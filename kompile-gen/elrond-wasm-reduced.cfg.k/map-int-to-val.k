
requires "int-type.k"
// requires "val-type.k"
requires "list-int.k"

module MAP-INT-TO-VAL
  imports private BOOL-SYNTAX
  imports private INT-SYNTAX
  imports private LIST-INT
  // imports private LIST-VAL
  imports private LIST
  // imports private SET-INT
  imports private SET
  imports INT-TYPE
  // imports VAL-TYPE

  syntax Int
  syntax Val

  syntax MapIntToVal [hook(MAP.Map)]
  syntax MapIntToVal ::= MapIntToVal MapIntToVal
         [ left, function, hook(MAP.concat), symbol(_MapIntToVal_),
           assoc, comm, unit(.MapIntToVal), element(_Int2Val|->_),
           index(0), format(%1%n%2)
         ]
  syntax MapIntToVal ::= ".MapIntToVal"
         [ function, total, hook(MAP.unit),
           symbol(.MapIntToVal)
         ]
  syntax MapIntToVal ::= WrappedInt "Int2Val|->" Val
         [ function, total, hook(MAP.element),
           symbol(_Int2Val|->_),
           injective
         ]

  syntax priority _Int2Val|->_ > _MapIntToVal_ .MapIntToVal
  syntax non-assoc _Int2Val|->_
  syntax Val ::= MapIntToVal "[" WrappedInt "]"
                 [function, hook(MAP.lookup), symbol(MapIntToVal:lookup)]
  syntax Val ::= MapIntToVal "[" WrappedInt "]" "orDefault" Val
                 [ function, total, hook(MAP.lookupOrDefault),
                   symbol(MapIntToVal:lookupOrDefault)
                 ]
  syntax MapIntToVal ::= MapIntToVal "[" key: WrappedInt "<-" value: Val "]"
                 [ function, total, symbol(MapIntToVal:update),
                   hook(MAP.update), prefer
                 ]
  syntax MapIntToVal ::= MapIntToVal "[" WrappedInt "<-" "undef" "]"
                 [ function, total, hook(MAP.remove),
                   symbol(_MapIntToVal[_<-undef])
                 ]
  syntax MapIntToVal ::= MapIntToVal "-Map" MapIntToVal
                 [ function, total, hook(MAP.difference) ]
  syntax MapIntToVal ::= updateMap(MapIntToVal, MapIntToVal)
                 [function, total, hook(MAP.updateAll)]

  syntax MapIntToVal ::= removeAll(MapIntToVal, Set)
                 [function, total, hook(MAP.removeAll)]
  // syntax MapIntToVal ::= removeAll(MapIntToVal, SetInt)
  //                [function, total, hook(MAP.removeAll)]

  syntax Set ::= keys(MapIntToVal)
                 [function, total, hook(MAP.keys)]
  // syntax SetInt ::= keys(MapIntToVal)
  //                [function, total, hook(MAP.keys)]

  // syntax List ::= "keys_list" "(" MapIntToVal ")"
  //                [function, hook(MAP.keys_list)]
  syntax ListInt ::= "keys_list" "(" MapIntToVal ")"
                 [function, hook(MAP.keys_list)]

  syntax Bool ::= WrappedInt "in_keys" "(" MapIntToVal ")"
                 [function, total, hook(MAP.in_keys)]

  syntax List ::= values(MapIntToVal)
                 [function, hook(MAP.values)]
  // syntax ListVal ::= values(MapIntToVal)
  //                [function, hook(MAP.values)]

  syntax Int ::= size(MapIntToVal)
                 [function, total, hook(MAP.size), symbol(MapIntToVal.sizeMap)]
  syntax Bool ::= MapIntToVal "<=Map" MapIntToVal
                 [function, total, hook(MAP.inclusion)]
  syntax WrappedInt ::= choice(MapIntToVal)
                 [function, hook(MAP.choice), symbol(MapIntToVal:choice)]
endmodule

module MAP-INT-TO-VAL-PRIMITIVE
  imports public  BOOL
  imports private K-EQUAL
  imports public  MAP-INT-TO-VAL

  syntax Val ::= MapIntToVal "{{" Int "}}"
                 [function, symbol(MapIntToVal:primitiveLookup)]
  syntax Val ::= MapIntToVal "{{" Int "}}" "orDefault" Val
                 [ function, total, symbol(MapIntToVal:primitiveLookupOrDefault) ]
  syntax MapIntToVal ::= MapIntToVal "{{" key: Int "<-" value: Val "}}"
                 [ function, total, symbol(MapIntToVal:primitiveUpdate),
                   prefer
                 ]
  syntax MapIntToVal ::= MapIntToVal "{{" Int "<-" "undef" "}}"
                 [ function, total, symbol(MapIntToVal:primitiveRemove) ]
  syntax Bool ::= Int "in_keys" "{{" MapIntToVal "}}"
                 [function, total, symbol(MapIntToVal:primitiveInKeys)]

  rule (M:MapIntToVal {{ Key:Int }})
      => (M[wrap(Key)])
  rule M:MapIntToVal {{ Key:Int }} orDefault Value:Val
      => M[wrap(Key)] orDefault Value
  rule M:MapIntToVal {{ Key:Int <- Value:Val }}
      => M[wrap(Key) <- Value]
  rule M:MapIntToVal {{ Key:Int <- undef }}
      => M[wrap(Key) <- undef]
  rule Key:Int in_keys {{ M:MapIntToVal }} => wrap(Key) in_keys(M)
