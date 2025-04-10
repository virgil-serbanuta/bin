from importlib.metadata import requires
import tokenizer.TokenType as TokenType

class ObjectBuilder:
  def __init__(self):
    self._reset()
    pass

  def is_empty(self):
    pass

  def _reset(self):
    pass

  def start(self):
    assert self.is_empty()

  def build(self):
    pass

class SpaceCommentBuilder(ObjectBuilder):
  def __init__(self):
    super().__init__()

  def _reset(self):
    self.__tokens = []

  def is_empty(self):
    return not self.__tokens

  def build(self):
    assert not self.is_empty()
    try:
      return SpaceComment(self.__tokens)
    finally:
      self._reset()

  def add(self, token):
    self.__tokens.append(token)

class RequiresBuilder(ObjectBuilder):
  def __init__(self):
    super().__init__()

  def _reset(self):
    self.__requires_word = ''
    self.__requires_word_space_comment = []
    self.__requires_file = ''
    self.__requires_file_space_comment = []

  def is_empty(self):
    return (
      not self.__requires_word
      and not self.__requires_word_space_comment
      and not self.__requires_file
      and not self.__requires_file_space_comment
    )

  def build(self):
    assert self.__requires_word and self.__requires_file
    try:
      return Requires(
              self.__requires_word, self.__requires_word_space_comment,
              self.__requires_file, self.__requires_file_space_comment
          )
    finally:
      self._reset()

  def set_requires_word(self, requires_word):
    self.__requires_word = requires_word

  def add_requires_word_space_comment(self, token):
    self.__requires_word_space_comment.append(token)

  def set_requires_file(self, file):
    self.__requires_file = file

  def add_requires_file_space_comment(self, token):
    self.__requires_file_space_comment.append(token)

class ModuleBuilder(ObjectBuilder):
  def __init__(self):
    super().__init__()

  def _reset(self):
    self.__module_space = []
    self.__module_name = []
    self.__module_name_space = []
    self.__module_entries = []
    self.__module_end_space = []
    self.__module_attributes = []
    self.__module_attributes_space = []

  def is_empty(self):
    return (
        not self.__module_space
        and not self.__module_name
        and not self.__module_name_space
        and not self.__module_entries
        and not self.__module_end_space
        and not self.__module_attributes
        and not self.__module_attributes_space
    )

  def build(self):
    assert self.__module_name
    try:
      return Module(
              self.__module_space,
              self.__module_name, self.__module_name_space,
              self.__module_entries,
              self.__module_end_space,
              self.__module_attributes, self.__module_attributes_space
          )
    finally:
      self._reset()

  def add_module_space(self, token):
    self.__module_space.add(token)

  def add_module_name(self, token):
    self.__module_name.add(token)

  def add_module_name_space(self, token):
    self.__module_name_space.add(token)

  def add_module_entry(self, entry):
    self.__module_entries.add(entry)

  def add_module_end_space(self, token):
    self.__module_end_space.add(token)

  def add_module_attribute(self, token):
    self.__module_attributes.add(token)

  def add_module_attributes_space(self, token):
    self.__module_attributes_space.add(token)

