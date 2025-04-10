from expression import Expression, wrap_constant

class FunctionBinaryOperator(Expression):
  pass

class FunctionBinaryOperator(Expression):
  def __init__(self, operator:str, first:Expression, second:Expression) -> None:
    self.__operator = operator
    self.__first = wrap_constant(first)
    self.__second = wrap_constant(second)

  def exp_equals(self, other):
    if type(other) != FunctionBinaryOperator:
      return False
    if self.__operator != other.__operator:
      return False
    if not self.__first.exp_equals(other.__first):
      return False
    if not self.__second.exp_equals(other.__second):
      return False
    return True

  def append_to(self, output, level):
    self.__first.append_to(output, level)
    output.append(' ')
    output.append(self.__operator)
    output.append(' ')
    self.__second.append_to(output, level)
