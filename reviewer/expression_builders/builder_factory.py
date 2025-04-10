from expression import Expression

class BuilderFactoryInterface(object):
  def __init__(self) -> None:
    pass

  def field_access_builder(self, *, expression:Expression, field_name:str):
    raise Exception('BuilderFactoryInterface not initialized!')

global builder_factory
builder_factory = BuilderFactoryInterface()
