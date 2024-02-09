#!/usr/bin/env python3

import subprocess
import sys

LONG_COMMAND_SUBSTRINGS = [
    'bazel-bin/go/go',
    'make',
    'mvn package',
    'mvn verify',
    'profile.py',
    'rv-predict.jar',
    'kprove',
    'kevm prove',
    'bazel',
    'run.sh',
    'kmxwasm.property'
]

def normalize(command):
    command = command.replace('\t', ' ')
    command = command.replace('\n', ' ')
    command = command.replace('  ', ' ')
    command = command.replace('  ', ' ')
    command = command.replace('  ', ' ')
    command = command.replace('  ', ' ')
    command = command.replace('  ', ' ')
    command = command.replace('  ', ' ')
    command = command.replace('  ', ' ')
    command = command.replace('  ', ' ')
    return command

def isLongCommand(command):
    command = normalize(command)
    #print command
    for s in LONG_COMMAND_SUBSTRINGS:
        if s in command:
            return True
    return False

def main(argv):
    if isLongCommand(' '.join(argv)):
        subprocess.call(
            ['paplay',
             '/home/virgil/bin/Rainbow.wav'])

if __name__ == '__main__':
    # print sys.argv
    main(sys.argv[1:])
