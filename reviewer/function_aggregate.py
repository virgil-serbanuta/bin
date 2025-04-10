from expression import Expression
from expressions.applied_function import AppliedFunction
from expressions.indexed import Index
from expression_builder import ExpressionBuilder
from function import Function
from tools import args_to_list

class AggregateFunction(object):
  def __init__(self, index:Index, function:Function):
    self.__index = index
    self.__original_name = function.name()
    output = []
    self.__index.append_to(output, 0)
    self.__function = function.with_name("%s{%s}" % (self.__original_name, ''.join(output)))

  def name(self) -> str:
    return self.__function.name()

  def __getitem__(self, idx:Index):
    return AggregateFunctionBuilder(
          self.__index,
          idx,
          self.__function.with_name(self.__original_name))

  def header(self):
    return self.__function.header()

  def append_header_to(self, output:list, level:int):
    return self.__function.append_header_to(output, level)

  def definitions(self):
    return self.__function.definitions()

  def summary(self):
    return self.__function.summary()

  def append_summary_to(self, output:list, level:int):
    return self.__function.append_summary_to(output, level)

  def details(self):
    return self.__function.details()

  def append_to(self, output, level):
    return self.__function.append_to(output, level)

def aggregate_function(name:str, *, arguments:list = []) -> AggregateFunction:
  idx = Index()
  arguments = [arg.build() for arg in arguments]
  return AggregateFunction(idx, Function(name, arguments, assignments=[], statements=[]))

class AppliedAggregateFunctionBuilder(ExpressionBuilder):
  def __init__(self, index:Index, function:AppliedFunction):
    self.__index = index
    self.__function = function

  def build(self) -> Expression:
      return AppliedAggregateFunction(self.__index, self.__function)

class AggregateFunctionBuilder(ExpressionBuilder):
  def __init__(self, index:Index, new_index:Index, function:Function):
    assert isinstance(function, Function)
    self.__index = index
    self.__new_index = new_index
    output = []
    self.__new_index.append_to(output, 0)
    self.__function = function.with_name("%s{%s}" % (function.name(), ''.join(output)))

  def __call__(self, *args:Expression) -> AppliedAggregateFunctionBuilder:
    for arg in args_to_list(*args):
      assert isinstance(arg, ExpressionBuilder), [type(arg)]
    args = [arg.build() for arg in args]
    return AppliedAggregateFunctionBuilder(
          self.__index,
          self.__function
              .substitute(self.__index, self.__new_index)
                  (*args)
              .build())

class AppliedAggregateFunction(Expression):
  def __init__(self, index:Index, function:AppliedFunction):
    # self.__index = index
    self.__original_name = function.name()
    # output = []
    # self.__index.append_to(output, 0)
    self.__function = function#.with_name("%s{%s}" % (self.__original_name, ''.join(output)))

  def append_to(self, output, level):
    return self.__function.append_to(output, level)
