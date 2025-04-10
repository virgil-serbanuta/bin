// requires "functype-type.k"

module LIST-FUNCTYPE
  imports private INT-SYNTAX
  imports private BASIC-K
  imports FUNCTYPE-TYPE

  syntax FuncType

  syntax ListFuncType [hook(LIST.List)]
  syntax ListFuncType ::= ListFuncType ListFuncType
          [ left, function, total, hook(LIST.concat),
            symbol(_ListFuncType_), smtlib(smt_seq_concat),
            assoc, unit(.ListFuncType), element(ListFuncTypeItem),
            format(%1%n%2)
          ]
  syntax ListFuncType ::= ".ListFuncType"
          [ function, total, hook(LIST.unit), symbol(.ListFuncType),
            smtlib(smt_seq_nil)
          ]
  syntax ListFuncType ::= ListItem(FuncType)
          [ function, total, hook(LIST.element), symbol(ListFuncTypeItem),
            smtlib(smt_seq_elem)
          ]
  syntax FuncType ::= ListFuncType "[" Int "]"
          [ function, hook(LIST.get), symbol(ListFuncType:get) ]
  syntax ListFuncType ::= ListFuncType "[" index: Int "<-" value: FuncType "]"
          [function, hook(LIST.update), symbol(ListFuncType:set)]
  syntax ListFuncType ::= makeListFuncType(length: Int, value: FuncType)
          [function, hook(LIST.make)]
  syntax ListFuncType ::= updateList(dest: ListFuncType, index: Int, src: ListFuncType)
          [function, hook(LIST.updateAll)]
  syntax ListFuncType ::= fillList(ListFuncType, index: Int, length: Int, value: FuncType)
          [function, hook(LIST.fill)]
  syntax ListFuncType ::= range(ListFuncType, fromFront: Int, fromBack: Int)
          [function, hook(LIST.range), symbol(ListFuncType:range)]
  syntax Bool ::= FuncType "in" ListFuncType
          [function, total, hook(LIST.in), symbol(_inListFuncType_)]
  syntax Int ::= size(ListFuncType)
          [function, total, hook(LIST.size), symbol(sizeListFuncType), smtlib(smt_seq_len)]
endmodule

module LIST-FUNCTYPE-PRIMITIVE
  imports BOOL
  imports INT
  imports LIST-FUNCTYPE

  syntax FuncType ::= ListFuncType "[" Int "]" "orDefault" FuncType
          [ function, total, symbol(ListFuncType:getOrDefault) ]

  syntax FuncType ::= ListFuncType "{{" Int "}}"
                 [function, symbol(ListFuncType:primitiveLookup)]
// -----------------------------------------------------------
  rule L:ListFuncType {{ I:Int }} => L[ I ]

  syntax FuncType ::= ListFuncType "{{" Int "}}" "orDefault" FuncType
                 [ function, total, symbol(ListFuncType:primitiveLookupOrDefault) ]
// -----------------------------------------------------------------------------
  rule L:ListFuncType {{ I:Int }} orDefault Value:FuncType
      => L [I] orDefault Value

  rule ListItem(V:FuncType) _:ListFuncType [0] orDefault _:FuncType
      => V
  rule _:ListFuncType ListItem(V:FuncType) [-1] orDefault _:FuncType
      => V
  rule .ListFuncType [_:Int] orDefault D:FuncType => D

  rule ListItem(_:FuncType) L:ListFuncType [I:Int] orDefault D:FuncType
      => L[I -Int 1] orDefault D
    requires 0 <Int I
  rule L:ListFuncType ListItem(_:FuncType) [I:Int] orDefault D:FuncType
      => L[I +Int 1] orDefault D
    requires I <Int 0

  rule L:ListFuncType[I:Int] orDefault D:FuncType => D
    requires notBool (0 -Int size(L) <=Int I andBool I <Int size(L))
    [simplification]

  syntax ListFuncType ::= ListItemWrap( FuncType )
      [function, total, symbol(ListFuncTypeItemWrap)]
  rule ListItemWrap( B:FuncType ) => ListItem(B)


  syntax ListFuncType ::= ListFuncType "{{" Int "<-" FuncType "}}"
                 [function, symbol(ListFuncType:primitiveSet)]
// -----------------------------------------------------------
  rule L:ListFuncType {{ I:Int <- V:FuncType }}
      => L[ I <- V]

  // Workaround for the Haskell backend missing the range hook.
  // See https://github.com/runtimeverification/haskell-backend/issues/3706
  rule range(ListItem(_) L:ListFuncType, FromStart:Int, FromEnd:Int)
      => range(L, FromStart -Int 1, FromEnd)
      requires 0 <Int FromStart
  rule range(L:ListFuncType ListItem(_), 0, FromEnd:Int)
      => range(L, 0, FromEnd -Int 1)
      requires 0 <Int FromEnd
  rule range(L:ListFuncType, 0, 0)
      => L

  syntax Bool ::= rangeDefined(ListFuncType, fromStart:Int, fromEnd:Int)  [function, total]
  rule rangeDefined(L:ListFuncType, FromStart:Int, FromEnd:Int)
      => 0 <=Int FromStart
        andBool 0 <=Int FromEnd
        andBool FromStart +Int FromEnd <=Int size(L)

  rule #Ceil(range(L:ListFuncType, FromStart:Int, FromEnd:Int))
      => {true #Equals rangeDefined(L, FromStart, FromEnd)}
      [simplification]

  syntax ListFuncType ::= rangeTotal(ListFuncType, Int, Int)
      [function, total, symbol(ListFuncType:rangeTotal)]
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
  
  rule rangeTotal(L, Front, Back) => .ListFuncType
    requires 0 <=Int Front
     andBool 0 <=Int Back 
     andBool size(L) <Int Front +Int Back

endmodule
