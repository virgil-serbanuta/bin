from expression import Expression, FieldAccess
from expression_builder import ExpressionBuilder
from expression_builders.method_call import MethodCallBuilder
import registry

class FieldAccessBuilder(ExpressionBuilder):
  def __init__(self, *, expression:Expression, field_name:str):
    super().__init__()
    assert isinstance(expression, Expression), [expression]

    self.__field_name = field_name
    self.__expression = expression

  def build(self) -> Expression:
    return FieldAccess(self.__expression, self.__field_name)

  def __call__(self, *args:Expression) -> MethodCallBuilder:
    return MethodCallBuilder(self.__expression, registry.method_registry.find(self.__expression, self.__field_name), *args)

