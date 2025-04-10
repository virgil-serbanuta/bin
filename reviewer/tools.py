def args_to_list(*args, expected_len = -1, function_name = ''):
  if expected_len >= 0:
    assert len(args) == expected_len, [function_name, expected_len, args]
  if len(args) > 0:
    assert not isinstance(args[0], tuple)
  return list(args)

def merge_dicts(first, second):
  return {**first, **second}
