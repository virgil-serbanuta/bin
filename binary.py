#!/usr/bin/env python3

import subprocess
import sys

MAX_DISTANCE = 33554432  # 2^25

class Opts:
  def __init__(self):
    self.__start = 0
    self.__end = None

  def parseArgs(self, argv):
    if "--" not in argv:
      return argv
    idx = argv.index("--")
    self.__parseArgs(argv[:idx])
    self.__validate()
    return argv[idx + 1:]

  def start(self):
    return self.__start

  def end(self):
    return self.__end

  def __validate(self):
    if self.__end is not None:
      if self.__end <= self.start:
        print("The --end must be after the --start.")
        sys.exit(1)

  def __parseArgs(self, argv):
    while argv:
      if argv[0] == "--start":
        if len(argv) < 2:
          print("Expected a value for --start.")
          sys.exit(1)
        self.__start = int(argv[1])
        argv = argv[2:]
        continue
      if argv[0] == "--end":
        if len(argv) < 2:
          print("Expected a value for --end.")
          sys.exit(1)
        self.__end = int(argv[1])
        argv = argv[2:]
        continue
      print("Unknown argument: '%s'." % argv[0])
      sys.exit(1)

def runCommand(prefix, arg, suffix):
  return subprocess.run(prefix + [str(arg)] + suffix).returncode == 0

def search(opts, prefix, suffix):
  start = opts.start()
  startValue = runCommand(prefix, start, suffix)
  if opts.end() is None:
    distance = 1
    endValue = startValue
    end = start
    newStart = start
    print("Searching for the end:")
    while endValue == startValue:
      newStart = end
      if distance > MAX_DISTANCE:
        print("Could not find an end value with a distance up to %d." % distance)
        return False
      end = start + distance
      print("   ... trying end=%d" % end)
      endValue = runCommand(prefix, end, suffix)
      distance *= 2
    start = newStart
  else:
    end = opts.end()
    endValue = runCommand(prefix, end, suffix)
    if endValue == startValue:
      print("The end value is the same as the start value, cannot search for boundary.")
      return False

  print("Searching for the split:")
  while end - start > 1:
    print("   ... current interval=[%d, %d]" % (start, end))
    mid = int(start + (end - start) / 2)
    value = runCommand(prefix, mid, suffix)
    if value == startValue:
      start = mid
    elif value == endValue:
      end = mid
    else:
      print("Internal error: value (%s) different from both the start (%s) and the end (%s) values." % (value, startValue, endValue))
      sys.exit(1)
  print("Split = [%d, %d]" % (start, end))
  return True

def main(argv):
  opts = Opts()
  argv = opts.parseArgs(argv)
  if len(argv) < 1:
    print("Expected at least a command and an argument for that command.")
    sys.exit(1)
  if not "%" in argv:
    print("Expected a variable argument (%).")
    sys.exit(1)
  idx = argv.index("%")
  if idx == 0:
    print("The variable argument (%) is also the command.")
    sys.exit(1)
  prefix = argv[:idx]
  suffix = argv[idx + 1:]

  if search(opts, prefix, suffix):
    sys.exit(0)
  sys.exit(1)

if __name__ == "__main__":
    main(sys.argv[1:])