endmodule

module MAP-INT-TO-VAL-SYMBOLIC
  imports MAP-INT-TO-VAL-KORE-SYMBOLIC
endmodule

module MAP-INT-TO-VAL-KORE-SYMBOLIC  [symbolic]
  imports MAP-INT-TO-VAL
  imports private K-EQUAL
  imports private BOOL

  rule #Ceil(@M:MapIntToVal [@K:WrappedInt])
      => {(@K in_keys(@M)) #Equals true}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule (K Int2Val|-> _ M:MapIntToVal) [ K <- V ] => (K Int2Val|-> V M)
      [simplification, preserves-definedness]
  rule M:MapIntToVal [ K <- V ] => (K Int2Val|-> V M) requires notBool (K in_keys(M))
      [simplification, preserves-definedness]
  rule M:MapIntToVal [ K <- _ ] [ K <- V ] => M [ K <- V ] [simplification]
  // Adding the definedness condition `notBool (K1 in_keys(M))` in the ensures clause of the following rule would be redundant
  // because K1 also appears in the rhs, preserving the case when it's #Bottom.
  rule (K1 Int2Val|-> V1 M:MapIntToVal) [ K2 <- V2 ] => (K1 Int2Val|-> V1 (M [ K2 <- V2 ]))
      requires K1 =/=K K2
      [simplification, preserves-definedness]

  // Symbolic remove
  rule (K Int2Val|-> _ M:MapIntToVal) [ K <- undef ] => M
      ensures notBool (K in_keys(M))
      [simplification]
  rule M:MapIntToVal [ K <- undef ] => M
      requires notBool (K in_keys(M))
      [simplification]
  // Adding the definedness condition `notBool (K1 in_keys(M))` in the ensures clause of the following rule would be redundant
  // because K1 also appears in the rhs, preserving the case when it's #Bottom.
  rule (K1 Int2Val|-> V1 M:MapIntToVal) [ K2 <- undef ]
      => (K1 Int2Val|-> V1 (M [ K2 <- undef ]))
      requires K1 =/=K K2
      [simplification, preserves-definedness]

  // Symbolic lookup
  rule (K  Int2Val|->  V M:MapIntToVal) [ K ] => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Int2Val|-> _V M:MapIntToVal) [ K2 ] => M [K2]
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapIntToVal [ K  <-  V1 ]) [ K ]  => V1 [simplification]
  rule ( MAP:MapIntToVal [ K1 <- _V1 ]) [ K2 ] => MAP [ K2 ]
      requires K1 =/=K K2
      [simplification]

  rule (K  Int2Val|->  V M:MapIntToVal) [  K ] orDefault _ => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Int2Val|-> _V M:MapIntToVal) [ K2 ] orDefault D
      => M [K2] orDefault D
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapIntToVal [ K  <-  V1 ]) [ K ] orDefault _ => V1 [simplification]
  rule ( MAP:MapIntToVal [ K1 <- _V1 ]) [ K2 ] orDefault D
      => MAP [ K2 ] orDefault D
      requires K1 =/=K K2
      [simplification]
  rule .MapIntToVal [ _ ] orDefault D => D [simplification]

  // Symbolic in_keys
  rule K in_keys(_M:MapIntToVal [ K <- undef ]) => false [simplification]
  rule K in_keys(_M:MapIntToVal [ K <- _ ]) => true [simplification]
  rule K1 in_keys(M:MapIntToVal [ K2 <- _ ])
      => true requires K1 ==K K2 orBool K1 in_keys(M)
      [simplification]
  rule K1 in_keys(M:MapIntToVal [ K2 <- _ ])
      => K1 in_keys(M)
      requires K1 =/=K K2
      [simplification]

  rule K in_keys((K Int2Val|-> _V) M:MapIntToVal)
      => true
    requires notBool K in_keys(M)
    [simplification(50), preserves-definedness]
  rule K1 in_keys((K2 Int2Val|-> _V) M:MapIntToVal)
      => K1 in_keys(M)
    requires true
        andBool (notBool K2 in_keys(M))
        andBool K1 =/=K K2
    [simplification(50), preserves-definedness]
  rule K1 in_keys((K2 Int2Val|-> _V) M:MapIntToVal)
      => K1 ==K K2 orBool K1 in_keys(M)
    requires notBool K2 in_keys(M)
    [simplification(100), preserves-definedness]


  rule {false #Equals @Key in_keys(.MapIntToVal)} => #Ceil(@Key) [simplification]
  rule {@Key in_keys(.MapIntToVal) #Equals false} => #Ceil(@Key) [simplification]
  rule {false #Equals @Key in_keys(Key' Int2Val|-> Val @M:MapIntToVal)}
      =>  #Ceil(@Key) #And #Ceil(Key' Int2Val|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {false #Equals @Key in_keys(@M)}
      [simplification]
  rule {@Key in_keys(Key' Int2Val|-> Val @M:MapIntToVal) #Equals false}
      =>  #Ceil(@Key) #And #Ceil(Key' Int2Val|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {@Key in_keys(@M) #Equals false}
      [simplification]
endmodule

