#!/usr/bin/env python3

import re
import sys

from pathlib import Path

PATH_RE = re.compile(r'AstLocationFile \(FileLocation \{fileName = "[^"]*", line = \d+, column = \d+\}\)')
IMPLICIT_LOCATION = re.compile(
    r'AstLocationImplicit'
)
SORT_RE = re.compile(
    r'SortActualSort \(SortActual \{sortActualName = InternedId \{getInternedId = "([^"]*)", internedIdLocation = AstLocationNone\}, sortActualSorts = \[\]\}\)'
)
ELEMENT_VAR_RE = re.compile(
    r'\(SomeVariableNameElement \(ElementVariableName \{unElementVariableName = VariableName \{base = InternedId \{getInternedId = "([^"]*)", internedIdLocation = AstLocationNone\}, counter = Just \(Element (\d+)\)\}\}\),FreeVariableInfo \{sort = "([^"]*)", count = \d+\}\)'
)
ELEMENT_VAR_RE_NO_COUNTER = re.compile(
    r'\(SomeVariableNameElement \(ElementVariableName \{unElementVariableName = VariableName \{base = InternedId \{getInternedId = "([^"]*)", internedIdLocation = AstLocationNone\}, counter = Nothing\}\}\),FreeVariableInfo \{sort = "([^"]*)", count = \d+\}\)'
)
FREE_VARS = re.compile(
    r', termFreeVariables = FreeVariables \{getFreeVariables = fromList \[[^\]]*\]\}'
)
TOTAL = re.compile(
    r'termTotal = Total \{isTotal = True\}'
)
NOT_TOTAL = re.compile(
    r'termTotal = Total \{isTotal = False\}'
)
FUNCTION = re.compile(
    r'termFunction = Function \{isFunction = True\}'
)
NOT_FUNCTION = re.compile(
    r'termFunction = Function \{isFunction = False\}'
)
DEFINED = re.compile(
    r'termDefined = Defined \{isDefined = True\}'
)
NOT_DEFINED = re.compile(
    r'termDefined = Defined \{isDefined = False\}'
)
CREATED = re.compile(
    r', termCreated = Created \{getCreated = (?:Nothing|Just \[\])\}'
)
FULLY_SIMPLIFIED = re.compile(
    r'termSimplified = Simplified \(SimplifiedData \{sType = Fully, condition = Any\}\)'
)
PARTLY_SIMPLIFIED = re.compile(
    r'termSimplified = Simplified \(SimplifiedData \{sType = Partly, condition = Any\}\)'
)
CONSTRUCTOR_LIKE_HEAD = re.compile(
    r'termConstructorLike = ConstructorLike \{getConstructorLike = Just ConstructorLikeHead\}'
)
INJECTION_HEAD = re.compile(
    r'termConstructorLike = ConstructorLike \{getConstructorLike = Just SortInjectionHead\}'
)
NOT_CONSTRUCTOR_LIKE = re.compile(
    r'termConstructorLike = ConstructorLike \{getConstructorLike = Nothing\}'
)
HASH = re.compile(
    r', _tlHash = -?\d+'
)
INTERNED_ID = re.compile(
    r'InternedId {getInternedId = "([^"]+)", internedIdLocation = AstLocationNone}'
)
SYMBOL_SORTS = re.compile(
    r', symbolSorts = ApplicationSorts \{applicationSortsOperands = \[(?:"[^"]+",?)*\], applicationSortsResult = "[^"]+"}'
)
INJ_ATTRIBUTES = re.compile(
    r', injAttributes = Symbol \{(?:[^{}=]+=[^{}=]+\{[^{}]+\})*\}'
)
SYMBOL_ATTRIBUTES = re.compile(
    r', symbolAttributes = Symbol \{(?:[^{}=]+=[^{}=]+\{[^{}]+\})*\}'
)
MAYBE_LINE_COLUMN = r'(?:Nothing|Just \(LineColumn \{line = \d+, column = \d+\}\))'
SOURCE_LOCATION = re.compile(
    r', sourceLocation = SourceLocation \{location = Location \{start = ' + MAYBE_LINE_COLUMN + r', end = ' + MAYBE_LINE_COLUMN + '\}, source = Source \{unSource = [^{}]*\}\}'
)
APPLICATION_SYMBOL = re.compile(
    r'Symbol \{symbolConstructor = ("[^"]+"), symbolParams = \[\]\}'
)
INTERNAL_BYTES = re.compile(
    r'InternalBytesF \(Const \(InternalBytes \{internalBytesSort = "SortBytes", internalBytesValue = ("[^"]*")\}\)\)'
)
BUILTIN_AC_STUFF = re.compile(
    r', builtinAcUnit = "[^"]*", builtinAcElement = "[^"]*", builtinAcConcat = "[^"]*"'
)
INT_TOKEN = re.compile(
    r'InternalIntF \(Const \(InternalInt \{internalIntSort = "SortInt", internalIntValue = (\d+)\}\)\)'
)
INT_TERM_LIKE = re.compile(
    r'TermLike__ \{_tlAttributes = TermAttributes \{termSort = "SortInt", Total, Function, Defined, Simplified, ConstructorLikeHead\}, _tlTermLikeF = (\d+)\}'
)
BYTES_TERM_LIKE = re.compile(
    r'TermLike__ \{_tlAttributes = TermAttributes \{termSort = "SortBytes", Total, Function, Defined, Simplified, ConstructorLikeHead\}, _tlTermLikeF = (InternalBytes\("[^"]*"\))\}'
)
BYTES_KEY = re.compile(
    r'Key \{getKey = KeyAttributes \{keySort = "SortBytes"\} :< (InternalBytes\("[^"]*"\))\}'
)
POUND_STRING_TERM_LIKE = re.compile(
    r'TermLike__ \{_tlAttributes = TermAttributes \{termSort = "#String", Total, Function, Defined, Simplified, ConstructorLikeHead\}, _tlTermLikeF = StringLiteralF \(Const \(StringLiteral \{getStringLiteral = ("(?:[^"\\]|\\.)*")\}\)\)\}'
)
WASM_STRING_TERM_LIKE = re.compile(
    r'TermLike__ \{_tlAttributes = TermAttributes \{termSort = "SortWasmStringToken", Total, Function, Defined, Simplified, ConstructorLikeHead\}, _tlTermLikeF = DomainValueF \(DomainValue \{domainValueSort = "SortWasmStringToken", domainValueChild = ("(?:[^"\\]|\\.)*")\}\)\}'
)
VARIABLE_TERM_LIKE = re.compile(
    r'TermLike__ \{_tlAttributes = TermAttributes \{termSort = "([^"]+)", Total, Function, Defined, Simplified, NotConstructorLike\}, _tlTermLikeF = VariableF \(Const \(Variable \{variableName = SomeVariableNameElement \(ElementVariableName \{unElementVariableName = VariableName \{base = "([^"]+)", counter = Just \(Element (\d)+\)\}\}\), variableSort = "[^"]+"\}\)\)\}'
)
VARIABLE_NO_COUNTER_TERM_LIKE = re.compile(
    r'TermLike__ \{_tlAttributes = TermAttributes \{termSort = "([^"]+)", Total, Function, Defined, Simplified, NotConstructorLike\}, _tlTermLikeF = VariableF \(Const \(Variable \{variableName = SomeVariableNameElement \(ElementVariableName \{unElementVariableName = VariableName \{base = "([^"]+)", counter = Nothing\}\}\), variableSort = "[^"]+"\}\)\)\}'
)
EMPTY_CELL_MAP_TERM_LIKE = re.compile(
    r'TermLike__ \{_tlAttributes = TermAttributes \{termSort = "([^"]+)", Total, Function, Defined, Simplified, ConstructorLikeHead\}, _tlTermLikeF = InternalMapF \(InternalAc \{builtinAcSort = "[^"]*", builtinAcChild = NormalizedMap \{getNormalizedMap = NormalizedAc \{elementsWithVariables = \[\], concreteElements = fromList \[\], opaque = \[\]\}\}\}\)\}'
)
INJ_TERM_LIKE = re.compile(
    r'TermLike__ \{_tlAttributes = TermAttributes \{[^}]*\}, _tlTermLikeF = InjF \(Inj \{injConstructor = "inj", injFrom = "[^"]*", injTo = "[^"]*", injChild = ([^}\[\]]+)\}\)\}'
)
APPLICATION_TERM_LIKE = re.compile(
    r'TermLike__ \{_tlAttributes = TermAttributes \{[^}]*\}, _tlTermLikeF = ApplySymbolF \(Application \{applicationSymbolOrAlias = "([^"]*)", applicationChildren = \[([^]{}]*)\]\}\)\}'
)
APPLICATION_KEY = re.compile(
    r'Key \{getKey = KeyAttributes \{keySort = "[^"]*"\} :< ApplySymbolF \(Application \{applicationSymbolOrAlias = "([^"]*)", applicationChildren = \[([^]{}]*)\]\}\)\}'
)
MAP_VALUE = re.compile(
    r',MapValue {getMapValue = ([^]{}]*)}'
)
MAP_WITH_VAR_TERM_LIKE = re.compile(
    'TermLike__ \{_tlAttributes = TermAttributes \{termSort = "[^"]*", NotTotal, Function, NotDefined, Simplified, NotConstructorLike\}, _tlTermLikeF = InternalMapF \(InternalAc \{builtinAcSort = "[^"]*", builtinAcChild = NormalizedMap \{getNormalizedMap = NormalizedAc \{elementsWithVariables = \[([^]{}]*)\], concreteElements = fromList \[([^]{}]*)\], opaque = \[([^]{}]*)\]\}\}\}\)\}'
)
REMOVE_KLABEL = re.compile(
    r', klabel = Klabel \{getKlabel = Just "(?:[^"\\]|\\.)*"\}'
)

