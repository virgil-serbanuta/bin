from expression import Expression
from expression_builder import ExpressionBuilder
from expressions.method_call import MethodCall
from function import Function

class MethodCallBuilder(ExpressionBuilder):
  def __init__(self, obj:Expression, method:Function, *args:Expression):
    assert isinstance(method, Function), [method]
    super().__init__()
    self.__obj = obj
    self.__method = method
    self.__args = args

  def build(self) -> Expression:
    return MethodCall(self.__obj, self.__method(self.__obj, *self.__args).build())
