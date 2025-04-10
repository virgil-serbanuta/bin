#!/usr/bin/env python3

import sys

def readFile(name):
    with open(name, "r") as f:
        return [l[:len(l) - 1] for l in f]

def findSequence(lines):
  l = len(lines) - 1
  for size in range(1, int(len(lines)/2)):
    if lines[l-2*size:l-size] == lines[l-size:l]:
      return lines[l-size:l]
  return []

def main(argv):
    if len(argv) != 1:
        print('Usage: repeated-sequence.py input-file')
        return
    lines = readFile(argv[0])
    sequence = findSequence(lines)
    if sequence:
      print('\n'.join(sequence))
    else:
      print('Not found')

if __name__ == "__main__":
    main(sys.argv[1:])