REPLACEMENTS = [
    (PATH_RE, 'AstLocationNone'),
    (IMPLICIT_LOCATION, 'AstLocationNone'),
    (SORT_RE, r'"\1"'),
    (ELEMENT_VAR_RE, r'\1_\2:\3'),
    (ELEMENT_VAR_RE_NO_COUNTER, r'\1:\2'),
    (FREE_VARS, ''),
    (TOTAL, 'Total'),
    (NOT_TOTAL, 'NotTotal'),
    (FUNCTION, 'Function'),
    (NOT_FUNCTION, 'NotFunction'),
    (DEFINED, 'Defined'),
    (NOT_DEFINED, 'NotDefined'),
    (CREATED, ''),
    (FULLY_SIMPLIFIED, 'Simplified'),
    (PARTLY_SIMPLIFIED, 'SimplifiedPartly'),
    (CONSTRUCTOR_LIKE_HEAD, 'ConstructorLikeHead'),
    (INJECTION_HEAD, 'InjectionHead'),
    (NOT_CONSTRUCTOR_LIKE, 'NotConstructorLike'),
    (HASH, ''),
    (INTERNED_ID, r'"\1"'),
    (SYMBOL_SORTS, ''),
    (SOURCE_LOCATION, ''),
    (REMOVE_KLABEL, ''),
    (INJ_ATTRIBUTES, ''),
    (SYMBOL_ATTRIBUTES, ''),
    (APPLICATION_SYMBOL, r'\1'),
    (INTERNAL_BYTES, r'InternalBytes(\1)'),
    (BUILTIN_AC_STUFF, ''),
    (INT_TOKEN, r'\1'),
    (INT_TERM_LIKE, r'\1'),
    (BYTES_TERM_LIKE, r'\1'),
    (BYTES_KEY, r'\1'),
    (POUND_STRING_TERM_LIKE, r'\1'),
    (WASM_STRING_TERM_LIKE, r'WasmString(\1)'),
    (VARIABLE_TERM_LIKE, r'\2_\3:\1'),
    (VARIABLE_NO_COUNTER_TERM_LIKE, r'\2:\1'),
    (EMPTY_CELL_MAP_TERM_LIKE, r'.\1'),
    # (, ''),
    # (, ''),
    # (, ''),
    # (, ''),
    # (, ''),
]

REPEATED_REPLACEMENTS = [
    (APPLICATION_TERM_LIKE, r'\1(\2)'),
    (APPLICATION_KEY, r'\1(\2)'),
    (INJ_TERM_LIKE, r'inj(\1)'),
    (MAP_VALUE, r' -> \1'),
    (MAP_WITH_VAR_TERM_LIKE, r'\1, \2, \3'),
]

def cleanup(s:str) -> str:
    for (regexp, replacement) in REPLACEMENTS:
        s = regexp.sub(replacement, s)
    while True:
        start = s
        for (regexp, replacement) in REPEATED_REPLACEMENTS:
            s = regexp.sub(replacement, s)
        if start == s:
            break
    return s

def main(argv):
    assert len(argv) < 2
    input_file = 'backend.dump'
    if argv:
        input_file = argv[0]
    input_path = Path(input_file)
    input = input_path.read_text()
    output_path = input_path.parent / (input_path.name + '.filtered')
    output = cleanup(input)
    output_path.write_text(output)

if __name__ == '__main__':
    main(sys.argv[1:])