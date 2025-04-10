from expression import Expression
from expression_builder import ExpressionBuilder, build_wrap
from expressions.applied_function import AppliedFunction
import registry
from statements.returns import Returns
from tools import args_to_list, merge_dicts

class AppliedFunctionBuilder(ExpressionBuilder):
  def __init__(self, name:str, arguments:list, assignments:list, statements:list) -> None:
    for arg in arguments:
      assert isinstance(arg, Expression), [type(arg)]  # or isinstance(arg, Argument)
    self.__name = name
    self.__arguments = arguments
    self.__assignments = assignments
    self.__statements = statements

  def build(self):
    return AppliedFunction(self.__name, self.__arguments, self.__assignments, self.__statements)

class Function(object):
  pass

class Function(object):
  def __init__(self, name:str, arguments:list, assignments:list, statements:list) -> None:
    for arg in arguments:
      assert isinstance(arg, Expression), [name, type(arg)]  # or isinstance(arg, Argument)
    self.__name = name
    self.__arguments = arguments
    self.__assignments = assignments
    self.__statements = statements
    self.__summary_cache = None
    self.__substitutions = {}

  def __call__(self, *args) -> AppliedFunctionBuilder:
    arg_list = args_to_list(
                  *args,
                  expected_len=len(self.__arguments),
                  function_name = self.__name
              )
    arg_list = [build_wrap(arg) for arg in arg_list]
    for arg in arg_list:
      assert isinstance(arg, Expression), [type(arg)]
    substitution = merge_dicts(dict(zip(self.__arguments, arg_list)), self.__substitutions)
    # TODO: Check that the substitution RHS does not conflict with
    # the LHS of self.__assignments
    # TODO: Check that the substitution RHS does not conflict with
    # self.__arguments
    assignments = [(var, exp.substitute(substitution)) for var, exp in self.__assignments]
    statements = [stat.substitute(substitution) for stat in self.__statements]
    return AppliedFunctionBuilder(self.__name, arg_list, assignments, statements) 

  def name(self):
    return self.__name

  def substitute(self, argument:Expression, value:Expression):
    # TODO: Make immutable
    assert argument not in self.__substitutions
    self.__substitutions[argument] = value
    return self

  def __summary(self):
    if self.__summary_cache is None:
      self.__build_summary()
    return self.__summary_cache

  def with_name(self, name:str) -> Function:
    return Function(name, self.__arguments, self.__assignments, self.__statements)

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

  def details(self):
    retv = []
    self.append_details_to(retv, 0)
    return ''.join(retv)

  def append_details_to(self, output:int, level:int):
    first = True
    for s in self.__statements:
      if first:
        first = False
      else:
        output.append('\n')
      output.append('  ' * level)
      output.append('- ')
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

def function(name:str, *, arguments:list = [], assignments:list = [], statements:list = []):

  #arguments = [a.build() for a in arguments]
  f = Function(name, arguments, assignments, statements)
  registry.method_registry.register('undefined', f)
  return f

