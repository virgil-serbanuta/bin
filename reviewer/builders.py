from expression import *
from functions import *
from global_vars import *

from expression_builder import ExpressionBuilder, VariableBuilder, function_argument
from function import function

class FunctionCallBuilder(object):
  def __init__(self, name, args):
    for a in args:
      assert isinstance(a, ExpressionBuilder)
    self.__name = name
    self.__args = args
    self.__statements = []
    self.__assignments = []

  def statements(self, *args):
    assert not self.__statements
    self.__statements = args_to_list(*args)
    return self

  def assignments(self, *args):
    assert not self.__assignments
    self.__assignments = args_to_list(*args)
    return self

  def build(self):
    return function(
        self.__name,
        arguments=[a.build() for a in self.__args],
        assignments=self.__assignments,
        statements=self.__statements
    )

class FunctionCallBuilderName(object):
  def __init__(self):
    pass

  def __getattr__(self, name: str):
    global building
    assert building, str(type(self)) + '.' + name
    def wrap_if_needed(arg):
      if isinstance(arg, str):
        return function_argument(arg)
      if isinstance(arg, VariableBuilder):
        return arg
      assert False, [type(arg), arg]
    def build(*args:ExpressionBuilder):
      new_args = [wrap_if_needed(arg) for arg in args_to_list(*args)]
      return FunctionCallBuilder(name, new_args)
    return build

fn = FunctionCallBuilderName()

class EndpointCallBuilder(object):
  def __init__(self, name, args):
    self.__name = name
    self.__args = args
    self.__statements = []
    self.__assignments = []
    self.__only_owner = False
    self.__payable = None

  def statements(self, *args):
    assert not self.__statements
    self.__statements = args_to_list(*args)
    return self

  def assignments(self, *args):
    assert not self.__assignments
    self.__assignments = args_to_list(*args)
    return self

  def only_owner(self):
    self.__only_owner = True
    return self

  def payable(self, p:str):
    self.__payable = p
    return self

  def build(self):
    # def wrap_if_needed(arg):
    #   if isinstance(arg, str):
    #     return function_argument(arg)
    #   if isinstance(arg, VariableBuilder):
    #     return arg
    #   assert False, [type(arg), arg]
    new_args = [arg.build() for arg in args_to_list(*self.__args)]
    return Endpoint(
        only_owner = self.__only_owner,
        payable = self.__payable,
        function = function(
            self.__name,
            arguments=new_args,
            assignments=self.__assignments,
            statements=self.__statements
        )
    )

class EndpointCallBuilderName(object):
  def __init__(self):
    pass

  def __getattr__(self, name: str):
    global building
    assert building, str(type(self)) + '.' + name
    def wrap_if_needed(arg):
      if isinstance(arg, str):
        return function_argument(arg)
      if isinstance(arg, ExpressionBuilder):
        return arg
      assert False, [type(arg), arg]
    def build(*args):
      new_args = [wrap_if_needed(arg) for arg in args_to_list(*args)]
      return EndpointCallBuilder(name, new_args)
    return build

endpoint = EndpointCallBuilderName()

class FunctionWithCallbackCallBuilder(object):
  def __init__(self, name, args):
    self.__name = name
    self.__args = args
    self.__statements = []
    self.__assignments = []

  def statements(self, *args):
    assert not self.__statements
    self.__statements = args_to_list(*args)
    return self

  def assignments(self, *args):
    assert not self.__assignments
    self.__assignments = args_to_list(*args)
    return self

  def build(self):
    return FunctionWithCallback(
        callback = None,
        function = function(
            self.__name,
            arguments=[a.build() for a in self.__args],
            assignments=self.__assignments,
            statements=self.__statements
        )
    )

class FunctionWithCallbackCallBuilderName(object):
  def __init__(self):
    pass

  def __getattr__(self, name: str):
    def wrap_if_needed(arg):
      if isinstance(arg, str):
        return function_argument(arg)
      if isinstance(arg, VariableBuilder):
        return arg
      assert False, [type(arg), arg]
    def build(*args):
      new_args = [wrap_if_needed(arg) for arg in args_to_list(*args)]
      return FunctionWithCallbackCallBuilder(name, new_args)
    return build

fn_with_callback = FunctionWithCallbackCallBuilderName()
