from pyclbr import Function
from tools import args_to_list


class Value(object):
  def __init__(self):
    pass

class Expression(object):
  pass

class FieldAccess(Expression):
  pass

class MethodCall(object):
  pass

class Expression(object):
  def __init__(self):
    pass

  def type_(self):
    return 'undefined'

class Constant(Expression):
  def __init__(self, value):
    self.__value = value

  def exp_equals(self, other):
    if type(other) != Constant:
      return False
    return self.__value == other.__value

  def append_to(self, output, _level):
    output.append(repr(self.__value))

  def substitute(self, _:dict) -> Expression:
    return self

def wrap_constant(value):
  if value is None:
    return value
  if isinstance(value, int):
    return Constant(value)
  if isinstance(value, str):
    return Constant(value)
  assert isinstance(value, Expression), [value]
  return value

class FieldAccess(Expression):
  def __init__(self, obj:Expression, name:str) -> None:
    assert isinstance(obj, Expression)
    self.__name = name
    self.__obj = obj

  def append_to(self, output, level):
    self.__obj.append_to(output, level)
    output.append('.')
    output.append(self.__name)


class Variable(Expression):
  def __init__(self, name):
    self.__name = name

  def __hash__(self):
    return hash(self.__name) ^ 483

  def exp_equals(self, other):
    if type(other) != Variable:
      return False
    return self.__name == other.__name

  def append_to(self, output, _level):
    output.append(self.__name)

  def substitute(self, substitution:dict) -> Expression:
    if self in substitution:
      return substitution[self]
    return self

class NamedValue(Expression):
  def __init__(self, expression:Expression, format_chunks:list, *format_args:Expression) -> None:
    super().__init__()
    self.__expression = expression
    self.__format_chunks = format_chunks
    self.__format_args = args_to_list(*format_args)
    for arg in self.__format_args:
      assert isinstance(arg, Expression)
    assert len(self.__format_chunks) == len(self.__format_args) + 1, [self.__format_chunks, self.__format_args]

  def append_to(self, output, level):
    assert len(self.__format_chunks) == len(self.__format_args) + 1, [self.__format_chunks, self.__format_args]
    for (prefix, arg) in zip(self.__format_chunks, self.__format_args):
      output.append(prefix)
      arg.append_to(output, level)
    output.append(self.__format_chunks[-1])

def variable(name:str) -> Variable:
  return Variable(name)

