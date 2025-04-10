from expression import Expression, Value
from expressions.applied_function import AppliedFunction

class MethodCall(Expression):
  def __init__(self, obj:Value, method:AppliedFunction):
    assert isinstance(method, AppliedFunction), [method]
    self.__obj = obj
    self.__method = method

  def append_to(self, output, level):
    self.__obj.append_to(output, level)
    output.append('.')
    self.__method.append_header_to(output, level)
    self.__method.append_summary_to(output, level + 1)
  
  def substitute(self, substitution:dict) -> Expression:
    obj = self.__obj.substitute(substitution)
    method = self.__method.substitute(substitution)
    return MethodCall(obj, method)
