#!/usr/bin/env python3

import sys

def indentZ3(lines):
  indent_level = 0
  indent = ''
  out = []
  for line in lines:
    line = line.strip()
    if not line:
      continue
    out.append(indent + line)
    if line == '(push 1 )':
      indent_level += 1
      indent = indent_level * '  '
    if line == '(pop 1 )':
      indent_level -= 1
      indent = indent_level * '  '
  return out

def main(argv):
  with open(argv[0]) as f:
    out = indentZ3(f)
  with open(argv[0] + '.indent', 'w') as f:
    f.writelines([line + '\n' for line in out])

if __name__ == '__main__':
  main(sys.argv[1:])