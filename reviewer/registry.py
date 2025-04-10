class Registry(object):
  def __init__(self):
    self.__objects = {}

  def find(self, obj, key):
    assert (obj.type_(), key) in self.__objects, (obj.type_(), key)
    return self.__objects[(obj.type_(), key)]

  def register(self, type_, registree):
    key = registree.name()
    assert (type_, key) not in self.__objects, (type_, key)
    self.__objects[(type_, key)] = registree

method_registry = Registry()

