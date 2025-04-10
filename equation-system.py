#!/usr/bin/python3

import sys

def parse(eq):
  parsed = [0 for c in range(ord('a'), ord('z')+1)]
  for c in eq:
    if c.islower():
      parsed[ord(c)-ord('a')] = 1
    else:
      assert c.isupper()
      parsed[ord(c)-ord('A')] = -1
  return parsed

def tostr(eq):
  out = []
  for (q, idx) in zip(eq, range(0, 1000)):
    if q < 0:
      if q != -1:
        out.append(str(-q))
      out.append(chr(idx+ord('A')))
    elif q > 0:
      if q != 1:
        out.append(str(q))
      out.append(chr(idx+ord('a')))
  return ''.join(out)

def extract(var, eq):
  assert var.islower()
  idx = ord(var)-ord('a')
  if eq[idx] < 0:
    return eq
  return [-q for q in eq]

def add(eq1, eq2):
  return [a-b for (a, b) in zip(eq1, eq2)]

def replace_if_needed(source, replacement, var):
  assert var.islower()
  idx = ord(var)-ord('a')
  assert replacement[idx], [var, ord(var)-ord('a'), replacement[idx], tostr(replacement), replacement]
  if source[idx] == 0:
    return source
  assert source[idx] % replacement[idx] == 0
  multiplier = source[idx] // replacement[idx]
  return [s-r*multiplier for (s, r) in zip(source, replacement)]

def extract_and_replace(idx, var, eqs, solution):
  replacement = extract(var, eqs[idx])
  solution.append((replacement, var))
  return  [ replace_if_needed(eq, replacement, var)
            for (eq, ix) in zip(eqs, range(0, len(eqs)))
            if ix != idx
          ]

def printeq(eqs):
  for (eq, idx) in zip(eqs, range(0, len(eqs))):
    print(idx, tostr(eq))

def replace_solution(solution, idx):
  (sol, var) = solution[idx]
  replacement = extract(var, sol)
  return  [ (replace_if_needed(eq, replacement, var) if ix < idx else eq, v)
            for ((eq, v), ix) in zip(solution, range(0, len(solution)))
          ]

def printsol(solution):
  for ((eq, var), idx) in zip(solution, range(0, len(solution))):
    print(idx, var, tostr(eq))

def assign(pairs):
  a = [0 for c in range(ord('a'), ord('z')+1)]
  for (var, value) in pairs:
    assert var.islower()
    a[ord(var)-ord('a')] = value
  return a

def solve(solution, assingnment):
  s = []
  for i in range(0, len(assingnment)):
    if assingnment[i]:
      s.append((chr(i + ord('a')), assingnment[i]))
  for (eq, var) in solution:
    idx = ord(var)-ord('a')
    assert eq[idx] == -1
    assert assingnment[idx] == 0
    value = sum([a * b for (a, b) in zip(eq, assingnment)])
    s.append((var, value))
    assingnment[idx] = value
  return s

def validate(result):
  existing = set()
  for (var, value) in result:
    if var == 'z':
      continue
    if value < 1:
      return False
    if value > 19:
      return False
    if value in existing:
      return False
    existing.add(value)
  return True

def in_range(value):
  return value >= 1 and value <= 19

def main(argv):
  equations = [ 'abcZ', 'defgZ', 'hijklZ', 'mnopZ', 'qrsZ'
              , 'adhZ', 'beimZ', 'cfjnqZ', 'gkorZ', 'lpsZ'
              , 'cglZ', 'bfkpZ', 'aejosZ', 'dinrZ', 'hmqZ'
              ]
  solution = []
  parsed = [parse(eq) for eq in equations]
  parsed=extract_and_replace(0, 'a', parsed, solution) #
  parsed=extract_and_replace(4, 'b', parsed, solution)
  parsed=extract_and_replace(10, 'e', parsed, solution)
  parsed=extract_and_replace(5, 'f', parsed, solution) #
  parsed=extract_and_replace(0, 'g', parsed, solution)
  parsed=extract_and_replace(7, 'j', parsed, solution)
  parsed=extract_and_replace(7, 'd', parsed, solution) #
  parsed=extract_and_replace(0, 'l', parsed, solution)
  parsed=extract_and_replace(2, 'm', parsed, solution)
  parsed=extract_and_replace(1, 'r', parsed, solution) #
  parsed=extract_and_replace(4, 'c', parsed, solution)
  ### Same eq
  parsed = parsed[1:]
  ### Negated eq
  parsed = parsed[1:]
  ### Multiplied by 2
  parsed = parsed[1:]
  printeq(parsed)
  print('-'*80)
  solution.append((parsed[0], 'h'))
  printsol(solution)
  print('-'*80)
  for i in range(0, len(solution)):
    solution = replace_solution(solution, len(solution) - i - 1)
  printsol(solution)

  z = 38
  for i in range(1, 20):
    print('i', i)
    for k in range(1, 20):
      if k == i:
        continue
      print('k', k)
      for n in range(1, 20):
        if n in [i, k]:
          continue
        for o in range(1, 20):
          if o in [i, k, n]:
            continue
          for p in range(1, 20):
            if not in_range(z-n-o-p):
              continue
            if p in [i, k, n, o]:
              continue
            for q in range(1, 20):
              if q in [i, k, n, o, p]:
                continue
              for s in range(1, 20):
                if s in [i, k, n, o, p, q]:
                  continue
                if not in_range(z-p-s):
                  continue
                if not in_range(z-q-s):
                  continue
                if not in_range(z+i-o-p-s):
                  continue
                if not in_range(s+q-i-k):
                  continue
                if not in_range(k+n+o+p-q-s):
                  continue
                if not in_range(z+i-p-q-s):
                  continue
                if not in_range(q+s-k-o):
                  continue
                if not in_range(q+s-i-k-n-o):
                  continue
                if not in_range(q+s-i-n):
                  continue
                if not in_range(k+o+p-q):
                  continue
                if not in_range(n+o+p-q):
                  continue
                assignment = assign(
                    [ ('i', i), ('k', k), ('n', n), ('o', o)
                    , ('p', p), ('q', q), ('s', s), ('z', z)
                    ]
                )
                result = solve(solution, assignment)
                # print(result)
                # assert False
                if validate(result):
                  print(result)

if __name__ == '__main__':
  main(sys.argv[1:])
