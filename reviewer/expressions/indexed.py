from expression import Expression

class Index:
  pass

class Indexed(Expression):
  def __init__(self, expression:Expression, var:Index) -> None:
    self.__expression = expression
    self.__var = var

  def append_to(self, output, level):
    self.__expression.append_to(output, level)
    output.append('[')
    self.__var.append_to(output, level)
    output.append(']')

class Index(object):
  last_id = 0
  def __init__(self):
    self.__id = Index.last_id
    Index.last_id += 1

  def append_to(self, output, _level):
    output.append('..')
    output.append(str(self.__id))

