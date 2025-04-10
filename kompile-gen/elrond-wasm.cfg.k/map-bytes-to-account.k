
require "bytes-type.k"
// require "account-type.k"

module MAP-BYTES-TO-ACCOUNT
  imports private BOOL-SYNTAX
  imports private INT-SYNTAX
  imports private LIST-BYTES
  // imports private LIST-ACCOUNT
  imports private LIST
  // imports private SET-BYTES
  imports private SET
  imports BYTES-TYPE
  // imports ACCOUNT-TYPE

  syntax Bytes
  syntax Account

  syntax MapBytesToAccount [hook(MAP.Map)]
  syntax MapBytesToAccount ::= MapBytesToAccount MapBytesToAccount
         [ left, function, hook(MAP.concat), klabel(_MapBytesToAccount_),
           symbol, assoc, comm, unit(.MapBytesToAccount), element(_Bytes2Account|->_),
           index(0), format(%1%n%2)
         ]
  syntax MapBytesToAccount ::= ".MapBytesToAccount"
         [ function, total, hook(MAP.unit),
           klabel(.MapBytesToAccount), symbol, latex(\dotCt{MapBytesToAccount})
         ]
  syntax MapBytesToAccount ::= WrappedBytes "Bytes2Account|->" Account
         [ function, total, hook(MAP.element),
           klabel(_Bytes2Account|->_), symbol,
           latex({#1}\mapsto{#2}), injective
         ]

  syntax priorities _Bytes2Account|->_ > _MapBytesToAccount_ .MapBytesToAccount
  syntax non-assoc _Bytes2Account|->_
  syntax Account ::= MapBytesToAccount "[" WrappedBytes "]"
                 [function, hook(MAP.lookup), klabel(MapBytesToAccount:lookup), symbol]
  syntax Account ::= MapBytesToAccount "[" WrappedBytes "]" "orDefault" Account
                 [ function, total, hook(MAP.lookupOrDefault),
                   klabel(MapBytesToAccount:lookupOrDefault)
                 ]
  syntax MapBytesToAccount ::= MapBytesToAccount "[" key: WrappedBytes "<-" value: Account "]"
                 [ function, total, klabel(MapBytesToAccount:update), symbol,
                   hook(MAP.update), prefer
                 ]
  syntax MapBytesToAccount ::= MapBytesToAccount "[" WrappedBytes "<-" "undef" "]"
                 [ function, total, hook(MAP.remove),
                   klabel(_MapBytesToAccount[_<-undef]), symbol
                 ]
  syntax MapBytesToAccount ::= MapBytesToAccount "-Map" MapBytesToAccount
                 [ function, total, hook(MAP.difference),
                   latex({#1}-_{\it MapBytesToAccountMap}{#2})
                 ]
  syntax MapBytesToAccount ::= updateMap(MapBytesToAccount, MapBytesToAccount)
                 [function, total, hook(MAP.updateAll)]

  syntax MapBytesToAccount ::= removeAll(MapBytesToAccount, Set)
                 [function, total, hook(MAP.removeAll)]
  // syntax MapBytesToAccount ::= removeAll(MapBytesToAccount, SetBytes)
  //                [function, total, hook(MAP.removeAll)]

  syntax Set ::= keys(MapBytesToAccount)
                 [function, total, hook(MAP.keys)]
  // syntax SetBytes ::= keys(MapBytesToAccount)
  //                [function, total, hook(MAP.keys)]

  // syntax List ::= "keys_list" "(" MapBytesToAccount ")"
  //                [function, hook(MAP.keys_list)]
  syntax ListBytes ::= "keys_list" "(" MapBytesToAccount ")"
                 [function, hook(MAP.keys_list)]

  syntax Bool ::= WrappedBytes "in_keys" "(" MapBytesToAccount ")"
                 [function, total, hook(MAP.in_keys)]

  syntax List ::= values(MapBytesToAccount)
                 [function, hook(MAP.values)]
  // syntax ListAccount ::= values(MapBytesToAccount)
  //                [function, hook(MAP.values)]

  syntax Int ::= size(MapBytesToAccount)
                 [function, total, hook(MAP.size), klabel(MapBytesToAccount.sizeMap)]
  syntax Bool ::= MapBytesToAccount "<=Map" MapBytesToAccount
                 [function, total, hook(MAP.inclusion)]
  syntax WrappedBytes ::= choice(MapBytesToAccount)
                 [function, hook(MAP.choice), klabel(MapBytesToAccount:choice)]
endmodule

module MAP-BYTES-TO-ACCOUNT-PRIMITIVE
  imports MAP-BYTES-TO-ACCOUNT-PRIMITIVE-CONCRETE
  imports MAP-BYTES-TO-ACCOUNT-PRIMITIVE-SYMBOLIC
endmodule

module MAP-BYTES-TO-ACCOUNT-PRIMITIVE-CONCRETE [concrete]
  imports public  BOOL
  imports private K-EQUAL
  imports public  MAP-BYTES-TO-ACCOUNT
  imports private MAP-BYTES-TO-ACCOUNT-KORE-SYMBOLIC

  syntax Account ::= MapBytesToAccount "{{" Bytes "}}"
                 [function, klabel(MapBytesToAccount:primitiveLookup)]
  syntax Account ::= MapBytesToAccount "{{" Bytes "}}" "orDefault" Account
                 [ function, total, klabel(MapBytesToAccount:primitiveLookupOrDefault) ]
  syntax MapBytesToAccount ::= MapBytesToAccount "{{" key: Bytes "<-" value: Account "}}"
                 [ function, total, klabel(MapBytesToAccount:primitiveUpdate), symbol,
                   prefer
                 ]
  syntax MapBytesToAccount ::= MapBytesToAccount "{{" Bytes "<-" "undef" "}}"
                 [ function, total, klabel(MapBytesToAccount:primitiveRemove), symbol ]
  syntax Bool ::= Bytes "in_keys" "{{" MapBytesToAccount "}}"
                 [function, total, klabel(MapBytesToAccount:primitiveInKeys)]

  rule M:MapBytesToAccount {{ Key:Bytes }} => M[wrap(Key)]
  rule M:MapBytesToAccount {{ Key:Bytes }} orDefault Value:Account
      => M[wrap(Key)] orDefault Value
  rule M:MapBytesToAccount {{ Key:Bytes <- Value:Account }}
      => M[wrap(Key) <- Value]
  rule M:MapBytesToAccount {{ Key:Bytes <- undef }}
      => M[wrap(Key) <- undef]
  rule Key:Bytes in_keys {{ M:MapBytesToAccount}} => Key in_keys[M]
endmodule

module MAP-BYTES-TO-ACCOUNT-PRIMITIVE-SYMBOLIC  [symbolic]
  imports public  BOOL
  imports private K-EQUAL
  imports public  MAP-BYTES-TO-ACCOUNT
  imports private MAP-BYTES-TO-ACCOUNT-KORE-SYMBOLIC

  syntax Account ::= MapBytesToAccount "{{" Bytes "}}"
                 [function, klabel(MapBytesToAccount:primitiveLookup)]
  syntax Account ::= MapBytesToAccount "{{" Bytes "}}" "orDefault" Account
                 [ function, total, klabel(MapBytesToAccount:primitiveLookupOrDefault) ]
  syntax MapBytesToAccount ::= MapBytesToAccount "{{" key: Bytes "<-" value: Account "}}"
                 [ function, total, klabel(MapBytesToAccount:primitiveUpdate), symbol,
                   prefer
                 ]
  syntax MapBytesToAccount ::= MapBytesToAccount "{{" Bytes "<-" "undef" "}}"
                 [ function, total, klabel(MapBytesToAccount:primitiveRemove), symbol ]
  syntax Bool ::= Bytes "in_keys" "{{" MapBytesToAccount "}}"
                 [function, total, klabel(MapBytesToAccount:primitiveInKeys)]

  // Definitions
  // -----------

  rule (wrap(Key) Bytes2Account|-> V:Account M:MapBytesToAccount)
          {{ Key:Bytes }}
      => V
      ensures notBool Key in_keys {{ M }}

  rule (wrap(Key) Bytes2Account|-> V:Account M:MapBytesToAccount)
          {{ Key:Bytes }} orDefault _:Account
      => V
      ensures notBool Key in_keys {{ M }}
  rule M:MapBytesToAccount {{ Key:Bytes }} orDefault V:Account
      => V
      requires notBool Key in_keys {{ M }}

  rule (wrap(Key) Bytes2Account|-> _:Account M:MapBytesToAccount)
          {{ Key:Bytes <- Value:Account }}
      => (wrap(Key) Bytes2Account|-> Value) M
  rule M:MapBytesToAccount {{ Key:Bytes <- Value:Account }}
      => (wrap(Key) Bytes2Account|-> Value) M
      requires notBool Key in_keys {{ M }}

  rule (wrap(Key) Bytes2Account|-> _:Account M:MapBytesToAccount)
          {{ Key:Bytes <- undef }}
      => M
      ensures notBool Key in_keys {{ M }}
  rule M:MapBytesToAccount {{ Key:Bytes <- undef }}
      => M
      requires notBool Key in_keys {{ M }}

  rule Key:Bytes in_keys
          {{wrap(Key) Bytes2Account|-> _:Account M:MapBytesToAccount}}
      => true
      ensures notBool Key in_keys {{ M }}
  rule _Key:Bytes in_keys {{ .MapBytesToAccount }}
      => false
  rule Key:Bytes in_keys
          {{Key2:WrappedBytes Bytes2Account|-> _:Account M:MapBytesToAccount}}
      => true
      requires Key =/=K unwrap(Key2)
      ensures notBool Key2 in_keys (M)
      [simplification]

  // Translation rules
  rule M:MapBytesToAccount[Key:WrappedBytes]
      => M{{unwrap(Key)}}
      [simplification, symbolic(M)]
  rule M:MapBytesToAccount[Key:WrappedBytes]
      => M{{unwrap(Key)}}
      [simplification, symbolic(Key)]
  rule M:MapBytesToAccount{{Key}}
      => M[wrap(Key)]
      [simplification, concrete]

  rule M:MapBytesToAccount [ Key:WrappedBytes ] orDefault Value:Account
      => M {{ unwrap(Key) }} orDefault Value
      [simplification, symbolic(M)]
  rule M:MapBytesToAccount [ Key:WrappedBytes ] orDefault Value:Account
      => M {{ unwrap(Key) }} orDefault Value
      [simplification, symbolic(Key)]
  rule M:MapBytesToAccount [ Key:WrappedBytes ] orDefault Value:Account
      => M {{ unwrap(Key) }} orDefault Value
      [simplification, symbolic(Value)]
  rule M:MapBytesToAccount{{Key}} orDefault Value
      => M[wrap(Key)] orDefault Value
      [simplification, concrete]

  rule M:MapBytesToAccount[Key:WrappedBytes <- Value:Account]
      => M {{ unwrap(Key) <- Value }}
      [simplification, symbolic(M)]
  rule M:MapBytesToAccount[Key:WrappedBytes <- Value:Account]
      => M {{ unwrap(Key) <- Value }}
      [simplification, symbolic(Key)]
  rule M:MapBytesToAccount[Key:WrappedBytes <- Value:Account]
      => M {{ unwrap(Key) <- Value }}
      [simplification, symbolic(Value)]
  rule M:MapBytesToAccount{{Key <- Value}} => M[wrap(Key) <- Value ]
      [simplification, concrete]

  rule M:MapBytesToAccount[Key:WrappedBytes <- undef]
      => M {{ unwrap(Key) <- undef }}
      [simplification, symbolic(M)]
  rule M:MapBytesToAccount[Key:WrappedBytes <- undef]
      => M {{ unwrap(Key) <- undef }}
      [simplification, symbolic(Key)]
  rule M:MapBytesToAccount{{Key <- undef}} => M[wrap(Key) <- undef]
      [simplification, concrete]

  rule Key:WrappedBytes in_keys (M:MapBytesToAccount)
      => unwrap(Key) in_keys {{M}}
      [simplification, symbolic(M)]
  rule Key:WrappedBytes in_keys (M:MapBytesToAccount)
      => unwrap(Key) in_keys {{M}}
      [simplification, symbolic(Key)]
  rule Key in_keys {{M:MapBytesToAccount}} => wrap(Key) in_keys(M)
      [simplification, concrete]

  // Symbolic execution rules
  // ------------------------
  syntax Bool ::= definedPrimitiveLookup(MapBytesToAccount, Bytes)  [function, total]
  rule definedPrimitiveLookup(M:MapBytesToAccount, K:Bytes) => K in_keys{{M}}

  rule #Ceil(@M:MapBytesToAccount {{@K:Bytes}})
      => {definedPrimitiveLookup(@M, @K) #Equals true}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule M:MapBytesToAccount {{ K <- _ }} {{ K <- V }} => M {{ K <- V }} [simplification]
  rule (K1 Bytes2Account|-> V1 M:MapBytesToAccount) {{ K2 <- V2 }}
      => (K1 Bytes2Account|-> V1 (M {{ K2 <- V2 }}))
      requires unwrap(K1) =/=K K2
      [simplification]

  rule (K1 Bytes2Account|-> V1 M:MapBytesToAccount) {{ K2 <- undef }}
      => (K1 Bytes2Account|-> V1 (M {{ K2 <- undef }}))
      requires unwrap(K1) =/=K K2
      [simplification]

  rule (K1 Bytes2Account|-> _V M:MapBytesToAccount) {{ K2 }} => M {{K2}}
      requires unwrap(K1) =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapBytesToAccount {{ K  <-  V1 }}) {{ K }}  => V1 [simplification]
  rule ( MAP:MapBytesToAccount {{ K1 <- _V1 }}) {{ K2 }} => MAP {{ K2 }}
      requires K1 =/=K K2
      [simplification]

  rule (K1 Bytes2Account|-> _V M:MapBytesToAccount) {{ K2 }} orDefault D
      => M {{K2}} orDefault D
      requires unwrap(K1) =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapBytesToAccount {{ K  <-  V1 }}) {{ K }} orDefault _ => V1 [simplification]
  rule ( MAP:MapBytesToAccount {{ K1 <- _V1 }}) {{ K2 }} orDefault D
      => MAP {{ K2 }} orDefault D
      requires K1 =/=K K2
      [simplification]

  rule K in_keys{{_M:MapBytesToAccount {{ K <- undef }} }} => false [simplification]
  rule K in_keys{{_M:MapBytesToAccount {{ K <- _ }} }} => true [simplification]
  rule K1 in_keys{{ M:MapBytesToAccount {{ K2 <- _ }} }}
      => true requires K1 ==K K2 orBool K1 in_keys{{M}}
      [simplification]
  rule K1 in_keys{{ M:MapBytesToAccount {{ K2 <- _ }} }}
      => K1 in_keys {{ M }}
      requires K1 =/=K K2
      [simplification]

  rule K1 in_keys {{ (K2 Bytes2Account|-> V) M:MapBytesToAccount }}
      => K1 ==K unwrap(K2) orBool K1 in_keys {{ M }}
    requires definedMapElementConcat(K2, V, M)
    [simplification(100)]
      

  rule {false #Equals @Key in_keys{{ Key' Bytes2Account|-> Val @M:MapBytesToAccount }}}
      =>  #Ceil(@Key) #And #Ceil(Key' Bytes2Account|-> Val @M)
          #And #Not({ @Key #Equals unwrap(Key') })
          #And {false #Equals @Key in_keys{{@M}}}
      [simplification]
  rule {@Key in_keys{{Key' Bytes2Account|-> Val @M:MapBytesToAccount}} #Equals false}
      =>  #Ceil(@Key) #And #Ceil(Key' Bytes2Account|-> Val @M)
          #And #Not({@Key #Equals unwrap(Key') })
          #And {@Key in_keys{{@M}} #Equals false}
      [simplification]

endmodule

module MAP-BYTES-TO-ACCOUNT-KORE-SYMBOLIC
  imports MAP-BYTES-TO-ACCOUNT
  imports private K-EQUAL
  imports private BOOL

  syntax Bool ::= definedMapElementConcat(WrappedBytes, Account, MapBytesToAccount)  [function, total]
  rule definedMapElementConcat(K, _V, M:MapBytesToAccount) => notBool K in_keys(M)

  rule #Ceil(@M:MapBytesToAccount [@K:WrappedBytes])
      => {(@K in_keys(@M)) #Equals true}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule (K Bytes2Account|-> _ M:MapBytesToAccount) [ K <- V ] => (K Bytes2Account|-> V M) [simplification]
  rule M:MapBytesToAccount [ K <- V ] => (K Bytes2Account|-> V M) requires notBool (K in_keys(M))
      [simplification]
  rule M:MapBytesToAccount [ K <- _ ] [ K <- V ] => M [ K <- V ] [simplification]
  rule (K1 Bytes2Account|-> V1 M:MapBytesToAccount) [ K2 <- V2 ] => (K1 Bytes2Account|-> V1 (M [ K2 <- V2 ]))
      requires K1 =/=K K2
      [simplification]

  rule (K Bytes2Account|-> _ M:MapBytesToAccount) [ K <- undef ] => M
      ensures notBool (K in_keys(M))
      [simplification]
  rule M:MapBytesToAccount [ K <- undef ] => M
      requires notBool (K in_keys(M))
      [simplification]
  rule (K1 Bytes2Account|-> V1 M:MapBytesToAccount) [ K2 <- undef ]
      => (K1 Bytes2Account|-> V1 (M [ K2 <- undef ]))
      requires K1 =/=K K2
      [simplification]

  rule (K  Bytes2Account|->  V M:MapBytesToAccount) [ K ] => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Bytes2Account|-> _V M:MapBytesToAccount) [ K2 ] => M [K2]
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapBytesToAccount [ K  <-  V1 ]) [ K ]  => V1 [simplification]
  rule ( MAP:MapBytesToAccount [ K1 <- _V1 ]) [ K2 ] => MAP [ K2 ]
      requires K1 =/=K K2
      [simplification]

  rule (K  Bytes2Account|->  V M:MapBytesToAccount) [  K ] orDefault _ => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Bytes2Account|-> _V M:MapBytesToAccount) [ K2 ] orDefault D
      => M [K2] orDefault D
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapBytesToAccount [ K  <-  V1 ]) [ K ] orDefault _ => V1 [simplification]
  rule ( MAP:MapBytesToAccount [ K1 <- _V1 ]) [ K2 ] orDefault D
      => MAP [ K2 ] orDefault D
      requires K1 =/=K K2
      [simplification]
  rule .MapBytesToAccount [ _ ] orDefault D => D [simplification]

  rule K in_keys(_M:MapBytesToAccount [ K <- undef ]) => false [simplification]
  rule K in_keys(_M:MapBytesToAccount [ K <- _ ]) => true [simplification]
  rule K1 in_keys(M:MapBytesToAccount [ K2 <- _ ])
      => true requires K1 ==K K2 orBool K1 in_keys(M)
      [simplification]
  rule K1 in_keys(M:MapBytesToAccount [ K2 <- _ ])
      => K1 in_keys(M)
      requires K1 =/=K K2
      [simplification]

  rule K in_keys((K Bytes2Account|-> V) M:MapBytesToAccount)
      => true
    requires definedMapElementConcat(K, V, M)
    [simplification(50)]
  rule K1 in_keys((K2 Bytes2Account|-> V) M:MapBytesToAccount)
      => K1 in_keys(M)
    requires true
        andBool definedMapElementConcat(K2, V, M)
        andBool K1 =/=K K2
    [simplification(50)]
  rule K1 in_keys((K2 Bytes2Account|-> V) M:MapBytesToAccount)
      => K1 ==K K2 orBool K1 in_keys(M)
    requires definedMapElementConcat(K2, V, M)
    [simplification(100)]
      

  rule {false #Equals @Key in_keys(.MapBytesToAccount)} => #Ceil(@Key) [simplification]
  rule {@Key in_keys(.MapBytesToAccount) #Equals false} => #Ceil(@Key) [simplification]
  rule {false #Equals @Key in_keys(Key' Bytes2Account|-> Val @M:MapBytesToAccount)}
      =>  #Ceil(@Key) #And #Ceil(Key' Bytes2Account|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {false #Equals @Key in_keys(@M)}
      [simplification]
  rule {@Key in_keys(Key' Bytes2Account|-> Val @M:MapBytesToAccount) #Equals false}
      =>  #Ceil(@Key) #And #Ceil(Key' Bytes2Account|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {@Key in_keys(@M) #Equals false}
      [simplification]
endmodule

module MAP-BYTES-TO-ACCOUNT-CURLY-BRACE
  imports private BOOL
  imports private K-EQUAL-SYNTAX
  imports MAP-BYTES-TO-ACCOUNT

  syntax MapBytesToAccount ::= MapBytesToAccount "{" key:WrappedBytes "<-" value:Account "}"
      [function, total, klabel(MapBytesToAccount:curly_update), symbol]
  rule M:MapBytesToAccount{Key <- Value} => M (Key Bytes2Account|-> Value)
    requires notBool Key in_keys(M)
  rule (Key Bytes2Account|-> _ M:MapBytesToAccount){Key <- Value}
      => M (Key Bytes2Account|-> Value)
  rule (M:MapBytesToAccount{Key <- Value})(A Bytes2Account|-> B N:MapBytesToAccount)
      => (M (A Bytes2Account|-> B)) {Key <- Value} N
      requires notBool A ==K Key
      [simplification]

  rule M:MapBytesToAccount{Key1 <- Value1}[Key2 <- Value2]
      => ((M:MapBytesToAccount[Key2 <- Value2]{Key1 <- Value1}) #And #Not ({Key1 #Equals Key2}))
        #Or ((M:MapBytesToAccount[Key2 <- Value2]) #And {Key1 #Equals Key2})
      [simplification(20)]
  rule M:MapBytesToAccount[Key <- Value]
      => M:MapBytesToAccount{Key <- Value}
      [simplification(100)]
  rule M:MapBytesToAccount{Key1 <- _Value1}[Key2] orDefault Value2
      => M[Key2] orDefault Value2
      requires Key1 =/=K Key2
      [simplification]
  rule _M:MapBytesToAccount{Key <- Value1}[Key] orDefault _Value2
      => Value1
      [simplification]
  // rule M:MapBytesToAccount{Key1 <- Value1}[Key2] orDefault Value2
  //     => (M[Key2] orDefault Value2 #And #Not ({Key1 #Equals Key2}))
  //       #Or (Value1 #And {Key1 #Equals Key2})
  //     [simplification]
  rule M:MapBytesToAccount{Key1 <- Value1}[Key2]
      => (M[Key2] #And #Not ({Key1 #Equals Key2}))
        #Or (Value1 #And {Key1 #Equals Key2})
      [simplification]

  rule Key1 in_keys(_:MapBytesToAccount{Key1 <- _})
      => true
      [simplification(50)]
  rule Key1 in_keys(M:MapBytesToAccount{Key2 <- _})
      => Key1 in_keys(M)
      requires notBool Key1 ==K Key2
      [simplification(50)]
  rule K1 in_keys(M:MapBytesToAccount { K2 <- _ })
      => K1 ==K K2 orBool K1 in_keys(M)
    [simplification(100)]
      
endmodule
