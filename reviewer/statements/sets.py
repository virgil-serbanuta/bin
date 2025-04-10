from expression import Expression
from statement import Statement

class Sets(Statement):
  def __init__(self, destination:Expression, value:Expression) -> None:
    assert isinstance(destination, Expression)
    assert isinstance(value, Expression)
    self.__destination = destination
    self.__value = value

  def append_to(self, output, level):
    output.append('sets\n')
    # TODO: Memoize
    output.append('  ' * (level + 1))
    output.append('- ')
    self.__destination.append_to(output, level + 1)
    output.append(' = ')
    self.__value.append_to(output, level + 1)

  def flatten(self) -> list:
    return [self]

  def implied_by(self, statements:list) -> bool:
    return False

  def filter_statements(self, statements) -> bool:
    return self
