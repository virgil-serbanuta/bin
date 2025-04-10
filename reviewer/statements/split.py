from expression import Expression
from expression_unary import not_operator
from statement import Statement
from statements.empty_statement import EmptyStatement
from statements.require import Require

class Split(Statement):
  def __init__(self, condition:Expression, true_statements, false_statements) -> None:
    assert isinstance(condition, Expression)
    self.__condition = condition
    if isinstance(true_statements, Statement):
      self.__true_statements = [true_statements]
    else:
      assert isinstance(true_statements, list)
      self.__true_statements = true_statements
    if isinstance(false_statements, Statement):
      self.__false_statements = [false_statements]
    else:
      assert isinstance(false_statements, list)
      self.__false_statements = false_statements

  def append_to(self, output, level):
    output.append('if ')
    self.__condition.append_to(output, level + 2)
    assert self.__true_statements
    # TODO: Memoize
    start = ''.join(['\n', '  ' * (level + 1), '- '])
    for statement in self.__true_statements:
      output.append(start)
      statement.append_to(output, level + 1)
    if self.__false_statements:
      output.append('\n')
      output.append('  ' * level)
      output.append('- else')
      for statement in self.__false_statements:
        output.append(start)
        statement.append_to(output, level + 1)

  def flatten(self) -> list:
    true_flatten = [s.flatten() for s in self.__true_statements]
    false_flatten = [s.flatten() for s in self.__false_statements]

    true_flatten = [s for l in true_flatten for s in l]
    false_flatten = [s for l in false_flatten for s in l]

    return [Split(self.__condition, true_flatten, false_flatten)]

  def implied_by(self, statements:list) -> bool:
    return False

  def filter_statements(self, statements) -> bool:
    true_filter = statements + [Require(self.__condition)]
    true_filtered = [s.filter_statements(true_filter) for s in self.__true_statements]
    false_filter = statements + [Require(not_operator(self.__condition))]
    false_filtered = [s.filter_statements(false_filter) for s in self.__false_statements]
    if not (true_filtered or false_filtered):
      return EmptyStatement()
    return Split(self.__condition, true_filtered, false_filtered)
