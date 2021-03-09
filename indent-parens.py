#!/usr/bin/env python3

import sys

class SoftToken:
    def __init__(self, str):
        self.__str = str

    def __str__(self):
        return self.__str

class AntiSoftToken:
    def __init__(self, str):
        self.__str = str

    def __str__(self):
        return self.__str

class IndenterLevel:
    def __init__(self, parent, length_limit, f):
        self.__parent = parent
        self.__unprinted_tokens = []
        self.__unprinted_token = None
        self.__hard_line_breaks = False
        self.__length = 0
        self.__length_limit = length_limit
        self.__f = f

        if parent:
            parent.addToken(self)

    def parent(self):
        return self.__parent

    def addToken(self, token):
        if self.__hard_line_breaks:
            self.flush()
            self.__unprinted_token = token
        else:
            self.__unprinted_tokens.append(token)
            self.__addToLength(self.__tokenLength(token))

    def flush(self):
        if self.__hard_line_breaks:
            if self.__unprinted_token:
                self.__flushToken(self.__unprinted_token)
                self.__unprinted_token = None
            return
        for token in self.__unprinted_tokens:
            self.__flushToken(token)
        self.__unprinted_tokens = []

    def __flushToken(self, token):
        if isinstance(token, IndenterLevel):
            token.flush()
            return
        if isinstance(token, SoftToken):
            if self.__hard_line_breaks:
                self.__f.write(str(token))
            return
        if isinstance(token, AntiSoftToken):
            if not self.__hard_line_breaks:
                self.__f.write(str(token))
            return
        self.__f.write(token)

    def __addToLength(self, length):
        if self.__hard_line_breaks:
            return
        self.__length += length
        if self.__length > self.__length_limit:
            self.setHardLineBreaks()
            return
        if self.__parent:
            self.__parent.__addToLength(length)

    def __tokenLength(self, token):
        if isinstance(token, IndenterLevel):
            assert not token.__hard_line_breaks
            return token.__length
        if isinstance(token, SoftToken):
            return 0
        if isinstance(token, AntiSoftToken):
            return len(str(token))
        return len(token)

    def setHardLineBreaks(self):
        if self.__hard_line_breaks:
            return
        if self.__parent:
            self.__parent.setHardLineBreaks()
        self.__hard_line_breaks = True
        if self.__unprinted_tokens:
            lastToken = self.__unprinted_tokens.pop()
            for token in self.__unprinted_tokens:
                self.__flushToken(token)
            self.__unprinted_tokens = []
            self.__unprinted_token = lastToken

def isOpen(c):
    return c in "{[("

def isClosed(c):
    return c in ")]}"

def startLine(indenter, open):
    indenter.addToken(SoftToken('\n' + '  ' * open))

def indent(f, lines):
    max_len = 80
    indenter = IndenterLevel(None, max_len, f)
    open = 0
    just_started = True
    for l in lines:
        for c in l:
            if isOpen(c):
                open = open + 1
                indenter = IndenterLevel(indenter, max_len, f)
                indenter.addToken(c)
                just_started = True
                startLine(indenter, open)
            elif isClosed(c):
                if open>0:
                    open = open - 1
                startLine(indenter, open)
                indenter.addToken(c)
                if indenter.parent():
                    indenter = indenter.parent()
                just_started = False
            elif c == ',':
                indenter.addToken(c)
                startLine(indenter, open)
                just_started = True
            elif c == ' ':
                if not just_started:
                    indenter.addToken(c)
                else:
                    indenter.addToken(AntiSoftToken(c))
            else:
                indenter.addToken(c)
                just_started = False
        indenter.setHardLineBreaks()
        startLine(indenter, open)
    indenter.flush()

def readFile(name):
    with open(name, "r") as f:
        return [l.strip() for l in f]

def main(argv):
    if len(argv) != 1:
        print("Expected exactly one arguments: the input file.")
        sys.exit(1)
    lines = readFile(argv[0])
    with open(argv[0] + ".indent", "w") as f:
        indent(f, lines)

if __name__ == "__main__":
    main(sys.argv[1:])