#!/usr/bin/env python3

import re
import sys

class Node:
    def __init__(self, name, line, line_index):
        self.__name = name
        self.__line = line
        self.__start_line_index = line_index
        self.__end_line_index = line_index
        self.__children = []

    def append(self, child):
        self.__children.append(child)

    def endAt(self, node):
        self.__end_line_index = node.endLineIndex()
        self.append(node)

    def endLineIndex(self):
        return self.__end_line_index

    def startLineIndex(self):
        return self.__start_line_index

    def children(self):
        return self.__children

    def name(self):
        return self.__name

    def line(self):
        return self.__line

    def indentLevel(self):
        return int((len(self.line()) - len(self.line().strip())) / 2)

    def endsWith(self, text):
        if self.__children:
            return lastElement(self.children()).endsWith(text)
        return self.__line.endswith(text)

    def changeChildren(self, children):
        new = Node(self.__name, self.__line, self.__start_line_index)
        new.__end_line_index = self.__end_line_index
        new.__children = children
        return new

null_node = [Node('null', ('  ' * i) + '_', -1) for i in range(0, 10000)]
null_comma_node = [Node('null', ('  ' * i) + '_,', -1) for i in range(0, 10000)]

def parseNode(line, line_index):
    assert isOpen(lastElement(line))
    return Node(line[len(line) - 1], line, line_index)

def leafNode (line, line_index):
    return Node(line, line, line_index)

def lastElement(l):
    assert len(l) >= 1
    return l[len(l) - 1]

def isOpen(c):
    return c in "{[("

def isClosed(c):
    return c in ")]}"

def parseLines(lines):
    pending_nodes = [Node('top', '', 0), parseNode(lines[0], 1)]
    line_index = 0
    for line in lines[1:]:
        stripped = line.strip()
        expected_spaces = (len(pending_nodes) - 1) * 2
        actual_spaces = len(line) - len(stripped)
        assert expected_spaces == actual_spaces or expected_spaces == actual_spaces - 1 or (')' in line) or ('}' in line) or (']' in line)
        line_index = line_index + 1
        if isOpen(lastElement(line)):
            if stripped and isClosed(stripped[0]):
                lastElement(pending_nodes).append(leafNode(line, line_index))
            else:
                pending_nodes.append(parseNode(line, line_index))
        else:
            if stripped and isClosed(stripped[0]):
                new_node = pending_nodes.pop()
                new_node.endAt(leafNode(line, line_index))
            else:
                assert not (')' in line) and not (']' in line) and not ('}' in line), [line]
                new_node = leafNode(line, line_index)
            lastElement(pending_nodes).append(new_node)
    assert len(pending_nodes) == 1
    nodes = pending_nodes[0].children()
    assert len(nodes) == 1
    return nodes[0]

def simplifyTree(tree, filter):
    child_selected = False
    children = tree.children()
    new_children = []
    for n in children:
        simplified = simplifyTree(n, filter)
        if simplified is None:
            stripped = n.line().strip()
            if stripped and isClosed(stripped[0]):
                new_children.append(n)
            elif n.endsWith(','):
                new_children.append(null_comma_node[n.indentLevel()])
            else:
                new_children.append(null_node[n.indentLevel()])
        else:
            new_children.append(simplified)
            child_selected = True

    if child_selected or filter.isSelected(tree.line()):
        return tree.changeChildren(new_children)
    return None

def treeToFile(f, tree):
    if tree.startLineIndex() == tree.endLineIndex():
        if tree.startLineIndex() >= 0:
            f.write("%s  # %d\n" % (tree.line(), tree.startLineIndex()))
        else:
            f.write("%s\n" % tree.line())
    else:
        f.write(
            "%s  # %d - %d\n"
                % (tree.line(), tree.startLineIndex(), tree.endLineIndex()))
    for c in tree.children():
        treeToFile(f, c)

def simplify(f, lines, filter):
    tree = parseLines(lines)
    simplified_tree = simplifyTree(tree, filter)
    treeToFile(f, simplified_tree)

def readFile(name):
    with open(name, "r") as f:
        return [l[:len(l) - 1] for l in f]

class ContainsFilter:
    def __init__(self, pattern):
        self.__pattern = pattern
        self.__re = re.compile(pattern)

    def isSelected(self, text):
        return self.__re.search(text) is not None

class OrFilter:
    def __init__(self, filters):
        self.__filters = filters

    def isSelected(self, text):
        for f in self.__filters:
            if f.isSelected(text):
                return True
        return False

def main(argv):
    if len(argv) <= 1:
        print('Expected more than one argument.')
        return
    lines = readFile(argv[0])
    with open(argv[0] + ".simplified", "w") as f:
        simplify(f, lines, OrFilter([ContainsFilter(arg) for arg in argv[1:]]))

if __name__ == "__main__":
    main(sys.argv[1:])
