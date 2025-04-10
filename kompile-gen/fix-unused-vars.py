#!/usr/bin/python3

import re
import sys

(NONE, WARNING, ERROR) = range(0, 3)

SOURCE_START = '	Source('
LOCATION_START = '	Location('

def splitErrors(input):
  error_type = NONE
  error_message = ''
  error_source = ''

  (OUT, AFTER_ERROR, AFTER_SOURCE, AFTER_LOCATION) = range(0, 4)
  state = OUT
  for line in input:
    if line[-1] == '\n':
      line = line[:-1]
    if state == OUT:
      if line.startswith('[Error]'):
        error_type = ERROR
      elif line.startswith('[Warning]'):
        error_type = WARNING
      else:
        continue
      idx = line.find(':')
      error_message = line[idx + 2:]
      state = AFTER_ERROR
      continue
    if state == AFTER_ERROR:
      if line.startswith('[Error]'):
        error_type = ERROR
        continue
      if line.startswith('[Warning]'):
        error_type = WARNING
        continue
      if not line.startswith(SOURCE_START):
        error_message += '\n' + line
        continue
      assert line.endswith(')')
      error_source = line[len(SOURCE_START):-1]
      state = AFTER_SOURCE
      continue
    if state == AFTER_SOURCE:
      assert line.startswith(LOCATION_START)
      assert line.endswith(')')
      line = line[len(LOCATION_START):-1]
      items = line.split(',')
      yield (error_type, error_message, error_source, (int(items[0]), int(items[1])), (int(items[2]), int(items[3])))
      state = OUT
      continue

unused_var_re = re.compile("^Variable '.+' defined\s+but\s+not\s+used.\s+Prefix\s+variable\s+name\s+with\s+underscore\s+if\s+this\s+is\s+intentional.$")

class ErrorOrganizer:
  def __init__(self, reverse):
    self.__last_line = -1
    self.__last_line_columns = None
    self.__file_positions = []
    self.__reverse = reverse

  def positions(self):
    return self.__file_positions

  def add(self, line, column):
    if self.__last_line == -1:
      self.__last_line = line
      self.__last_line_columns = [column]
      self.__file_positions = []
    else:
      self.__end_line_if_needed(line)
      self.__last_line_columns.append(column)

  def finish(self):
    if self.__last_line != -1:
      self.__end_line()
      self.__last_line = -1
  
  def __end_line_if_needed(self, line):
    if self.__last_line != line:
      self.__end_line()
      self.__last_line = line

  def __end_line(self):
    assert self.__last_line_columns
    self.__last_line_columns.sort(reverse=self.__reverse)
    self.__file_positions.append((self.__last_line, self.__last_line_columns))
    self.__last_line_columns = []

def fixUnusedVarWarningsFile(file_name, positions):
  #print([file_name, positions])
  #return
  with open(file_name, 'r') as f:
    lines = list(f)
  for (line_no, line_positions) in positions:
    line = lines[line_no - 1]
    last_column = len(line)
    for column in line_positions:
      assert column < last_column, [line_no, column, line_positions, file_name, last_column, line]
      last_column = column
      line = line[:column - 1] + '_' + line[column - 1:]
    lines[line_no - 1] = line
  with open(file_name, 'w') as f:
    for line in lines:
      f.write(line)

def fixUnusedVarWarnings(errors):
  organizer = ErrorOrganizer(True)
  last_source = ''
  for (error_type, error_message, error_source, (line_start, column_start), (_line_end, _column_end)) in errors:
    if error_type != WARNING:
      continue
    #print([error_message, error_source, (line_start, column_start)])
    if unused_var_re.search(error_message) == None:
      continue
    #print('a')
    if last_source != error_source:
      organizer.finish()
      positions = organizer.positions()
      if positions:
        fixUnusedVarWarningsFile(last_source, positions)
      last_source = error_source
    organizer.add(line_start, column_start)
  organizer.finish()
  positions = organizer.positions()
  if positions:
    fixUnusedVarWarningsFile(last_source, positions)

def main(argv):
  with open(argv[0]) as f:
    fixUnusedVarWarnings(splitErrors(f))

if __name__ == '__main__':
  main(sys.argv[1:])
