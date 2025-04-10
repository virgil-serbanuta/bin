from expression import Expression
from statement import Statement
import statements

class Sends(Statement):
  pass

#TODO: RENAME STATEMENT CLASSES TO END OR NOT IN S.
class Sends(Statement):
  def __init__(self, amount:Expression, destination:Expression) -> None:
    assert isinstance(destination, Expression)
    assert isinstance(amount, Expression)
    self.__destination = destination
    self.__amount = amount

  def append_to(self, output, level):
    output.append('sends\n')
    # TODO: Memoize
    output.append('  ' * (level + 1))
    output.append('- ')
    self.__amount.append_to(output, level + 1)
    output.append(' to ')
    self.__destination.append_to(output, level + 1)

  def flatten(self) -> list:
    return [self]

  def implied_by(self, statements:list) -> bool:
    return False

  def filter_statements(self, statements) -> bool:
    return self

  def substitute(self, substitution:dict) -> Sends:
    return Sends(self.__amount.substitute(substitution), self.__destination.substitute(substitution))
