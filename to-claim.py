#!/usr/bin/env python3

import re
import sys

def defaultConfiguration():
  return (
    r'    <T><TT>\n'
    r'      <k> .K </k>\n'
    r'      invariantState(\n'
    r'          ?NumUsers1:Usize,\n'
    r'          ?UserIdToAddress1:Map,\n'
    r'          ?AddressToUserId1:Map,\n'
    r'          ?NumBoardMembers1:Usize,\n'
    r'          ?NumProposers1:Usize,\n'
    r'          ?UserRoles1:Map,\n'
    r'          ?Quorum1:Usize,\n'
    r'          ?ActionLastIndex1:Usize,\n'
    r'          ?ActionData1:Map,\n'
    r'          ?ActionSigners1:Map,\n'
    r'          ?PerformedActions:List):StateCell\n'
    r'    </TT></T>\n'
  )

REGEXPS = [
  ( r'\{\n'
    r'\s*([^\s].*)\n'
    r'\s*#Equals\n'
    r'\s*([^\s].*)\n'
    r'\s*([^\s].*)\n'
    r'\s*\}'
  , r'\1 ==K \2 \3'
  ),
  ( r'\{\n'
    r'\s*([^\s].*)\n'
    r'\s*#Equals\n'
    r'\s*([^\s].*)\n'
    r'\s*\}'
  , r'\1 ==K \2'
  ),
  ( r'#Not\s*(\(.*\))\n'
  , r'notBool \1\n'
  ),
  ( r'#And\n'
    r'\s+([^\s].*)\n'
  , r'andBool \1\n'
  ),
  ( r'andBool false ==K (.*)\n'
  , r'andBool notBool \1\n'
  ),
  ( r'andBool true ==K '
  , r'andBool '
  ),
  ( r'\b_'
  , r'Var'
  ),
  ( r"'QuesUnds'"
  , r'VarUnds'
  ),
  ( r'  ((?:notBool|#Not)(?:.*\n)*)'
    r'andBool\s+(<T>(?:.*\n)*\s*</T>\n)'
    r'((?:andBool.*\n)*)'
  , r'claim\n'
    r'  \2  =>\n'
    + defaultConfiguration() +
    r'  requires true\n'
    r'andBool \1\n'
    r'\3'
  ),
  ( r'andBool'
  , r'    andBool'
  ),
  ( r'~> \.'
  , r'~> .K'
  )
]

def readFile(name):
  with open(name, 'r') as f:
    return f.read()

def writeFile(name, text):
  with open(name, 'w') as f:
    f.write(text)

def regexpTransform(text, left, right):
  return re.sub(left, right, text)

def transform(text):
  for left, right in REGEXPS:
    text = regexpTransform(text, left, right)
  return text

def main(argv):
  if len(argv) < 1:
    print("Expected input file name")
  writeFile(argv[0] + ".k", transform(readFile(argv[0])))

if __name__ == "__main__":
  main(sys.argv[1:])