class RuleBuilder(ObjectBuilder):
  def __init__(self):
    super().__init__()

  def _reset(self):
    self.__rule_space = []
    self.__rule_tag = []
    self.__rule_tag_space = []
    self.__rule_lhs = []
    self.__rule_arrow_space = []
    self.__rule_rhs = []
    self.__rule_requires = []
    self.__rule_ensures = []
    self.__rule_attributes = []
    self.__rule_attributes_space = []

  def is_empty(self):
    return (
        not self.__rule_space
        and not self.__rule_tag
        and not self.__rule_tag_space
        and not self.__rule_lhs
        and not self.__rule_arrow_space
        and not self.__rule_rhs
        and not self.__rule_requires
        and not self.__rule_ensures
        and not self.__rule_attributes
        and not self.__rule_attributes_space
    )

  def build(self):
    assert self.__rule_lhs
    assert self.__rule_rhs
    try:
      return Rule(
              self.__rule_space,
              self.__rule_tag, self.__rule_tag_space,
              self.__rule_lhs, self.__rule_arrow_space, self.__rule_rhs,
              self.__rule_requires, self.__rule_ensures,
              self.__rule_attributes, self.__rule_attributes_space
          )
    finally:
      self._reset()

  def add_rule_space(token):
    self.__rule_space.add(token)

  def add_rule_tag(token):
    self.__rule_tag.add(token)

  def add_rule_tag_space(token):
    self.__rule_tag_space.add(token)

  def add_rule_lhs(token):
    self.__rule_lhs.add(token)

  def add_rule_arrow_space(token):
    self.__rule_arrow_space.add(token)

  def add_rule_rhs(token):
    self.__rule_rhs.add(token)

  def add_rule_requires(token):
    self.__rule_requires.add(token)

  def add_rule_ensures(token):
    self.__rule_ensures.add(token)

  def add_rule_attributes(token):
    self.__rule_attributes.add(token)

  def add_rule_attributes_space(token):
    self.__rule_attributes_space.add(token)


class ImportBuilder(ObjectBuilder):
  def __init__(self):
    super().__init__()

  def _reset(self):
    self.__import_space = []
    self.__import_name = []
    self.__import_name_space = []

  def is_empty(self):
    return (
        not self.__import_space
        and not self.__import_name
        and not self.__import_name_space
    )

  def build(self):
    assert self.__import_name
    try:
      return Import(
              self.__import_space,
              self.__import_name, self.__import_name_space
          )
    finally:
      self._reset()

  def add_import_space(token):
    self.__import_space.add(token)

  def add_import_name(token):
    self.__import_name.add(token)

  def add_import_name_space(token):
    self.__import_name.add(token)


class SyntaxBuilder(ObjectBuilder):
  def __init__(self):
    super().__init__()

  def _reset(self):
    self.__syntax_space = []
    self.__sort = []
    self.__colon_equal_space = []
    self.__definitions = []

  def is_empty(self):
    return (
        not self.__syntax_space
        and not self.__sort
        and not self.__colon_equal_space
        and not self.__definitions
    )

  def build(self):
    assert self.__sort and self.__definitions
    try:
      return Syntax(
              self.__syntax_space,
              self.__sort
              self.__colon_equal_space,
              self.__definitions
          )
    finally:
      self._reset()

  zuma
  def add_import_space(token):
    self.__import_space.add(token)

  def add_import_name(token):
    self.__import_name.add(token)

  def add_import_name_space(token):
    self.__import_name.add(token)


class ImportBuilder(ObjectBuilder):
  def __init__(self):
    super().__init__()

  def _reset(self):
    self.__import_space = []
    self.__import_name = []
    self.__import_name_space = []

  def is_empty(self):
    return (
        not self.__import_space
        and not self.__import_name
        and not self.__import_name_space
    )

  def build(self):
    assert self.__import_name
    try:
      return Import(
              self.__import_space,
              self.__import_name, self.__import_name_space
          )
    finally:
      self._reset()

  def add_import_space(token):
    self.__import_space.add(token)

  def add_import_name(token):
    self.__import_name.add(token)

  def add_import_name_space(token):
    self.__import_name.add(token)

