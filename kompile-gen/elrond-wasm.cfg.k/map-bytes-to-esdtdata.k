
require "bytes-type.k"
// require "esdtdata-type.k"

module MAP-BYTES-TO-ESDTDATA
  imports private BOOL-SYNTAX
  imports private INT-SYNTAX
  imports private LIST-BYTES
  // imports private LIST-ESDTDATA
  imports private LIST
  // imports private SET-BYTES
  imports private SET
  imports BYTES-TYPE
  // imports ESDTDATA-TYPE

  syntax Bytes
  syntax EsdtData

  syntax MapBytesToEsdtData [hook(MAP.Map)]
  syntax MapBytesToEsdtData ::= MapBytesToEsdtData MapBytesToEsdtData
         [ left, function, hook(MAP.concat), klabel(_MapBytesToEsdtData_),
           symbol, assoc, comm, unit(.MapBytesToEsdtData), element(_Bytes2EsdtData|->_),
           index(0), format(%1%n%2)
         ]
  syntax MapBytesToEsdtData ::= ".MapBytesToEsdtData"
         [ function, total, hook(MAP.unit),
           klabel(.MapBytesToEsdtData), symbol, latex(\dotCt{MapBytesToEsdtData})
         ]
  syntax MapBytesToEsdtData ::= WrappedBytes "Bytes2EsdtData|->" EsdtData
         [ function, total, hook(MAP.element),
           klabel(_Bytes2EsdtData|->_), symbol,
           latex({#1}\mapsto{#2}), injective
         ]

  syntax priorities _Bytes2EsdtData|->_ > _MapBytesToEsdtData_ .MapBytesToEsdtData
  syntax non-assoc _Bytes2EsdtData|->_
  syntax EsdtData ::= MapBytesToEsdtData "[" WrappedBytes "]"
                 [function, hook(MAP.lookup), klabel(MapBytesToEsdtData:lookup), symbol]
  syntax EsdtData ::= MapBytesToEsdtData "[" WrappedBytes "]" "orDefault" EsdtData
                 [ function, total, hook(MAP.lookupOrDefault),
                   klabel(MapBytesToEsdtData:lookupOrDefault)
                 ]
  syntax MapBytesToEsdtData ::= MapBytesToEsdtData "[" key: WrappedBytes "<-" value: EsdtData "]"
                 [ function, total, klabel(MapBytesToEsdtData:update), symbol,
                   hook(MAP.update), prefer
                 ]
  syntax MapBytesToEsdtData ::= MapBytesToEsdtData "[" WrappedBytes "<-" "undef" "]"
                 [ function, total, hook(MAP.remove),
                   klabel(_MapBytesToEsdtData[_<-undef]), symbol
                 ]
  syntax MapBytesToEsdtData ::= MapBytesToEsdtData "-Map" MapBytesToEsdtData
                 [ function, total, hook(MAP.difference),
                   latex({#1}-_{\it MapBytesToEsdtDataMap}{#2})
                 ]
  syntax MapBytesToEsdtData ::= updateMap(MapBytesToEsdtData, MapBytesToEsdtData)
                 [function, total, hook(MAP.updateAll)]

  syntax MapBytesToEsdtData ::= removeAll(MapBytesToEsdtData, Set)
                 [function, total, hook(MAP.removeAll)]
  // syntax MapBytesToEsdtData ::= removeAll(MapBytesToEsdtData, SetBytes)
  //                [function, total, hook(MAP.removeAll)]

  syntax Set ::= keys(MapBytesToEsdtData)
                 [function, total, hook(MAP.keys)]
  // syntax SetBytes ::= keys(MapBytesToEsdtData)
  //                [function, total, hook(MAP.keys)]

  // syntax List ::= "keys_list" "(" MapBytesToEsdtData ")"
  //                [function, hook(MAP.keys_list)]
  syntax ListBytes ::= "keys_list" "(" MapBytesToEsdtData ")"
                 [function, hook(MAP.keys_list)]

  syntax Bool ::= WrappedBytes "in_keys" "(" MapBytesToEsdtData ")"
                 [function, total, hook(MAP.in_keys)]

  syntax List ::= values(MapBytesToEsdtData)
                 [function, hook(MAP.values)]
  // syntax ListEsdtData ::= values(MapBytesToEsdtData)
  //                [function, hook(MAP.values)]

  syntax Int ::= size(MapBytesToEsdtData)
                 [function, total, hook(MAP.size), klabel(MapBytesToEsdtData.sizeMap)]
  syntax Bool ::= MapBytesToEsdtData "<=Map" MapBytesToEsdtData
                 [function, total, hook(MAP.inclusion)]
  syntax WrappedBytes ::= choice(MapBytesToEsdtData)
                 [function, hook(MAP.choice), klabel(MapBytesToEsdtData:choice)]
endmodule

module MAP-BYTES-TO-ESDTDATA-PRIMITIVE
  imports MAP-BYTES-TO-ESDTDATA-PRIMITIVE-CONCRETE
  imports MAP-BYTES-TO-ESDTDATA-PRIMITIVE-SYMBOLIC
endmodule

module MAP-BYTES-TO-ESDTDATA-PRIMITIVE-CONCRETE [concrete]
  imports public  BOOL
  imports private K-EQUAL
  imports public  MAP-BYTES-TO-ESDTDATA
  imports private MAP-BYTES-TO-ESDTDATA-KORE-SYMBOLIC

  syntax EsdtData ::= MapBytesToEsdtData "{{" Bytes "}}"
                 [function, klabel(MapBytesToEsdtData:primitiveLookup)]
  syntax EsdtData ::= MapBytesToEsdtData "{{" Bytes "}}" "orDefault" EsdtData
                 [ function, total, klabel(MapBytesToEsdtData:primitiveLookupOrDefault) ]
  syntax MapBytesToEsdtData ::= MapBytesToEsdtData "{{" key: Bytes "<-" value: EsdtData "}}"
                 [ function, total, klabel(MapBytesToEsdtData:primitiveUpdate), symbol,
                   prefer
                 ]
  syntax MapBytesToEsdtData ::= MapBytesToEsdtData "{{" Bytes "<-" "undef" "}}"
                 [ function, total, klabel(MapBytesToEsdtData:primitiveRemove), symbol ]
  syntax Bool ::= Bytes "in_keys" "{{" MapBytesToEsdtData "}}"
                 [function, total, klabel(MapBytesToEsdtData:primitiveInKeys)]

  rule M:MapBytesToEsdtData {{ Key:Bytes }} => M[wrap(Key)]
  rule M:MapBytesToEsdtData {{ Key:Bytes }} orDefault Value:EsdtData
      => M[wrap(Key)] orDefault Value
  rule M:MapBytesToEsdtData {{ Key:Bytes <- Value:EsdtData }}
      => M[wrap(Key) <- Value]
  rule M:MapBytesToEsdtData {{ Key:Bytes <- undef }}
      => M[wrap(Key) <- undef]
  rule Key:Bytes in_keys {{ M:MapBytesToEsdtData}} => Key in_keys[M]
endmodule

module MAP-BYTES-TO-ESDTDATA-PRIMITIVE-SYMBOLIC  [symbolic]
  imports public  BOOL
  imports private K-EQUAL
  imports public  MAP-BYTES-TO-ESDTDATA
  imports private MAP-BYTES-TO-ESDTDATA-KORE-SYMBOLIC

  syntax EsdtData ::= MapBytesToEsdtData "{{" Bytes "}}"
                 [function, klabel(MapBytesToEsdtData:primitiveLookup)]
  syntax EsdtData ::= MapBytesToEsdtData "{{" Bytes "}}" "orDefault" EsdtData
                 [ function, total, klabel(MapBytesToEsdtData:primitiveLookupOrDefault) ]
  syntax MapBytesToEsdtData ::= MapBytesToEsdtData "{{" key: Bytes "<-" value: EsdtData "}}"
                 [ function, total, klabel(MapBytesToEsdtData:primitiveUpdate), symbol,
                   prefer
                 ]
  syntax MapBytesToEsdtData ::= MapBytesToEsdtData "{{" Bytes "<-" "undef" "}}"
                 [ function, total, klabel(MapBytesToEsdtData:primitiveRemove), symbol ]
  syntax Bool ::= Bytes "in_keys" "{{" MapBytesToEsdtData "}}"
                 [function, total, klabel(MapBytesToEsdtData:primitiveInKeys)]

  // Definitions
  // -----------

  rule (wrap(Key) Bytes2EsdtData|-> V:EsdtData M:MapBytesToEsdtData)
          {{ Key:Bytes }}
      => V
      ensures notBool Key in_keys {{ M }}

  rule (wrap(Key) Bytes2EsdtData|-> V:EsdtData M:MapBytesToEsdtData)
          {{ Key:Bytes }} orDefault _:EsdtData
      => V
      ensures notBool Key in_keys {{ M }}
  rule M:MapBytesToEsdtData {{ Key:Bytes }} orDefault V:EsdtData
      => V
      requires notBool Key in_keys {{ M }}

  rule (wrap(Key) Bytes2EsdtData|-> _:EsdtData M:MapBytesToEsdtData)
          {{ Key:Bytes <- Value:EsdtData }}
      => (wrap(Key) Bytes2EsdtData|-> Value) M
  rule M:MapBytesToEsdtData {{ Key:Bytes <- Value:EsdtData }}
      => (wrap(Key) Bytes2EsdtData|-> Value) M
      requires notBool Key in_keys {{ M }}

  rule (wrap(Key) Bytes2EsdtData|-> _:EsdtData M:MapBytesToEsdtData)
          {{ Key:Bytes <- undef }}
      => M
      ensures notBool Key in_keys {{ M }}
  rule M:MapBytesToEsdtData {{ Key:Bytes <- undef }}
      => M
      requires notBool Key in_keys {{ M }}

  rule Key:Bytes in_keys
          {{wrap(Key) Bytes2EsdtData|-> _:EsdtData M:MapBytesToEsdtData}}
      => true
      ensures notBool Key in_keys {{ M }}
  rule _Key:Bytes in_keys {{ .MapBytesToEsdtData }}
      => false
  rule Key:Bytes in_keys
          {{Key2:WrappedBytes Bytes2EsdtData|-> _:EsdtData M:MapBytesToEsdtData}}
      => true
      requires Key =/=K unwrap(Key2)
      ensures notBool Key2 in_keys (M)
      [simplification]

  // Translation rules
  rule M:MapBytesToEsdtData[Key:WrappedBytes]
      => M{{unwrap(Key)}}
      [simplification, symbolic(M)]
  rule M:MapBytesToEsdtData[Key:WrappedBytes]
      => M{{unwrap(Key)}}
      [simplification, symbolic(Key)]
  rule M:MapBytesToEsdtData{{Key}}
      => M[wrap(Key)]
      [simplification, concrete]

  rule M:MapBytesToEsdtData [ Key:WrappedBytes ] orDefault Value:EsdtData
      => M {{ unwrap(Key) }} orDefault Value
      [simplification, symbolic(M)]
  rule M:MapBytesToEsdtData [ Key:WrappedBytes ] orDefault Value:EsdtData
      => M {{ unwrap(Key) }} orDefault Value
      [simplification, symbolic(Key)]
  rule M:MapBytesToEsdtData [ Key:WrappedBytes ] orDefault Value:EsdtData
      => M {{ unwrap(Key) }} orDefault Value
      [simplification, symbolic(Value)]
  rule M:MapBytesToEsdtData{{Key}} orDefault Value
      => M[wrap(Key)] orDefault Value
      [simplification, concrete]

  rule M:MapBytesToEsdtData[Key:WrappedBytes <- Value:EsdtData]
      => M {{ unwrap(Key) <- Value }}
      [simplification, symbolic(M)]
  rule M:MapBytesToEsdtData[Key:WrappedBytes <- Value:EsdtData]
      => M {{ unwrap(Key) <- Value }}
      [simplification, symbolic(Key)]
  rule M:MapBytesToEsdtData[Key:WrappedBytes <- Value:EsdtData]
      => M {{ unwrap(Key) <- Value }}
      [simplification, symbolic(Value)]
  rule M:MapBytesToEsdtData{{Key <- Value}} => M[wrap(Key) <- Value ]
      [simplification, concrete]

  rule M:MapBytesToEsdtData[Key:WrappedBytes <- undef]
      => M {{ unwrap(Key) <- undef }}
      [simplification, symbolic(M)]
  rule M:MapBytesToEsdtData[Key:WrappedBytes <- undef]
      => M {{ unwrap(Key) <- undef }}
      [simplification, symbolic(Key)]
  rule M:MapBytesToEsdtData{{Key <- undef}} => M[wrap(Key) <- undef]
      [simplification, concrete]

  rule Key:WrappedBytes in_keys (M:MapBytesToEsdtData)
      => unwrap(Key) in_keys {{M}}
      [simplification, symbolic(M)]
  rule Key:WrappedBytes in_keys (M:MapBytesToEsdtData)
      => unwrap(Key) in_keys {{M}}
      [simplification, symbolic(Key)]
  rule Key in_keys {{M:MapBytesToEsdtData}} => wrap(Key) in_keys(M)
      [simplification, concrete]

  // Symbolic execution rules
  // ------------------------
  syntax Bool ::= definedPrimitiveLookup(MapBytesToEsdtData, Bytes)  [function, total]
  rule definedPrimitiveLookup(M:MapBytesToEsdtData, K:Bytes) => K in_keys{{M}}

  rule #Ceil(@M:MapBytesToEsdtData {{@K:Bytes}})
      => {definedPrimitiveLookup(@M, @K) #Equals true}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule M:MapBytesToEsdtData {{ K <- _ }} {{ K <- V }} => M {{ K <- V }} [simplification]
  rule (K1 Bytes2EsdtData|-> V1 M:MapBytesToEsdtData) {{ K2 <- V2 }}
      => (K1 Bytes2EsdtData|-> V1 (M {{ K2 <- V2 }}))
      requires unwrap(K1) =/=K K2
      [simplification]

  rule (K1 Bytes2EsdtData|-> V1 M:MapBytesToEsdtData) {{ K2 <- undef }}
      => (K1 Bytes2EsdtData|-> V1 (M {{ K2 <- undef }}))
      requires unwrap(K1) =/=K K2
      [simplification]

  rule (K1 Bytes2EsdtData|-> _V M:MapBytesToEsdtData) {{ K2 }} => M {{K2}}
      requires unwrap(K1) =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapBytesToEsdtData {{ K  <-  V1 }}) {{ K }}  => V1 [simplification]
  rule ( MAP:MapBytesToEsdtData {{ K1 <- _V1 }}) {{ K2 }} => MAP {{ K2 }}
      requires K1 =/=K K2
      [simplification]

  rule (K1 Bytes2EsdtData|-> _V M:MapBytesToEsdtData) {{ K2 }} orDefault D
      => M {{K2}} orDefault D
      requires unwrap(K1) =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapBytesToEsdtData {{ K  <-  V1 }}) {{ K }} orDefault _ => V1 [simplification]
  rule ( MAP:MapBytesToEsdtData {{ K1 <- _V1 }}) {{ K2 }} orDefault D
      => MAP {{ K2 }} orDefault D
      requires K1 =/=K K2
      [simplification]

  rule K in_keys{{_M:MapBytesToEsdtData {{ K <- undef }} }} => false [simplification]
  rule K in_keys{{_M:MapBytesToEsdtData {{ K <- _ }} }} => true [simplification]
  rule K1 in_keys{{ M:MapBytesToEsdtData {{ K2 <- _ }} }}
      => true requires K1 ==K K2 orBool K1 in_keys{{M}}
      [simplification]
  rule K1 in_keys{{ M:MapBytesToEsdtData {{ K2 <- _ }} }}
      => K1 in_keys {{ M }}
      requires K1 =/=K K2
      [simplification]

  rule K1 in_keys {{ (K2 Bytes2EsdtData|-> V) M:MapBytesToEsdtData }}
      => K1 ==K unwrap(K2) orBool K1 in_keys {{ M }}
    requires definedMapElementConcat(K2, V, M)
    [simplification(100)]
      

  rule {false #Equals @Key in_keys{{ Key' Bytes2EsdtData|-> Val @M:MapBytesToEsdtData }}}
      =>  #Ceil(@Key) #And #Ceil(Key' Bytes2EsdtData|-> Val @M)
          #And #Not({ @Key #Equals unwrap(Key') })
          #And {false #Equals @Key in_keys{{@M}}}
      [simplification]
  rule {@Key in_keys{{Key' Bytes2EsdtData|-> Val @M:MapBytesToEsdtData}} #Equals false}
      =>  #Ceil(@Key) #And #Ceil(Key' Bytes2EsdtData|-> Val @M)
          #And #Not({@Key #Equals unwrap(Key') })
          #And {@Key in_keys{{@M}} #Equals false}
      [simplification]

endmodule

module MAP-BYTES-TO-ESDTDATA-KORE-SYMBOLIC
  imports MAP-BYTES-TO-ESDTDATA
  imports private K-EQUAL
  imports private BOOL

  syntax Bool ::= definedMapElementConcat(WrappedBytes, EsdtData, MapBytesToEsdtData)  [function, total]
  rule definedMapElementConcat(K, _V, M:MapBytesToEsdtData) => notBool K in_keys(M)

  rule #Ceil(@M:MapBytesToEsdtData [@K:WrappedBytes])
      => {(@K in_keys(@M)) #Equals true}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule (K Bytes2EsdtData|-> _ M:MapBytesToEsdtData) [ K <- V ] => (K Bytes2EsdtData|-> V M) [simplification]
  rule M:MapBytesToEsdtData [ K <- V ] => (K Bytes2EsdtData|-> V M) requires notBool (K in_keys(M))
      [simplification]
  rule M:MapBytesToEsdtData [ K <- _ ] [ K <- V ] => M [ K <- V ] [simplification]
  rule (K1 Bytes2EsdtData|-> V1 M:MapBytesToEsdtData) [ K2 <- V2 ] => (K1 Bytes2EsdtData|-> V1 (M [ K2 <- V2 ]))
      requires K1 =/=K K2
      [simplification]

  rule (K Bytes2EsdtData|-> _ M:MapBytesToEsdtData) [ K <- undef ] => M
      ensures notBool (K in_keys(M))
      [simplification]
  rule M:MapBytesToEsdtData [ K <- undef ] => M
      requires notBool (K in_keys(M))
      [simplification]
  rule (K1 Bytes2EsdtData|-> V1 M:MapBytesToEsdtData) [ K2 <- undef ]
      => (K1 Bytes2EsdtData|-> V1 (M [ K2 <- undef ]))
      requires K1 =/=K K2
      [simplification]

  rule (K  Bytes2EsdtData|->  V M:MapBytesToEsdtData) [ K ] => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Bytes2EsdtData|-> _V M:MapBytesToEsdtData) [ K2 ] => M [K2]
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapBytesToEsdtData [ K  <-  V1 ]) [ K ]  => V1 [simplification]
  rule ( MAP:MapBytesToEsdtData [ K1 <- _V1 ]) [ K2 ] => MAP [ K2 ]
      requires K1 =/=K K2
      [simplification]

  rule (K  Bytes2EsdtData|->  V M:MapBytesToEsdtData) [  K ] orDefault _ => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Bytes2EsdtData|-> _V M:MapBytesToEsdtData) [ K2 ] orDefault D
      => M [K2] orDefault D
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapBytesToEsdtData [ K  <-  V1 ]) [ K ] orDefault _ => V1 [simplification]
  rule ( MAP:MapBytesToEsdtData [ K1 <- _V1 ]) [ K2 ] orDefault D
      => MAP [ K2 ] orDefault D
      requires K1 =/=K K2
      [simplification]
  rule .MapBytesToEsdtData [ _ ] orDefault D => D [simplification]

  rule K in_keys(_M:MapBytesToEsdtData [ K <- undef ]) => false [simplification]
  rule K in_keys(_M:MapBytesToEsdtData [ K <- _ ]) => true [simplification]
  rule K1 in_keys(M:MapBytesToEsdtData [ K2 <- _ ])
      => true requires K1 ==K K2 orBool K1 in_keys(M)
      [simplification]
  rule K1 in_keys(M:MapBytesToEsdtData [ K2 <- _ ])
      => K1 in_keys(M)
      requires K1 =/=K K2
      [simplification]

  rule K in_keys((K Bytes2EsdtData|-> V) M:MapBytesToEsdtData)
      => true
    requires definedMapElementConcat(K, V, M)
    [simplification(50)]
  rule K1 in_keys((K2 Bytes2EsdtData|-> V) M:MapBytesToEsdtData)
      => K1 in_keys(M)
    requires true
        andBool definedMapElementConcat(K2, V, M)
        andBool K1 =/=K K2
    [simplification(50)]
  rule K1 in_keys((K2 Bytes2EsdtData|-> V) M:MapBytesToEsdtData)
      => K1 ==K K2 orBool K1 in_keys(M)
    requires definedMapElementConcat(K2, V, M)
    [simplification(100)]
      

  rule {false #Equals @Key in_keys(.MapBytesToEsdtData)} => #Ceil(@Key) [simplification]
  rule {@Key in_keys(.MapBytesToEsdtData) #Equals false} => #Ceil(@Key) [simplification]
  rule {false #Equals @Key in_keys(Key' Bytes2EsdtData|-> Val @M:MapBytesToEsdtData)}
      =>  #Ceil(@Key) #And #Ceil(Key' Bytes2EsdtData|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {false #Equals @Key in_keys(@M)}
      [simplification]
  rule {@Key in_keys(Key' Bytes2EsdtData|-> Val @M:MapBytesToEsdtData) #Equals false}
      =>  #Ceil(@Key) #And #Ceil(Key' Bytes2EsdtData|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {@Key in_keys(@M) #Equals false}
      [simplification]
endmodule

module MAP-BYTES-TO-ESDTDATA-CURLY-BRACE
  imports private BOOL
  imports private K-EQUAL-SYNTAX
  imports MAP-BYTES-TO-ESDTDATA

  syntax MapBytesToEsdtData ::= MapBytesToEsdtData "{" key:WrappedBytes "<-" value:EsdtData "}"
      [function, total, klabel(MapBytesToEsdtData:curly_update), symbol]
  rule M:MapBytesToEsdtData{Key <- Value} => M (Key Bytes2EsdtData|-> Value)
    requires notBool Key in_keys(M)
  rule (Key Bytes2EsdtData|-> _ M:MapBytesToEsdtData){Key <- Value}
      => M (Key Bytes2EsdtData|-> Value)
  rule (M:MapBytesToEsdtData{Key <- Value})(A Bytes2EsdtData|-> B N:MapBytesToEsdtData)
      => (M (A Bytes2EsdtData|-> B)) {Key <- Value} N
      requires notBool A ==K Key
      [simplification]

  rule M:MapBytesToEsdtData{Key1 <- Value1}[Key2 <- Value2]
      => ((M:MapBytesToEsdtData[Key2 <- Value2]{Key1 <- Value1}) #And #Not ({Key1 #Equals Key2}))
        #Or ((M:MapBytesToEsdtData[Key2 <- Value2]) #And {Key1 #Equals Key2})
      [simplification(20)]
  rule M:MapBytesToEsdtData[Key <- Value]
      => M:MapBytesToEsdtData{Key <- Value}
      [simplification(100)]
  rule M:MapBytesToEsdtData{Key1 <- _Value1}[Key2] orDefault Value2
      => M[Key2] orDefault Value2
      requires Key1 =/=K Key2
      [simplification]
  rule _M:MapBytesToEsdtData{Key <- Value1}[Key] orDefault _Value2
      => Value1
      [simplification]
  // rule M:MapBytesToEsdtData{Key1 <- Value1}[Key2] orDefault Value2
  //     => (M[Key2] orDefault Value2 #And #Not ({Key1 #Equals Key2}))
  //       #Or (Value1 #And {Key1 #Equals Key2})
  //     [simplification]
  rule M:MapBytesToEsdtData{Key1 <- Value1}[Key2]
      => (M[Key2] #And #Not ({Key1 #Equals Key2}))
        #Or (Value1 #And {Key1 #Equals Key2})
      [simplification]

  rule Key1 in_keys(_:MapBytesToEsdtData{Key1 <- _})
      => true
      [simplification(50)]
  rule Key1 in_keys(M:MapBytesToEsdtData{Key2 <- _})
      => Key1 in_keys(M)
      requires notBool Key1 ==K Key2
      [simplification(50)]
  rule K1 in_keys(M:MapBytesToEsdtData { K2 <- _ })
      => K1 ==K K2 orBool K1 in_keys(M)
    [simplification(100)]
      
endmodule
