#!/usr/bin/env python

import fileinput

class Line:
    def __init__(self, line, startTag, endTag, time):
        self.__line = line
        self.__startTag = startTag
        self.__endTag = endTag
        self.__time = time
        self.__endLine = None
        self.__innerLines = []

    def isStart(self):
        return not (self.__startTag is None)
    def isEnd(self):
        return not (self.__endTag is None)
    def isDesirable(self):
        return self.__endLine.__time > 0.2
    def isOpen(self):
        return not (self.__startTag is None) and (self.__endTag is None)
    def close(self, endLine):
        assert self.__endLine is None
        assert self.__startTag == endLine.__endTag
        self.__endLine = endLine
    def addLine(self, line):
        self.__innerLines.append(line)
    def show(self, level):
        print ("%s%s" % ("    " * level, self.__line))
        for child in self.__innerLines:
            child.show(level + 1)
        if not (self.__endLine is None):
            print ("%s%s" % ("    " * level, self.__endLine.__line))

def parseLine(line):
    chunks = line.split(" ")
    if not chunks:
        return None
    if chunks[-1] == "{":
        assert len(chunks) >= 2
        return Line(line, "-".join(chunks[:-1]), None, None)
    elif chunks[0] == "}":
        assert len(chunks) >= 3
        timeChunk = chunks[-1]
        assert timeChunk[-1] == "s"
        time = float(timeChunk[:-1])
        return Line(line, None, "-".join(chunks[1:-1]), time)
    else:
        return Line(line, None, None, None)

def filter():
    lineStack = []
    for line in fileinput.input():
        parsed = parseLine(line.strip())
        if parsed is None:
            continue
        if parsed.isStart():
            lineStack.append(parsed)
            continue
        if parsed.isEnd():
            lastOpenLine = lineStack.pop()
            lastOpenLine.close(parsed)
            if not lastOpenLine.isDesirable():
                continue
            parsed = lastOpenLine

        if lineStack and lineStack[-1].isOpen():
            lineStack[-1].addLine(parsed)
        else:
            lineStack.append(parsed)

    return lineStack

def show(lines):
    for line in lines:
        line.show(0)

def main():
    show(filter())

if __name__ == "__main__":
    main()