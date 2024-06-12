#!/usr/bin/env python3

from typing import Callable, List, Tuple

def first_caps(val: str) -> str:
    return val[0].upper() + val[1:]

def make_ceil(
        name:str, ftype:str,
        make_total:Callable[[List[str]], str],
        make_normal:Callable[[List[str]], str],
        make_total_declaration:Callable[[List[str]], str],
        args:List[Tuple[str, str]]
    ) -> str:
    if name.startswith('#'):
        name_for_defined = name[1:]
    else:
        name_for_defined = name
    defined_name = f'defined{first_caps(name_for_defined)}'
    total_name = f'{name}Total'
    named_args = [
        (first_caps(arg_name) if arg_name else f'Arg{arg_index}', arg_type)
        for (arg_name, arg_type), arg_index in zip(args, range(0, len(args)), strict=True)
    ]

    set_typed_args = [f'@{arg_name}:{arg_type}' for arg_name, arg_type in named_args]
    set_untyped_args = [f'@{arg_name}' for arg_name, _ in named_args]
    typed_args = [f'{arg_name}:{arg_type}' for arg_name, arg_type in named_args]
    untyped_args = [arg_name for arg_name, _ in named_args]
    set_untyped_args_str = ', '.join(set_untyped_args)
    untyped_args_str = ', '.join(untyped_args)

    function_args = [
        f'{arg_name}: {arg_type}' if arg_name else arg_type
        for arg_name, arg_type in args
    ]

    open_parens = '(' * len(args)
    ceil = [
      f'    rule #Ceil({make_normal(set_typed_args)})\n',
      f'        =>  {open_parens}{{ {defined_name}({set_untyped_args_str})  #Equals true }}\n',
    ]
    for arg_name, arg_type in named_args:
        ceil.append(f'          #And #Ceil(@{arg_name}))\n')
    ceil.append('        [simplification]\n\n')


    ceil.append(f'''
    syntax {ftype} ::= {make_total_declaration(function_args)}
        [function, total, klabel({total_name}), symbol, no-evaluators]

    rule {make_total(typed_args)}
        => {make_normal(untyped_args)}
        requires {defined_name}({untyped_args_str})
        [concrete, simplification]
''')
    for arg_name, _ in named_args:
        ceil.append(f'''
    rule {make_normal(typed_args)}
        => {make_total(untyped_args)}
        requires {defined_name}({untyped_args_str})
        [symbolic({arg_name}), simplification]
''')

    return ''.join(ceil)

def make_function_ceil(name:str, ftype:str, args:List[Tuple[str, str]]) -> str:
    total_name = f'{name}Total'

    def make_total(args: List[str]) -> str:
        return f'{total_name}({", ".join(args)})'
    def make_normal(args: List[str]) -> str:
        return f'{name}({", ".join(args)})'

    return make_ceil(
        name=name, ftype=ftype,
        make_total=make_total,
        make_normal=make_normal,
        make_total_declaration=make_total,
        args=args,
    )


def make_operator_ceil(operator:str, name:str, ftype:str, args:List[Tuple[str, str]]) -> str:
    assert 2 == len(args)

    def make_total(args_: List[str]) -> str:
        assert 2 == len(args_)
        return f'{args_[0]} {operator}Total {args_[1]}'
    def make_total_declaration(args_: List[str]) -> str:
        assert 2 == len(args_)
        return f'{args_[0]} "{operator}Total" {args_[1]}'
    def make_normal(args_: List[str]) -> str:
        assert 2 == len(args_)
        return f'{args_[0]} {operator} {args_[1]}'

    return make_ceil(
        name=name, ftype=ftype,
        make_total=make_total,
        make_normal=make_normal,
        make_total_declaration=make_total_declaration,
        args=args,
    )

def make_complex_ceil(name:str, ftype:str, definition:List[str|Tuple[str, str]]) -> str:
    total_name = f'{name}Total'

    def make_total(args_: List[str]) -> str:
        return f'{total_name}({", ".join(args_)})'
    def make_total_declaration(args_: List[str]) -> str:
        return f'{total_name}({", ".join(args_)})'
    def make_normal(args_: List[str]) -> str:
        assert len(args_) == len(definition) // 2
        pieces = []
        for i in range(0, len(definition) - 1, 2):
            pieces.append(definition[i])
            pieces.append(args_[i // 2])
        pieces.append(definition[-1])
        return ''.join(pieces)

    args = [definition[i] for i in range(1, len(definition), 2)]

    return make_ceil(
        name=name, ftype=ftype,
        make_total=make_total,
        make_normal=make_normal,
        make_total_declaration=make_total_declaration,
        args=args,
    )

def make_map_lookup_ceil() -> str:
    return f'''
    rule M:Map[Key:KItem] orDefault _:KItem
        => M[Key]
        requires definedMapLookup(M, Key)
        [concrete, simplification]
    rule M:Map[Key:KItem]
        => M[Key] orDefault 0
        requires definedMapLookup(M, Key)
        [symbolic(M), simplification]
    rule M:Map[Key:KItem]
        => M[Key] orDefault 0
        requires definedMapLookup(M, Key)
        [symbolic(Key), simplification]
'''

def main() -> None:
    print(make_function_ceil('substrBytes', 'Bytes', [('', 'Bytes'), ('startIndex', 'Int'), ('endIndex', 'Int')]))
    print(make_function_ceil('replaceAtBytes', 'Bytes', [('dest', 'Bytes'), ('index', 'Int'), ('src', 'Bytes')]))
    print(make_function_ceil('padRightBytes', 'Bytes', [('', 'Bytes'), ('length', 'Int'), ('value', 'Int')]))
    print(make_function_ceil('log2Int', 'Int', [('', 'Int')]))
    print(make_operator_ceil('modInt', 'modInt', 'Int', [('', 'Int'), ('', 'Int')]))
    print(make_function_ceil('#getElemSegment', 'Index', [('', 'ElemSegment'), ('', 'Int')]))
    print(make_function_ceil('#getInts', 'Int', [('', 'Ints'), ('', 'Int')]))
    print(make_function_ceil('#signed', 'Int', [('', 'IValType'), ('', 'Int')]))
    print(make_operator_ceil('<<Int', 'shlInt', 'Int', [('', 'Int'), ('', 'Int')]))
    print(make_operator_ceil('>>Int', 'shrInt', 'Int', [('', 'Int'), ('', 'Int')]))
    print(make_operator_ceil('^Int', 'powInt', 'Int', [('', 'Int'), ('', 'Int')]))
    print(make_operator_ceil('/Int', 'divInt', 'Int', [('', 'Int'), ('', 'Int')]))

    print(make_complex_ceil('listLookup', 'KItem', ['', ('', 'List'), '[', ('index', 'Int'), ']', ]))
    print(make_complex_ceil('listBytesLookup', 'Bytes', ['', ('', 'ListBytes'), '[', ('index', 'Int'), ']', ]))
    print(make_complex_ceil('projectBytes', 'Bytes', ['{', ('', 'KItem'), '}:>Bytes', ]))
    print(make_complex_ceil('projectInt', 'Int', ['{', ('', 'KItem'), '}:>Int', ]))

    print(make_map_lookup_ceil())

if __name__ == '__main__':
    main()