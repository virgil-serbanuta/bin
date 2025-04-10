class TokenType:
  SPACE = 0
  WORD = 1
  NUMBER = 2
  PUNCTUATION = 3
  COMMENT = 4
  STRING = 5

PUNCTUATION_NO_SLASH_QUOTE_SET = set('[]{}`<~>,.<>?;:\\|=-+!@#$%^&*()')

def is_punctuation_no_slash_quote(c):
  return c in PUNCTUATION_NO_SLASH_QUOTE_SET

def is_letter(c):
  return c.isalpha() or c == '_'

def tokenize_words(input):
  OUT = 0
  WORD = 1
  NUMBER = 2
  SLASH = 3
  COMMENT_ONE_LINE = 4
  COMMENT_MULTILINE = 5
  COMMENT_MULTILINE_STAR = 6
  STRING_DOUBLE = 7
  STRING_DOUBLE_QUOTE = 8
  # STRING_SIMPLE = 9
  # STRING_SIMPLE_QUOTE = 10
  state = OUT
  word=[]
  def word_state_for(c):
    # TODO: Use a map.
    if c.isspace():
      return OUT
    # if c == "'":
    #   return STRING_SIMPLE
    if c == '"':
      return STRING_DOUBLE
    if is_letter(c):
      return WORD
    if c.isdigit():
      return NUMBER
    assert False, [c, ord(c), is_punctuation_no_slash_quote(c)]

  for c in input:
    if state == OUT:
      if c.isspace():
        word.append(c)
        continue
      if word:
        yield (TokenType.SPACE, ''.join(word))
        word = []
      if is_punctuation_no_slash_quote(c):
        yield (TokenType.PUNCTUATION, c)
        continue
      if c == '/':
        state = SLASH
        continue
      word = [c]
      state = word_state_for(c)
      continue
    if state == WORD:
      if is_letter(c):
        word.append(c)
        continue
      assert word
      yield (TokenType.WORD, ''.join(word))
      word = []
      if is_punctuation_no_slash_quote(c):
        state = OUT
        yield (TokenType.PUNCTUATION, c)
        continue
      if c == '/':
        state = SLASH
        continue
      word = [c]
      state = word_state_for(c)
      continue
    if state == NUMBER:
      if c.isdigit():
        word.append(c)
        continue
      yield (TokenType.NUMBER, ''.join(word))
      word = []
      if is_punctuation_no_slash_quote(c):
        yield (TokenType.PUNCTUATION, c)
        state = OUT
        continue
      if c == '/':
        state = SLASH
        continue
      word = [c]
      state = word_state_for(c)
      continue
    if state == SLASH:
      if c == '/':
        word = ['//']
        state = COMMENT_ONE_LINE
        continue
      if c == '*':
        word = ['/*']
        state = COMMENT_MULTILINE
        continue
      yield (TokenType.PUNCTUATION, '/')
      if is_punctuation_no_slash_quote(c):
        yield (TokenType.PUNCTUATION, c)
        state = OUT
        continue
      word = [c]
      state = word_state_for(c)
      continue
    if state == COMMENT_ONE_LINE:
      if c == '\n':
        yield (TokenType.COMMENT, ''.join(word))
        word = [c]
        state = OUT
        continue
      continue
    if state == COMMENT_MULTILINE:
      word.append(c)
      if c == '*':
        state = COMMENT_MULTILINE_STAR
        continue
      continue
    if state == COMMENT_MULTILINE_STAR:
      word.append(c)
      if c == '*':
        continue
      if c == '/':
        yield (TokenType.COMMENT, ''.join(word))
        word = []
        state = OUT
        continue
      state = COMMENT_MULTILINE
      continue
    if state == STRING_DOUBLE:
      word.append(c)
      if c == '"':
        yield (TokenType.STRING, ''.join(word))
        word = []
        state = OUT
        continue
      if c == '\\':
        state = STRING_DOUBLE_QUOTE
        continue
      continue
    if state == STRING_DOUBLE_QUOTE:
      word.append(c)
      state = STRING_DOUBLE
      continue
    # if state == STRING_SIMPLE:
    #   word.append(c)
    #   if c == '"':
    #     yield (TokenType.STRING, ''.join(word))
    #     word = []
    #     state = OUT
    #     continue
    #   if c == '\\':
    #     state = STRING_SIMPLE_QUOTE
    #     continue
    #   continue
    # if state == STRING_SIMPLE_QUOTE:
    #   word.append(c)
    #   state = STRING_SIMPLE_QUOTE
    #   continue
    assert False, [state]

  if state == OUT:
    if word:
      yield (TokenType.SPACE, ''.join(word))
  elif state == WORD:
    assert word
    yield (TokenType.WORD, ''.join(word))
  elif state == NUMBER:
    yield (TokenType.NUMBER, ''.join(word))
  elif state == SLASH:
    assert False, [state]
  elif state == COMMENT_ONE_LINE:
    assert word
    yield (TokenType.COMMENT, ''.join(word))
  elif state == COMMENT_MULTILINE:
    assert False, [state]
  elif state == COMMENT_MULTILINE_STAR:
    assert False, [state]
  elif state == STRING_DOUBLE:
    assert False, [state]
  elif state == STRING_DOUBLE_QUOTE:
    assert False, [state]
  # elif state == STRING_SIMPLE:
  #   assert False, [state]
  # elif state == STRING_SIMPLE_QUOTE:
  #   assert False, [state]
  else:
    assert False, [state]

def serialize(tokens):
  return ''.join([value for (_ttype, value) in tokens])
