#!/usr/bin/env python3

import sys

def isOpen(c):
    return c in "{[("

def isClosed(c):
    return c in ")]}"

def startLine(f, open):
    f.write('\n')
    f.write('  ' * open)

def indent(f, lines):
    open = 0
    just_started = True
    for l in lines:
        for c in l:
            if isOpen(c):
                open = open + 1
                f.write(c)
                just_started = True
                startLine(f, open)
            elif isClosed(c):
                if open>0:
                    open = open - 1
                startLine(f, open)
                f.write(c)
                just_started = False
            elif c == ',':
                f.write(c)
                startLine(f, open)
                just_started = True
            elif c == ' ':
                if not just_started:
                    f.write(c)
            else:
                f.write(c)
                just_started = False
        startLine(f, open)


def readFile(name):
    with open(name, "r") as f:
        return [l.strip() for l in f]

def main(argv):
    if len(argv) != 1:
        print("Expected only one argument.")
        return
    lines = readFile(argv[0])
    with open(argv[0] + ".indent", "w") as f:
        indent(f, lines)

if __name__ == "__main__":
    main(sys.argv[1:])