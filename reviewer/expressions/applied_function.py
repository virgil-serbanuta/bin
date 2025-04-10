from ast import arg
from expression import Expression, Variable
from statements.returns import Returns

class AppliedFunction(Expression):
  pass

class AppliedFunction(Expression):
  def __init__(self, name:str, arguments:list, assignments:list, statements:list) -> None:
    self.__name = name
    self.__arguments = arguments
    self.__assignments = assignments
    self.__statements = statements
    self.__summary_cache = None

    for arg in arguments:
      assert isinstance(arg, Expression), [type(arg)]  # or isinstance(arg, Argument)

  def substitute(self, substitution:dict) -> AppliedFunction:
    arguments = [a.substitute(substitution) for a in self.__arguments]
    for var, _ in self.__assignments:
      assert isinstance(var, Variable)
      assert var not in substitution
    assignments = [(var, value.substitute(substitution)) for var, value in self.__assignments]
    statements = [s.substitute(substitution) for s in self.__statements]
    return AppliedFunction(self.__name, arguments, assignments, statements)

  def exp_equals(self, other):
    if type(other) != AppliedFunction:
      return False
    if self.__name != other.__name:
      return False
    if len(self.__arguments) != len(other.__arguments):
      return False
    for (a1, a2) in zip(self.__arguments, other.__arguments):
      if not a1.exp_equals(a2):
        return False
    return True

  def name(self):
    return self.__name

  def __summary(self):
    if self.__summary_cache is None:
      self.__build_summary()
    return self.__summary_cache

  def append_to(self, output:list, level:int):
    self.append_header_to(output, level)

  def header(self):
    retv = []
    self.append_header_to(retv, 0)
    return ''.join(retv)

  def append_header_to(self, output:list, level:int):
    output.append(self.__name)
    output.append('(')
    first = True
    for arg in self.__arguments:
      if first:
        first = False
      else:
        output.append(', ')
      arg.append_to(output, level + 3)
    output.append(')')

  def definitions(self):
    retv = []
    for assignment in self.__assignments:
      retv.append('  (')
      assignment.append_to(retv, 1)
      retv.append(')\n')
    return ''.join(retv)

  def summary(self):
    retv = []
    self.append_summary_to(retv, 0)
    return ''.join(retv)

  def append_summary_to(self, output:list, level:int):
    first = True
    for s in self.__summary():
      if first:
        first = False
      else:
        output.append('\n')
      output.append('  - ')
      s.append_to(output, level + 1)

  def __build_summary(self):
    self.__summary_cache = []
    for statement in self.__statements:
      statement = statement.filter_statements(self.__summary_cache)
      flattened = statement.flatten()
      for item in flattened:
        if isinstance(item, Returns):
          continue
        if item.implied_by(self.__summary_cache):
          continue
        self.__summary_cache.append(item)
      if isinstance(statement, Returns):
        self.__summary_cache.append(statement)
