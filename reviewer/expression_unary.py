from expression import Expression

class FunctionUnaryOperator(Expression):
  pass

class FunctionUnaryOperator(Expression):
  def __init__(self, operator:str, expression:Expression) -> None:
    assert isinstance(expression, Expression)
    self.__operator = operator
    self.__expression = expression

  def exp_equals(self, other):
    if type(other) != FunctionUnaryOperator:
      return False
    if self.__operator != other.__operator:
      return False
    if not self.__expression.exp_equals(other.__expression):
      return False
    return True

  def append_to(self, output, level):
    output.append(self.__operator)
    output.append(' ')
    self.__expression.append_to(output, level)

def not_operator(expression:Expression):
  return FunctionUnaryOperator('not', expression)