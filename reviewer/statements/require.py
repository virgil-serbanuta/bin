from expression import Expression
from statement import Statement

class Require(Statement):
  def __init__(self, condition:Expression) -> None:
    assert isinstance(condition, Expression)
    self.__condition = condition

  def append_to(self, output, level):
    output.append('requires\n')
    # TODO: Memoize
    output.append('  ' * (level + 1))
    output.append('- ')
    self.__condition.append_to(output, level + 1)

  def flatten(self) -> list:
    return [self]

  def implied_by(self, statements:list) -> bool:
    for s in statements:
      if self.__same_require(s):
        return True
    return False

  def __same_require(self, other):
    if not isinstance(other, Require):
      return False
    return self.__condition.exp_equals(other.__condition)

  def condition(self):
    return self.__condition

  def filter_statements(self, statements) -> bool:
    return self
