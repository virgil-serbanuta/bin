#!/usr/bin/env python3

import sys

def index_line(line:str, additional_depth: int, prefix:list[str], indexed:dict) -> None:
    if len(prefix) == 0:
        prefix_str = '['
    else:
        prefix_str = ''.join('[' + s + ']' for s in prefix)
    depth = len(prefix) + additional_depth

    if not line.startswith(prefix_str):
        return
    pieces = line[1:].split('][')
    if len(pieces) < 2:
        return
    if len(pieces) > depth:
        pieces = pieces[:depth]
    tree = indexed
    for index in range(0, len(pieces)):
        piece = pieces[index]
        if piece not in tree:
            tree[piece] = [0, {}]
        value = tree[piece]
        value[0] += 1
        tree = value[1]

def remove_small(indexed:dict, min_count:int) -> None:
    keys = list(indexed.keys())
    for key in keys:
        (count, children) = indexed[key]
        if count < min_count:
            del indexed[key]
        else:
            remove_small(children, min_count)

def main(args) -> None:
    indexed = {}
    with open(args[0]) as f:
        line_no = 0
        for line in f:
            line_no += 1
            if 0 == (line_no & 0xffff):
                print(line_no)
            index_line(
                line,
                3,
                [ 'kore', 'simplify', 'term f4410af'
                , 'simplification 044ac44e', 'term 3845cab', 'term d21ed79'
                , 'term f2fa5de', 'term 3464051', 'term 86dd1ff'
                , 'term 8f4abd2', 'term b0a286c', 'term 41ccb9d'
                , 'term af89eb6', 'term f8eb6e2', 'term 3b055b7'
                , 'term 8ab83c9', 'term 8973cfa', 'simplification a56f6c7c'
                , 'term fc06cc3', 'term a8ce772', 'simplification c1128672'
                , 'term 4c0f4a7', 'simplification 9b603eda'
                , 'term 60c4d4a'
                ,
                ],
                indexed
            )
    remove_small(indexed, 10)
    print(indexed)

if __name__ == '__main__':
    main(sys.argv[1:])
