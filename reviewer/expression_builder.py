from expression import Expression, NamedValue, Variable, wrap_constant
import expression_builders.builder_factory as builder_factory
from expressions.function_binary_operator import FunctionBinaryOperator
from expressions.indexed import Index, Indexed

_greater = None
_less = None
_greater_equal = None
_less_equal = None
_equals = None
_not_equals = None
_plus = None
_minus = None
_mul = None
_div = None
_mod = None
_index_with = None

def build_wrap(arg):
  if isinstance(arg, ExpressionBuilder):
    return arg.build()
  return wrap_constant(arg)

class ExpressionBuilder(object):
  pass

class FieldAccessBuilder(object):
  pass

class ExpressionBuilder(object):
  def __init__(self):
    pass

  def build(self) -> Expression:
    assert False, ['Unimplemented', type(self), '.build()']

  def __getattr__(self, name: str) -> ExpressionBuilder:
    return builder_factory.builder_factory.field_access_builder(expression=self.build(), field_name=name)

  def __gt__(self, other):
    return _greater(self.build(), build_wrap(other))

  def __lt__(self, other):
    return _less(self.build(), build_wrap(other))

  def __ge__(self, other):
    return _greater_equal(self.build(), build_wrap(other))

  def __le__(self, other):
    return _less_equal(self.build(), build_wrap(other))

  def __eq__(self, other):
    return _equals(self.build(), build_wrap(other)).build()

  def __ne__(self, other):
    return _not_equals(self.build(), build_wrap(other))

  def __add__(self, other):
    return _plus(self.build(), build_wrap(other))

  def __sub__(self, other):
    return _minus(self.build(), build_wrap(other))

  def __mul__(self, other):
    return _mul(self.build(), build_wrap(other))

  def __truediv__(self, other):
    return _div(self.build(), build_wrap(other))

  def __mod__(self, other):
    return _mod(self.build(), build_wrap(other))

  def __getitem__(self, idx):
    return _index_with(self.build(), idx)

class FunctionBinaryOperatorBuilder(ExpressionBuilder):
  def __init__(self, operator:str, first:Expression, second:Expression):
    super().__init__()
    self.__operator = operator
    self.__first = first
    self.__second = second

  def build(self) -> Expression:
    return FunctionBinaryOperator(self.__operator, self.__first, self.__second)

class FunctionBinaryOperatorCallBuilder(object):
  def __init__(self, operator:str):
    self.__operator = operator

  def __call__(self, first:Expression, second:Expression) -> FunctionBinaryOperatorBuilder:
    return FunctionBinaryOperatorBuilder(self.__operator, first, second)

class VariableBuilder(ExpressionBuilder):
  def __init__(self, name):
    self.__name = name

  def build(self) -> Expression:
      return Variable(self.__name)

class IndexedBuilder(ExpressionBuilder):
  def __init__(self, expression:Expression, var:Index) -> None:
    super().__init__()
    self.__expression = expression
    self.__var = var

  def build(self):
    return Indexed(self.__expression, self.__var)

class NamedConstantBuilder(object):
  def __init__(self) -> None:
    pass

  def __getattr__(self, name: str):
    def build(value) -> Expression:
      return NamedValue(wrap_constant(value), [name])
    return build

def function_argument(name:str) -> VariableBuilder:
  return VariableBuilder(name)

_greater = FunctionBinaryOperatorCallBuilder('>')
_less = FunctionBinaryOperatorCallBuilder('<')
_greater_equal = FunctionBinaryOperatorCallBuilder('>=')
_less_equal = FunctionBinaryOperatorCallBuilder('<=')
_equals = FunctionBinaryOperatorCallBuilder('==')
_not_equals = FunctionBinaryOperatorCallBuilder('!=')
_plus = FunctionBinaryOperatorCallBuilder('+')
_minus = FunctionBinaryOperatorCallBuilder('-')
_mul = FunctionBinaryOperatorCallBuilder('*')
_div = FunctionBinaryOperatorCallBuilder('/')
_mod = FunctionBinaryOperatorCallBuilder('%')

def _index_with(expression, var) -> IndexedBuilder:
  return IndexedBuilder(expression, var)

