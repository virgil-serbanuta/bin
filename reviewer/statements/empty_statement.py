from statement import Statement

class EmptyStatement(Statement):
  def __init__(self) -> None:
    pass

  def append_to(self, output, level):
    output.append('empty')

  def flatten(self) -> list:
    return [self]

  def implied_by(self, statements:list) -> bool:
    return True

  def filter_statements(self, statements) -> bool:
    return self

