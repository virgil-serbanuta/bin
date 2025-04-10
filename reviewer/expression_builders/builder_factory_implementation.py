from expression import Expression
from expression_builders.field_acces import FieldAccessBuilder
import expression_builders.builder_factory as builder_factory

class BuilderFactoryImplementation(object):
  def __init__(self) -> None:
    pass

  def field_access_builder(self, *, expression:Expression, field_name:str):
    return FieldAccessBuilder(expression = expression, field_name = field_name)

builder_factory.builder_factory = BuilderFactoryImplementation()

def init():
  pass