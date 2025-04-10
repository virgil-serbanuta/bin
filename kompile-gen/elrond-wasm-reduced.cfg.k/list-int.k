requires "int-type.k"

module LIST-INT
  imports private INT-SYNTAX
  imports private BASIC-K
  imports INT-TYPE

  syntax Int

  syntax ListInt [hook(LIST.List)]
  syntax ListInt ::= ListInt ListInt
          [ left, function, total, hook(LIST.concat),
            symbol(_ListInt_), smtlib(smt_seq_concat),
            assoc, unit(.ListInt), element(ListIntItem),
            format(%1%n%2)
          ]
  syntax ListInt ::= ".ListInt"
          [ function, total, hook(LIST.unit), symbol(.ListInt),
            smtlib(smt_seq_nil)
          ]
  syntax ListInt ::= ListItem(WrappedInt)
          [ function, total, hook(LIST.element), symbol(ListIntItem),
            smtlib(smt_seq_elem)
          ]
  syntax WrappedInt ::= ListInt "[" Int "]"
          [ function, hook(LIST.get), symbol(ListInt:get) ]
  syntax ListInt ::= ListInt "[" index: Int "<-" value: WrappedInt "]"
          [function, hook(LIST.update), symbol(ListInt:set)]
  syntax ListInt ::= makeListInt(length: Int, value: WrappedInt)
          [function, hook(LIST.make)]
  syntax ListInt ::= updateList(dest: ListInt, index: Int, src: ListInt)
          [function, hook(LIST.updateAll)]
  syntax ListInt ::= fillList(ListInt, index: Int, length: Int, value: WrappedInt)
          [function, hook(LIST.fill)]
  syntax ListInt ::= range(ListInt, fromFront: Int, fromBack: Int)
          [function, hook(LIST.range), symbol(ListInt:range)]
  syntax Bool ::= WrappedInt "in" ListInt
          [function, total, hook(LIST.in), symbol(_inListInt_)]
  syntax Int ::= size(ListInt)
          [function, total, hook(LIST.size), symbol(sizeListInt), smtlib(smt_seq_len)]
endmodule

module LIST-INT-PRIMITIVE
  imports BOOL
  imports INT
  imports LIST-INT

  syntax WrappedInt ::= ListInt "[" Int "]" "orDefault" WrappedInt
          [ function, total, symbol(ListInt:getOrDefault) ]

  syntax Int ::= ListInt "{{" Int "}}"
                 [function, symbol(ListInt:primitiveLookup)]
// -----------------------------------------------------------
  rule L:ListInt {{ I:Int }} => unwrap( L[ I ] )

  syntax Int ::= ListInt "{{" Int "}}" "orDefault" Int
                 [ function, total, symbol(ListInt:primitiveLookupOrDefault) ]
// -----------------------------------------------------------------------------
  rule L:ListInt {{ I:Int }} orDefault Value:Int
      => unwrap( L [I] orDefault wrap(Value) )

  rule ListItem(V:WrappedInt) _:ListInt [0] orDefault _:WrappedInt
      => V
  rule _:ListInt ListItem(V:WrappedInt) [-1] orDefault _:WrappedInt
      => V
  rule .ListInt [_:Int] orDefault D:WrappedInt => D

  rule ListItem(_:WrappedInt) L:ListInt [I:Int] orDefault D:WrappedInt
      => L[I -Int 1] orDefault D
    requires 0 <Int I
  rule L:ListInt ListItem(_:WrappedInt) [I:Int] orDefault D:WrappedInt
      => L[I +Int 1] orDefault D
    requires I <Int 0

  rule L:ListInt[I:Int] orDefault D:WrappedInt => D
    requires notBool (0 -Int size(L) <=Int I andBool I <Int size(L))
    [simplification]

  syntax ListInt ::= ListItemWrap( Int )
      [function, total, symbol(ListIntItemWrap)]
  rule ListItemWrap( B:Int ) => ListItem(wrap(B))


  syntax ListInt ::= ListInt "{{" Int "<-" Int "}}"
                 [function, symbol(ListInt:primitiveSet)]
// -----------------------------------------------------------
  rule L:ListInt {{ I:Int <- V:Int }}
      => L[ I <- wrap(V)]

  // Workaround for the Haskell backend missing the range hook.
  // See https://github.com/runtimeverification/haskell-backend/issues/3706
  rule range(ListItem(_) L:ListInt, FromStart:Int, FromEnd:Int)
      => range(L, FromStart -Int 1, FromEnd)
      requires 0 <Int FromStart
  rule range(L:ListInt ListItem(_), 0, FromEnd:Int)
      => range(L, 0, FromEnd -Int 1)
      requires 0 <Int FromEnd
  rule range(L:ListInt, 0, 0)
      => L

  syntax Bool ::= rangeDefined(ListInt, fromStart:Int, fromEnd:Int)  [function, total]
  rule rangeDefined(L:ListInt, FromStart:Int, FromEnd:Int)
      => 0 <=Int FromStart
        andBool 0 <=Int FromEnd
        andBool FromStart +Int FromEnd <=Int size(L)

  rule #Ceil(range(L:ListInt, FromStart:Int, FromEnd:Int))
      => {true #Equals rangeDefined(L, FromStart, FromEnd)}
      [simplification]

  syntax ListInt ::= rangeTotal(ListInt, Int, Int)
      [function, total, symbol(ListInt:rangeTotal)]
// ----------------------------------------------------------
  rule rangeTotal(L, Front, Back) => range(L, Front, Back)
    requires 0 <=Int Front
     andBool 0 <=Int Back 
     andBool size(L) >=Int Front +Int Back

  rule rangeTotal(L, Front, Back) => rangeTotal(L, 0, Back)
    requires Front <Int 0
  
  rule rangeTotal(L, Front, Back) => rangeTotal(L, Front, 0)
    requires 0 <=Int Front
     andBool Back <Int 0
  
  rule rangeTotal(L, Front, Back) => .ListInt
    requires 0 <=Int Front
     andBool 0 <=Int Back 
     andBool size(L) <Int Front +Int Back

endmodule
