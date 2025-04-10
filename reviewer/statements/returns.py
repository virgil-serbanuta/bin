from expression import Expression
from statement import Statement

class Returns(Statement):
  pass

class Returns(Statement):
  def __init__(self, expression:Expression) -> None:
    assert isinstance(expression, Expression)
    self.__expression = expression

  def append_to(self, output, level):
    output.append('returns\n')
    # TODO: Memoize
    output.append('  ' * (level + 1))
    output.append('- ')
    self.__expression.append_to(output, level + 1)

  def flatten(self) -> list:
    return [self]

  def implied_by(self, statements:list) -> bool:
    return False

  def filter_statements(self, statements) -> bool:
    return self

  def substitute(self, substitution:dict) -> Returns:
    return Returns(self.__expression.substitute(substitution))
