#!/usr/bin/python3

import sys

import tokenizer

def main(argv):
  with open(argv[0]) as f:
    tokens = list(tokenizer.tokenize_words(f.read()))
    print(tokens)
    print(tokenizer.serialize(tokens))

if __name__ == '__main__':
  main(sys.argv[1:])
