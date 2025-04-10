
require "int-type.k"
// require "functype-type.k"
require "list-int.k"

module MAP-INT-TO-FUNCTYPE
  imports private BOOL-SYNTAX
  imports private INT-SYNTAX
  imports private LIST-INT
  // imports private LIST-FUNCTYPE
  imports private LIST
  // imports private SET-INT
  imports private SET
  imports INT-TYPE
  // imports FUNCTYPE-TYPE

  syntax Int
  syntax FuncType

  syntax MapIntToFuncType [hook(MAP.Map)]
  syntax MapIntToFuncType ::= MapIntToFuncType MapIntToFuncType
         [ left, function, hook(MAP.concat), klabel(_MapIntToFuncType_),
           symbol, assoc, comm, unit(.MapIntToFuncType), element(_Int2FuncType|->_),
           index(0), format(%1%n%2)
         ]
  syntax MapIntToFuncType ::= ".MapIntToFuncType"
         [ function, total, hook(MAP.unit),
           klabel(.MapIntToFuncType), symbol, latex(\dotCt{MapIntToFuncType})
         ]
  syntax MapIntToFuncType ::= WrappedInt "Int2FuncType|->" FuncType
         [ function, total, hook(MAP.element),
           klabel(_Int2FuncType|->_), symbol,
           latex({#1}\mapsto{#2}), injective
         ]

  syntax priorities _Int2FuncType|->_ > _MapIntToFuncType_ .MapIntToFuncType
  syntax non-assoc _Int2FuncType|->_
  syntax FuncType ::= MapIntToFuncType "[" WrappedInt "]"
                 [function, hook(MAP.lookup), klabel(MapIntToFuncType:lookup), symbol]
  syntax FuncType ::= MapIntToFuncType "[" WrappedInt "]" "orDefault" FuncType
                 [ function, total, hook(MAP.lookupOrDefault),
                   klabel(MapIntToFuncType:lookupOrDefault), symbol
                 ]
  syntax MapIntToFuncType ::= MapIntToFuncType "[" key: WrappedInt "<-" value: FuncType "]"
                 [ function, total, klabel(MapIntToFuncType:update), symbol,
                   hook(MAP.update), prefer
                 ]
  syntax MapIntToFuncType ::= MapIntToFuncType "[" WrappedInt "<-" "undef" "]"
                 [ function, total, hook(MAP.remove),
                   klabel(_MapIntToFuncType[_<-undef]), symbol
                 ]
  syntax MapIntToFuncType ::= MapIntToFuncType "-Map" MapIntToFuncType
                 [ function, total, hook(MAP.difference),
                   latex({#1}-_{\it MapIntToFuncTypeMap}{#2})
                 ]
  syntax MapIntToFuncType ::= updateMap(MapIntToFuncType, MapIntToFuncType)
                 [function, total, hook(MAP.updateAll)]

  syntax MapIntToFuncType ::= removeAll(MapIntToFuncType, Set)
                 [function, total, hook(MAP.removeAll)]
  // syntax MapIntToFuncType ::= removeAll(MapIntToFuncType, SetInt)
  //                [function, total, hook(MAP.removeAll)]

  syntax Set ::= keys(MapIntToFuncType)
                 [function, total, hook(MAP.keys)]
  // syntax SetInt ::= keys(MapIntToFuncType)
  //                [function, total, hook(MAP.keys)]

  // syntax List ::= "keys_list" "(" MapIntToFuncType ")"
  //                [function, hook(MAP.keys_list)]
  syntax ListInt ::= "keys_list" "(" MapIntToFuncType ")"
                 [function, hook(MAP.keys_list)]

  syntax Bool ::= WrappedInt "in_keys" "(" MapIntToFuncType ")"
                 [function, total, hook(MAP.in_keys)]

  syntax List ::= values(MapIntToFuncType)
                 [function, hook(MAP.values)]
  // syntax ListFuncType ::= values(MapIntToFuncType)
  //                [function, hook(MAP.values)]

  syntax Int ::= size(MapIntToFuncType)
                 [function, total, hook(MAP.size), klabel(MapIntToFuncType.sizeMap), symbol]
  syntax Bool ::= MapIntToFuncType "<=Map" MapIntToFuncType
                 [function, total, hook(MAP.inclusion)]
  syntax WrappedInt ::= choice(MapIntToFuncType)
                 [function, hook(MAP.choice), klabel(MapIntToFuncType:choice), symbol]
endmodule

module MAP-INT-TO-FUNCTYPE-PRIMITIVE
  imports MAP-INT-TO-FUNCTYPE-PRIMITIVE-CONCRETE
  imports MAP-INT-TO-FUNCTYPE-PRIMITIVE-SYMBOLIC
endmodule

module MAP-INT-TO-FUNCTYPE-PRIMITIVE-CONCRETE [concrete]
  imports public  BOOL
  imports private K-EQUAL
  imports public  MAP-INT-TO-FUNCTYPE

  syntax FuncType ::= MapIntToFuncType "{{" Int "}}"
                 [function, klabel(MapIntToFuncType:primitiveLookup), symbol]
  syntax FuncType ::= MapIntToFuncType "{{" Int "}}" "orDefault" FuncType
                 [ function, total, klabel(MapIntToFuncType:primitiveLookupOrDefault), symbol ]
  syntax MapIntToFuncType ::= MapIntToFuncType "{{" key: Int "<-" value: FuncType "}}"
                 [ function, total, klabel(MapIntToFuncType:primitiveUpdate), symbol,
                   prefer
                 ]
  syntax MapIntToFuncType ::= MapIntToFuncType "{{" Int "<-" "undef" "}}"
                 [ function, total, klabel(MapIntToFuncType:primitiveRemove), symbol ]
  syntax Bool ::= Int "in_keys" "{{" MapIntToFuncType "}}"
                 [function, total, klabel(MapIntToFuncType:primitiveInKeys), symbol]

  rule (M:MapIntToFuncType {{ Key:Int }})
      => (M[wrap(Key)])
  rule M:MapIntToFuncType {{ Key:Int }} orDefault Value:FuncType
      => M[wrap(Key)] orDefault Value
  rule M:MapIntToFuncType {{ Key:Int <- Value:FuncType }}
      => M[wrap(Key) <- Value]
  rule M:MapIntToFuncType {{ Key:Int <- undef }}
      => M[wrap(Key) <- undef]
  rule Key:Int in_keys {{ M:MapIntToFuncType }} => wrap(Key) in_keys(M)
endmodule

module MAP-INT-TO-FUNCTYPE-PRIMITIVE-SYMBOLIC  [symbolic]
  imports public  BOOL
  imports private K-EQUAL
  imports public  MAP-INT-TO-FUNCTYPE
  imports private MAP-INT-TO-FUNCTYPE-KORE-SYMBOLIC

  syntax FuncType ::= MapIntToFuncType "{{" Int "}}"
                 [function, symbol, klabel(MapIntToFuncType:primitiveLookup)]
  syntax FuncType ::= MapIntToFuncType "{{" Int "}}" "orDefault" FuncType
                 [ function, total, symbol, klabel(MapIntToFuncType:primitiveLookupOrDefault) ]
  syntax MapIntToFuncType ::= MapIntToFuncType "{{" key: Int "<-" value: FuncType "}}"
                 [ function, total, klabel(MapIntToFuncType:primitiveUpdate), symbol,
                   prefer
                 ]
  syntax MapIntToFuncType ::= MapIntToFuncType "{{" Int "<-" "undef" "}}"
                 [ function, total, symbol, klabel(MapIntToFuncType:primitiveRemove) ]
  syntax Bool ::= Int "in_keys" "{{" MapIntToFuncType "}}"
                 [function, total, symbol, klabel(MapIntToFuncType:primitiveInKeys)]

  // Definitions
  // -----------

  rule (wrap(Key) Int2FuncType|-> V:FuncType M:MapIntToFuncType)
          {{ Key:Int }}
      => V
      ensures notBool Key in_keys {{ M }}

  rule (wrap(Key) Int2FuncType|-> V:FuncType M:MapIntToFuncType)
          {{ Key:Int }} orDefault _:FuncType
      => V
      ensures notBool Key in_keys {{ M }}
  rule M:MapIntToFuncType {{ Key:Int }} orDefault V:FuncType
      => V
      requires notBool Key in_keys {{ M }}

  rule (wrap(Key) Int2FuncType|-> _:FuncType M:MapIntToFuncType)
          {{ Key:Int <- Value:FuncType }}
      => (wrap(Key) Int2FuncType|-> Value) M
  rule M:MapIntToFuncType {{ Key:Int <- Value:FuncType }}
      => (wrap(Key) Int2FuncType|-> Value) M
      requires notBool Key in_keys {{ M }}

  rule (wrap(Key) Int2FuncType|-> _:FuncType M:MapIntToFuncType)
          {{ Key:Int <- undef }}
      => M
      ensures notBool Key in_keys {{ M }}
  rule M:MapIntToFuncType {{ Key:Int <- undef }}
      => M
      requires notBool Key in_keys {{ M }}

  rule Key:Int in_keys
          {{wrap(Key) Int2FuncType|-> _:FuncType M:MapIntToFuncType}}
      => true
      ensures notBool Key in_keys {{ M }}
  rule _Key:Int in_keys {{ .MapIntToFuncType }}
      => false
  // TODO: This may create an exponential evaluation tree, depending on how
  // caching works in the backend. It should be rewritten to finish in
  // O(n^2) or something like that, where n is the number of explicit keys
  // in the map.
  rule Key:Int in_keys
          {{Key2:WrappedInt Int2FuncType|-> _:FuncType M:MapIntToFuncType}}
      => Key in_keys {{ M }}
      requires Key =/=K unwrap( Key2 )
      ensures notBool Key2 in_keys (M)
      [simplification]

  // Translation rules
  rule M:MapIntToFuncType[Key:WrappedInt]
      => M{{unwrap( Key )}}
      [simplification, symbolic(M)]
  rule M:MapIntToFuncType[Key:WrappedInt]
      => M{{unwrap( Key )}}
      [simplification, symbolic(Key)]
  rule M:MapIntToFuncType{{Key}}
      => M[wrap(Key)]
      [simplification, concrete]

  rule M:MapIntToFuncType [ Key:WrappedInt ] orDefault Value:FuncType
      => M {{ unwrap( Key ) }} orDefault Value
      [simplification, symbolic(M)]
  rule M:MapIntToFuncType [ Key:WrappedInt ] orDefault Value:FuncType
      => M {{ unwrap( Key ) }} orDefault Value
      [simplification, symbolic(Key)]
  rule M:MapIntToFuncType [ Key:WrappedInt ] orDefault Value:FuncType
      => M {{ unwrap( Key ) }} orDefault Value
      [simplification, symbolic(Value)]
  rule M:MapIntToFuncType{{Key}} orDefault Value
      => M[wrap(Key)] orDefault Value
      [simplification, concrete]

  rule M:MapIntToFuncType[Key:WrappedInt <- Value:FuncType]
      => M {{ unwrap( Key ) <- Value }}
      [simplification, symbolic(M)]
  rule M:MapIntToFuncType[Key:WrappedInt <- Value:FuncType]
      => M {{ unwrap( Key ) <- Value }}
      [simplification, symbolic(Key)]
  rule M:MapIntToFuncType[Key:WrappedInt <- Value:FuncType]
      => M {{ unwrap( Key ) <- Value }}
      [simplification, symbolic(Value)]
  rule M:MapIntToFuncType{{Key <- Value}} => M[wrap(Key) <- Value ]
      [simplification, concrete]

  rule M:MapIntToFuncType[Key:WrappedInt <- undef]
      => M {{ unwrap( Key ) <- undef }}
      [simplification, symbolic(M)]
  rule M:MapIntToFuncType[Key:WrappedInt <- undef]
      => M {{ unwrap( Key ) <- undef }}
      [simplification, symbolic(Key)]
  rule M:MapIntToFuncType{{Key <- undef}} => M[wrap(Key) <- undef]
      [simplification, concrete]

  rule Key:WrappedInt in_keys (M:MapIntToFuncType)
      => unwrap( Key ) in_keys {{M}}
      [simplification, symbolic(M)]
  rule Key:WrappedInt in_keys (M:MapIntToFuncType)
      => unwrap( Key ) in_keys {{M}}
      [simplification, symbolic(Key)]
  rule Key in_keys {{M:MapIntToFuncType}} => wrap(Key) in_keys(M)
      [simplification, concrete]

  // Symbolic execution rules
  // ------------------------
  syntax Bool ::= definedPrimitiveLookup(MapIntToFuncType, Int)  [function, total]
  rule definedPrimitiveLookup(M:MapIntToFuncType, K:Int) => K in_keys{{M}}

  rule #Ceil(@M:MapIntToFuncType {{@K:Int}})
      => {definedPrimitiveLookup(@M, @K) #Equals true}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule M:MapIntToFuncType {{ K <- _ }} {{ K <- V }} => M {{ K <- V }} [simplification]
  rule (K1 Int2FuncType|-> V1 M:MapIntToFuncType) {{ K2 <- V2 }}
      => (K1 Int2FuncType|-> V1 (M {{ K2 <- V2 }}))
      requires unwrap( K1 ) =/=K K2
      [simplification]

  rule (K1 Int2FuncType|-> V1 M:MapIntToFuncType) {{ K2 <- undef }}
      => (K1 Int2FuncType|-> V1 (M {{ K2 <- undef }}))
      requires unwrap( K1 ) =/=K K2
      [simplification]

  rule (K1 Int2FuncType|-> _V M:MapIntToFuncType) {{ K2 }} => M {{K2}}
      requires unwrap( K1 ) =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapIntToFuncType {{ K  <-  V1 }}) {{ K }}  => V1 [simplification]
  rule ( MAP:MapIntToFuncType {{ K1 <- _V1 }}) {{ K2 }} => MAP {{ K2 }}
      requires K1 =/=K K2
      [simplification]

  rule (K1 Int2FuncType|-> _V M:MapIntToFuncType) {{ K2 }} orDefault D
      => M {{K2}} orDefault D
      requires unwrap( K1 ) =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapIntToFuncType {{ K  <-  V1 }}) {{ K }} orDefault _ => V1 [simplification]
  rule ( MAP:MapIntToFuncType {{ K1 <- _V1 }}) {{ K2 }} orDefault D
      => MAP {{ K2 }} orDefault D
      requires K1 =/=K K2
      [simplification]

  rule K in_keys{{_M:MapIntToFuncType {{ K <- undef }} }} => false [simplification]
  rule K in_keys{{_M:MapIntToFuncType {{ K <- _ }} }} => true [simplification]
  rule K1 in_keys{{ M:MapIntToFuncType {{ K2 <- _ }} }}
      => true requires K1 ==K K2 orBool K1 in_keys{{M}}
      [simplification]
  rule K1 in_keys{{ M:MapIntToFuncType {{ K2 <- _ }} }}
      => K1 in_keys {{ M }}
      requires K1 =/=K K2
      [simplification]

  rule K1 in_keys {{ (K2 Int2FuncType|-> V) M:MapIntToFuncType }}
      => K1 ==K unwrap( K2 ) orBool K1 in_keys {{ M }}
    requires definedMapElementConcat(K2, V, M)
    [simplification(100)]


  rule {false #Equals @Key in_keys{{ Key' Int2FuncType|-> Val @M:MapIntToFuncType }}}
      =>  #Ceil(@Key) #And #Ceil(Key' Int2FuncType|-> Val @M)
          #And #Not({ @Key #Equals unwrap( Key' ) })
          #And {false #Equals @Key in_keys{{@M}}}
      [simplification]
  rule {@Key in_keys{{Key' Int2FuncType|-> Val @M:MapIntToFuncType}} #Equals false}
      =>  #Ceil(@Key) #And #Ceil(Key' Int2FuncType|-> Val @M)
          #And #Not({@Key #Equals unwrap( Key' ) })
          #And {@Key in_keys{{@M}} #Equals false}
      [simplification]

endmodule

module MAP-INT-TO-FUNCTYPE-KORE-SYMBOLIC
  imports MAP-INT-TO-FUNCTYPE
  imports private K-EQUAL
  imports private BOOL

  syntax Bool ::= definedMapElementConcat(WrappedInt, FuncType, MapIntToFuncType)  [function, total]
  rule definedMapElementConcat(K, _V, M:MapIntToFuncType) => notBool K in_keys(M)

  rule #Ceil(@M:MapIntToFuncType [@K:WrappedInt])
      => {(@K in_keys(@M)) #Equals true}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule (K Int2FuncType|-> _ M:MapIntToFuncType) [ K <- V ] => (K Int2FuncType|-> V M) [simplification]
  rule M:MapIntToFuncType [ K <- V ] => (K Int2FuncType|-> V M) requires notBool (K in_keys(M))
      [simplification]
  rule M:MapIntToFuncType [ K <- _ ] [ K <- V ] => M [ K <- V ] [simplification]
  rule (K1 Int2FuncType|-> V1 M:MapIntToFuncType) [ K2 <- V2 ] => (K1 Int2FuncType|-> V1 (M [ K2 <- V2 ]))
      requires K1 =/=K K2
      [simplification]

  rule (K Int2FuncType|-> _ M:MapIntToFuncType) [ K <- undef ] => M
      ensures notBool (K in_keys(M))
      [simplification]
  rule M:MapIntToFuncType [ K <- undef ] => M
      requires notBool (K in_keys(M))
      [simplification]
  rule (K1 Int2FuncType|-> V1 M:MapIntToFuncType) [ K2 <- undef ]
      => (K1 Int2FuncType|-> V1 (M [ K2 <- undef ]))
      requires K1 =/=K K2
      [simplification]

  rule (K  Int2FuncType|->  V M:MapIntToFuncType) [ K ] => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Int2FuncType|-> _V M:MapIntToFuncType) [ K2 ] => M [K2]
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapIntToFuncType [ K  <-  V1 ]) [ K ]  => V1 [simplification]
  rule ( MAP:MapIntToFuncType [ K1 <- _V1 ]) [ K2 ] => MAP [ K2 ]
      requires K1 =/=K K2
      [simplification]

  rule (K  Int2FuncType|->  V M:MapIntToFuncType) [  K ] orDefault _ => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Int2FuncType|-> _V M:MapIntToFuncType) [ K2 ] orDefault D
      => M [K2] orDefault D
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapIntToFuncType [ K  <-  V1 ]) [ K ] orDefault _ => V1 [simplification]
  rule ( MAP:MapIntToFuncType [ K1 <- _V1 ]) [ K2 ] orDefault D
      => MAP [ K2 ] orDefault D
      requires K1 =/=K K2
      [simplification]
  rule .MapIntToFuncType [ _ ] orDefault D => D [simplification]

  rule K in_keys(_M:MapIntToFuncType [ K <- undef ]) => false [simplification]
  rule K in_keys(_M:MapIntToFuncType [ K <- _ ]) => true [simplification]
  rule K1 in_keys(M:MapIntToFuncType [ K2 <- _ ])
      => true requires K1 ==K K2 orBool K1 in_keys(M)
      [simplification]
  rule K1 in_keys(M:MapIntToFuncType [ K2 <- _ ])
      => K1 in_keys(M)
      requires K1 =/=K K2
      [simplification]

  rule K in_keys((K Int2FuncType|-> V) M:MapIntToFuncType)
      => true
    requires definedMapElementConcat(K, V, M)
    [simplification(50)]
  rule K1 in_keys((K2 Int2FuncType|-> V) M:MapIntToFuncType)
      => K1 in_keys(M)
    requires true
        andBool definedMapElementConcat(K2, V, M)
        andBool K1 =/=K K2
    [simplification(50)]
  rule K1 in_keys((K2 Int2FuncType|-> V) M:MapIntToFuncType)
      => K1 ==K K2 orBool K1 in_keys(M)
    requires definedMapElementConcat(K2, V, M)
    [simplification(100)]


  rule {false #Equals @Key in_keys(.MapIntToFuncType)} => #Ceil(@Key) [simplification]
  rule {@Key in_keys(.MapIntToFuncType) #Equals false} => #Ceil(@Key) [simplification]
  rule {false #Equals @Key in_keys(Key' Int2FuncType|-> Val @M:MapIntToFuncType)}
      =>  #Ceil(@Key) #And #Ceil(Key' Int2FuncType|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {false #Equals @Key in_keys(@M)}
      [simplification]
  rule {@Key in_keys(Key' Int2FuncType|-> Val @M:MapIntToFuncType) #Equals false}
      =>  #Ceil(@Key) #And #Ceil(Key' Int2FuncType|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {@Key in_keys(@M) #Equals false}
      [simplification]
endmodule

module MAP-INT-TO-FUNCTYPE-CURLY-BRACE
  imports private BOOL
  imports private K-EQUAL-SYNTAX
  imports MAP-INT-TO-FUNCTYPE

  syntax MapIntToFuncType ::= MapIntToFuncType "{" key:WrappedInt "<-" value:FuncType "}"
      [function, total, symbol, klabel(MapIntToFuncType:curly_update)]
  rule M:MapIntToFuncType{Key <- Value} => M (Key Int2FuncType|-> Value)
    requires notBool Key in_keys(M)
  rule (Key Int2FuncType|-> _ M:MapIntToFuncType){Key <- Value}
      => M (Key Int2FuncType|-> Value)
  rule (M:MapIntToFuncType{Key <- Value})(A Int2FuncType|-> B N:MapIntToFuncType)
      => (M (A Int2FuncType|-> B)) {Key <- Value} N
      requires notBool A ==K Key
      [simplification]

  rule M:MapIntToFuncType{Key1 <- Value1}[Key2 <- Value2]
      => ((M:MapIntToFuncType[Key2 <- Value2]{Key1 <- Value1}) #And #Not ({Key1 #Equals Key2}))
        #Or ((M:MapIntToFuncType[Key2 <- Value2]) #And {Key1 #Equals Key2})
      [simplification(20)]
  rule M:MapIntToFuncType[Key <- Value]
      => M:MapIntToFuncType{Key <- Value}
      [simplification(100)]
  rule M:MapIntToFuncType{Key1 <- _Value1}[Key2] orDefault Value2
      => M[Key2] orDefault Value2
      requires Key1 =/=K Key2
      [simplification]
  rule _M:MapIntToFuncType{Key <- Value1}[Key] orDefault _Value2
      => Value1
      [simplification]
  // rule M:MapIntToFuncType{Key1 <- Value1}[Key2] orDefault Value2
  //     => (M[Key2] orDefault Value2 #And #Not ({Key1 #Equals Key2}))
  //       #Or (Value1 #And {Key1 #Equals Key2})
  //     [simplification]
  rule M:MapIntToFuncType{Key1 <- Value1}[Key2]
      => (M[Key2] #And #Not ({Key1 #Equals Key2}))
        #Or (Value1 #And {Key1 #Equals Key2})
      [simplification]

  rule Key1 in_keys(_:MapIntToFuncType{Key1 <- _})
      => true
      [simplification(50)]
  rule Key1 in_keys(M:MapIntToFuncType{Key2 <- _})
      => Key1 in_keys(M)
      requires notBool Key1 ==K Key2
      [simplification(50)]
  rule K1 in_keys(M:MapIntToFuncType { K2 <- _ })
      => K1 ==K K2 orBool K1 in_keys(M)
    [simplification(100)]

endmodule