def outerParseK(tokens):
  ( OUT, REQUIRES, REQUIRES_FILE, MODULE, MODULE_NAME, MODULE_NAME_SPACE
  , MODULE_AFTER, MODULE_ATTRIBUTES_AFTER
  , IMPORT, IMPORT_NAME, IMPORT_SPACE
  , RULE, RULE_EQ, RULE_RHS, RULE_REQUIRES, RULE_SPACE
  , SYNTAX, SYNTAX_SORT, SYNTAX_COLON, SYNTAX_COLON_COLON, SYNTAX_RHS
  , CONFIGURATION, ATTRIBUTES
  ) = tuple(range(0, 18))
  state = OUT
  space_comment_builder = SpaceCommentBuilder()
  requires_builder = RequiresBuilder()
  module_builder = ModuleBuilder()
  import_builder = ImportBuilder()

  def processTopLevelToken(token_type, token):
    if token_type == TokenType.WORD:
      if token == 'require' or token == 'requires':
        requires_builder.start()
        requires_builder.set_requires_word(token)
        return REQUIRES
      if token == 'module':
        module_builder.start()
        return MODULE
    assert False, [state, token_type, token]

  space_comment_builder.start()
  for (token_type, token) in tokens:
    if state == OUT:
      if token_type == TokenType.SPACE or token_type == TokenType.COMMENT:
        space_comment_builder.add((token_type, token))
        continue
      if space_comment_builder.has_tokens():
        yield space_comment_builder.build()
      state = processTopLevelToken(token_type, token)
    if state == REQUIRES:
      if token_type == TokenType.SPACE or token_type == TokenType.COMMENT:
        requires_builder.add_requires_word_space_comment((token_type, token))
        continue
      if token_type == TokenType.STRING:
        requires_builder.set_requires_file(token)
        state = REQUIRES_FILE
        continue
      assert False, [state, token_type, token]
    if state == REQUIRES_FILE:
      if token_type == TokenType.SPACE or token_type == TokenType.COMMENT:
        requires_builder.add_requires_file_space_comment((token_type, token))
        continue
      yield requires_builder.build()
      state = processTopLevelToken(token_type, token)
    if state == MODULE:
      if token_type == TokenType.SPACE or token_type == TokenType.COMMENT:
        module_space.append((token_type, token))
        continue
      if token_type == TokenType.WORD:
        module_name.append((token_type, token))
        state = MODULE_NAME
        continue
      if token_type == TokenType.PUNCTUATION:
        if token == '-':
          module_name.append((token_type, token))
          state = MODULE_NAME
          continue
      assert False, [state, token_type, token]
    if state == MODULE_NAME:
      if token_type == TokenType.SPACE or token_type == TokenType.COMMENT:
        module_name_space.append((token_type, token))
        state = MODULE_NAME_SPACE
        continue
      if token_type == TokenType.WORD:
        module_name.append((token_type, token))
        continue
      if token_type == TokenType.PUNCTUATION:
        if token == '-':
          module_name.append((token_type, token))
          continue
      assert False, [state, token_type, token]
    if state == MODULE_NAME_SPACE:
      if token_type == TokenType.SPACE or token_type == TokenType.COMMENT:
        module_name_space.append((token_type, token))
        continue
      if token_type == TokenType.WORD:
        if token == 'import':
          import_builder.start()
          state = IMPORT
          continue
        if token == 'rule':
          state = RULE
          continue
        if token == 'syntax':
          state = SYNTAX
          continue
        if token == 'configuration':
          state = CONFIGURATION
          continue
        if token == 'endmodule':
          state = MODULE_AFTER
          continue
      assert False, [state, token_type, token]
    if state == MODULE_AFTER:
      if token_type == TokenType.SPACE or token_type == TokenType.COMMENT:
        module_end_space.append((token_type, token))
        continue
      if token_type == TokenType.PUNCTUATION:
        if token == '[':
          state = ATTRIBUTES
          open_square_bracket = 0
          attributes_return_state = MODULE_ATTRIBUTES_AFTER
          attributes_update = lambda t: module_attributes.append(t)
          continue
      assert False, [state, token_type, token]
    if state == IMPORT:
      if token_type == TokenType.SPACE or token_type == TokenType.COMMENT:
        import_space.append((token_type, token))
        continue
      if token_type == TokenType.WORD:
        import_name.append((token_type, token))
        state = IMPORT_NAME
        continue
      if token_type == TokenType.PUNCTUATION:
        if token == '-':
          module_name.append((token_type, token))
          state = IMPORT_NAME
          continue
      assert False, [state, token_type, token]
    if state == IMPORT_NAME:
      if token_type == TokenType.SPACE or token_type == TokenType.COMMENT:
        import_name_space.append((token_type, token))
        state = IMPORT_SPACE
        continue
      if token_type == TokenType.WORD:
        import_name.append((token_type, token))
        continue
      if token_type == TokenType.PUNCTUATION:
        if token == '-':
          module_name.append((token_type, token))
          continue
      assert False, [state, token_type, token]
