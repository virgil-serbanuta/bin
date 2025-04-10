from expression import *
from global_vars import *
from registry import *
from statements import *
from tools import args_to_list

from function import Function

# class Function(Expression):
#   pass

# class Function(Expression):
#   def __init__(self, name:str, arguments:list, assignments:list, statements:list) -> None:
#     self.__name = name
#     self.__arguments = arguments
#     self.__assignments = assignments
#     self.__statements = statements
#     self.__summary_cache = None

#     for arg in arguments:
#       assert isinstance(arg, Expression), [type(arg)]  # or isinstance(arg, Argument)

#   def exp_equals(self, other):
#     if type(other) != Function:
#       return False
#     if self.__name != other.__name:
#       return False
#     if len(self.__arguments) != len(other.__arguments):
#       return False
#     for (a1, a2) in zip(self.__arguments, other.__arguments):
#       if not a1.exp_equals(a2):
#         return False
#     return True

#   def name(self):
#     return self.__name

#   def __summary(self):
#     if self.__summary_cache is None:
#       self.__build_summary()
#     return self.__summary_cache

#   def with_name(self, name:str) -> Function:
#     return Function(name, self.__arguments, self.__assignments, self.__statements)

#   def __call__(self, *args) -> Function:
#     arg_list = args_to_list(*args, expected_len=len(self.__arguments))
#     arg_list = [wrap_constant(arg) for arg in arg_list]
#     for arg in arg_list:
#       assert isinstance(arg, Expression), [type(arg)]
#     substitution = dict(zip(self.__arguments, arg_list))
#     # TODO: Check that the substitution RHS does not conflict with
#     # the LHS of self.__assignments
#     # TODO: Check that the substitution RHS does not conflict with
#     # self.__arguments
#     assignments = [(var, exp.substitute(substitution)) for var, exp in self.__assignments]
#     statements = [stat.substitute(substitution) for stat in self.__statements]
#     return Function(self.__name, arg_list, assignments, statements) 

#   def append_to(self, output:list, level:int):
#     self.append_header_to(output, level)

#   def header(self):
#     retv = []
#     self.append_header_to(retv, 0)
#     return ''.join(retv)

#   def append_header_to(self, output:list, level:int):
#     output.append(self.__name)
#     output.append('(')
#     first = True
#     for arg in self.__arguments:
#       if first:
#         first = False
#       else:
#         output.append(', ')
#       arg.append_to(output, level + 3)
#     output.append(')')

#   def definitions(self):
#     retv = []
#     for assignment in self.__assignments:
#       retv.append('  (')
#       assignment.append_to(retv, 1)
#       retv.append(')\n')
#     return ''.join(retv)

#   def summary(self):
#     retv = []
#     self.append_summary_to(retv, 0)
#     return ''.join(retv)

#   def append_summary_to(self, output:list, level:int):
#     first = True
#     for s in self.__summary():
#       if first:
#         first = False
#       else:
#         output.append('\n')
#       output.append('  - ')
#       s.append_to(output, level + 1)

#   def details(self):
#     retv = []
#     self.append_details_to(retv, 0)
#     return ''.join(retv)

#   def append_details_to(self, output:int, level:int):
#     first = True
#     for s in self.__statements:
#       if first:
#         first = False
#       else:
#         output.append('\n')
#       output.append('  ' * level)
#       output.append('- ')
#       s.append_to(output, level + 1)


#   def __build_summary(self):
#     global building
#     assert not building
#     self.__summary_cache = []
#     for statement in self.__statements:
#       statement = statement.filter_statements(self.__summary_cache)
#       flattened = statement.flatten()
#       for item in flattened:
#         if isinstance(item, Returns):
#           continue
#         if item.implied_by(self.__summary_cache):
#           continue
#         self.__summary_cache.append(item)
#       if isinstance(statement, Returns):
#         self.__summary_cache.append(statement)

class Endpoint(Expression):
  pass

class Endpoint(Expression):
  def __init__(self, *, only_owner:bool, payable:str, function:Function) -> None:
    self.__function = function
    self.__only_owner = only_owner
    self.__payable = payable

  def exp_equals(self, other):
    if type(other) != Endpoint:
      return False
    if not self.__function.exp_equals(other.__function):
      return False
    assert self.__only_owner == other.__only_owner
    assert self.__payable == other.__payable
    return True

  def name(self):
    return self.__function.name()

  def __call__(self, *args) -> Endpoint:
    return Endpoint(only_owner=self.__only_owner, payable=self.__payable, function=self.__function(*args))

  def append_to(self, output:list, level:int):
    self.append_header_to(output, level)
    self.__function.append_to(output, level)

  def header(self):
    retv = []
    self.append_header_to(retv, 0)
    self.__function.append_header_to(retv, 0)
    return ''.join(retv)

  def append_header_to(self, output:list, level:int):
    if self.__only_owner:
      output.append('[only_owner]')
    if self.__payable is not None:
      output.append('[payable("')
      output.append(self.__payable)
      output.append('")]')

  def definitions(self):
    return self.__function.definitions()

  def summary(self):
    return self.__function.summary()

  def append_summary_to(self, output:list, level:int):
    self.__function.append_summary_to(output, level)

  def details(self):
    return self.__function.details()

  def append_details_to(self, output:int, level:int):
    self.__function.append_details_to(output, level)

class FunctionWithCallback(Expression):
  pass

class FunctionWithCallback(Expression):
  def __init__(self, callback:Function, function:Function) -> None:
    assert callback == None or isinstance(callback, Function), [callback]
    assert isinstance(function, Function), [function]
    super().__init__()
    self.__callback = callback
    self.__function = function

  def name(self):
    return self.__function.name()

  def with_callback(self, callback) -> FunctionWithCallback:
    assert self.__callback is None
    return FunctionWithCallback(callback, self.__function)

  def call(self, *args:Expression) -> FunctionWithCallback:
    assert self.__callback is not None
    return FunctionWithCallback(
          self.__callback,
          self.__function(*args))

  def header(self):
    return self.__function.header()

  def append_header_to(self, output:list, level:int):
    return self.__function.append_header_to(output, level)

  def definitions(self):
    return self.__function.definitions()

  def summary(self):
    output = []
    self.append_summary_to(output, 0)
    return ''.join(output)

  def append_summary_to(self, output:list, level:int):
    self.__function.append_summary_to(output, level)
    if self.__callback is not None:
      #TODO: MEMOIZE
      output.append('\n')
      output.append('  ' * (level + 1))
      output.append('- callback')
      output.append('\n')
      output.append('  ' * (level + 2))
      output.append('- ')
      self.__callback.append_summary_to(output, level + 2)

  def details(self):
    assert self.__callback is None
    output = []
    self.__function.append_details_to(output, 1)
    output.append('\n  - callback')
    return ''.join(output)

  def append_to(self, output, level):
    self.__function.append_to(output, level)
    assert self.__callback is None
    # #TODO: MEMOIZE
    # output.append('\n')
    # output.append('  ' * (level + 1))
    # output.append('- callback')
    # output.append('\n')
    # output.append('  ' * (level + 2))
    # output.append('- ')
    # self.__callback.append_to(output, level + 2)
  
  def filter_statements(self, statements):
    function = self.__function.filter_statements(statements)
    callback = self.__callback.filter_statements(statements)
    return FunctionWithCallback(callback = callback, function = function)
