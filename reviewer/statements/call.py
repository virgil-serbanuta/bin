from expressions.applied_function import AppliedFunction
from functions import FunctionWithCallback
from statement import Statement

class Call(Statement):
  def __init__(self, call:AppliedFunction) -> None:
    assert isinstance(call, AppliedFunction) or isinstance(call, FunctionWithCallback), [call]
    super().__init__()
    self.__call = call

  def filter_statements(self, statements):
    call = self.__call.filter_statements(statements)
    return Call(call)

