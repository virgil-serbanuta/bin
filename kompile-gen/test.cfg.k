

module LIST-BYTESW
  imports private INT-SYNTAX
  imports private BASIC-K

  syntax Bytesw

  syntax ListBytesw [hook(LIST.List)]
  syntax ListBytesw ::= ListBytesw ListBytesw
          [ left, function, total, hook(LIST.concat),
            klabel(_ListBytesw_), symbol, smtlib(smt_seq_concat),
            assoc, unit(.ListBytesw), element(ListByteswItem),
            format(%1%n%2)
          ]
  syntax ListBytesw ::= ".ListBytesw"
          [ function, total, hook(LIST.unit), klabel(.ListBytesw),
            symbol, smtlib(smt_seq_nil), latex(\dotCt{ListBytesw})
          ]
  syntax ListBytesw ::= ListItem(Bytesw)
          [ function, total, hook(LIST.element), klabel(ListByteswItem),
            symbol, smtlib(smt_seq_elem)
          ]
  syntax Bytesw ::= ListBytesw "[" Int "]"
          [ function, hook(LIST.get), klabel(ListBytesw:get), symbol ]
  syntax ListBytesw ::= ListBytesw "[" index: Int "<-" value: Bytesw "]"
          [function, hook(LIST.update), klabel(ListBytesw:set)]
  syntax ListBytesw ::= makeListBytesw(length: Int, value: Bytesw)
          [function, hook(LIST.make)]
  syntax ListBytesw ::= updateList(dest: ListBytesw, index: Int, src: ListBytesw)
          [function, hook(LIST.updateAll)]
  syntax ListBytesw ::= fillList(ListBytesw, index: Int, length: Int, value: Bytesw)
          [function, hook(LIST.fill)]
  syntax ListBytesw ::= range(ListBytesw, fromFront: Int, fromBack: Int)
          [function, hook(LIST.range), klabel(ListBytesw:range), symbol]
  syntax Bool ::= Bytesw "in" ListBytesw
          [function, total, hook(LIST.in), klabel(_inListBytesw_)]
  syntax Int ::= size(ListBytesw)
          [function, total, hook(LIST.size), klabel (sizeListBytesw), smtlib(smt_seq_len)]
endmodule

module LIST-BYTESW-EXTENSIONS
  imports BOOL
  imports INT
  imports LIST-BYTESW

  syntax Bytesw ::= ListBytesw "[" Int "]" "orDefault" Bytesw
          [ function, total, klabel(ListBytesw:getOrDefault), symbol ]

  rule ListItem(V:Bytesw) _:ListBytesw [0] orDefault _:Bytesw
      => V
  rule _:ListBytesw ListItem(V:Bytesw) [-1] orDefault _:Bytesw
      => V
  rule .ListBytesw [_:Int] orDefault D:Bytesw => D

  rule ListItem(_:Bytesw) L:ListBytesw [I:Int] orDefault D:Bytesw
      => L[I -Int 1] orDefault D
    requires 0 <Int I
  rule L:ListBytesw ListItem(_:Bytesw) [I:Int] orDefault D:Bytesw
      => L[I +Int 1] orDefault D
    requires I <Int 0

  rule L:ListBytesw[I:Int] orDefault D:Bytesw => D
    requires notBool (0 -Int size(L) <=Int I andBool I <Int size(L))
    [simplification]
endmodule



module LIST-ESDTTRANSFER
  imports private INT-SYNTAX
  imports private BASIC-K

  syntax ESDTTransfer

  syntax ListESDTTransfer [hook(LIST.List)]
  syntax ListESDTTransfer ::= ListESDTTransfer ListESDTTransfer
          [ left, function, total, hook(LIST.concat),
            klabel(_ListESDTTransfer_), symbol, smtlib(smt_seq_concat),
            assoc, unit(.ListESDTTransfer), element(ListESDTTransferItem),
            format(%1%n%2)
          ]
  syntax ListESDTTransfer ::= ".ListESDTTransfer"
          [ function, total, hook(LIST.unit), klabel(.ListESDTTransfer),
            symbol, smtlib(smt_seq_nil), latex(\dotCt{ListESDTTransfer})
          ]
  syntax ListESDTTransfer ::= ListItem(ESDTTransfer)
          [ function, total, hook(LIST.element), klabel(ListESDTTransferItem),
            symbol, smtlib(smt_seq_elem)
          ]
  syntax ESDTTransfer ::= ListESDTTransfer "[" Int "]"
          [ function, hook(LIST.get), klabel(ListESDTTransfer:get), symbol ]
  syntax ListESDTTransfer ::= ListESDTTransfer "[" index: Int "<-" value: ESDTTransfer "]"
          [function, hook(LIST.update), klabel(ListESDTTransfer:set)]
  syntax ListESDTTransfer ::= makeListESDTTransfer(length: Int, value: ESDTTransfer)
          [function, hook(LIST.make)]
  syntax ListESDTTransfer ::= updateList(dest: ListESDTTransfer, index: Int, src: ListESDTTransfer)
          [function, hook(LIST.updateAll)]
  syntax ListESDTTransfer ::= fillList(ListESDTTransfer, index: Int, length: Int, value: ESDTTransfer)
          [function, hook(LIST.fill)]
  syntax ListESDTTransfer ::= range(ListESDTTransfer, fromFront: Int, fromBack: Int)
          [function, hook(LIST.range), klabel(ListESDTTransfer:range), symbol]
  syntax Bool ::= ESDTTransfer "in" ListESDTTransfer
          [function, total, hook(LIST.in), klabel(_inListESDTTransfer_)]
  syntax Int ::= size(ListESDTTransfer)
          [function, total, hook(LIST.size), klabel (sizeListESDTTransfer), smtlib(smt_seq_len)]
endmodule

module LIST-ESDTTRANSFER-EXTENSIONS
  imports BOOL
  imports INT
  imports LIST-ESDTTRANSFER

  syntax ESDTTransfer ::= ListESDTTransfer "[" Int "]" "orDefault" ESDTTransfer
          [ function, total, klabel(ListESDTTransfer:getOrDefault), symbol ]

  rule ListItem(V:ESDTTransfer) _:ListESDTTransfer [0] orDefault _:ESDTTransfer
      => V
  rule _:ListESDTTransfer ListItem(V:ESDTTransfer) [-1] orDefault _:ESDTTransfer
      => V
  rule .ListESDTTransfer [_:Int] orDefault D:ESDTTransfer => D

  rule ListItem(_:ESDTTransfer) L:ListESDTTransfer [I:Int] orDefault D:ESDTTransfer
      => L[I -Int 1] orDefault D
    requires 0 <Int I
  rule L:ListESDTTransfer ListItem(_:ESDTTransfer) [I:Int] orDefault D:ESDTTransfer
      => L[I +Int 1] orDefault D
    requires I <Int 0

  rule L:ListESDTTransfer[I:Int] orDefault D:ESDTTransfer => D
    requires notBool (0 -Int size(L) <=Int I andBool I <Int size(L))
    [simplification]
endmodule





module MAP-ADDRESSTOKENNONCE-TO-ESDTTOKENDATA
  imports private BOOL-SYNTAX
  imports private INT-SYNTAX
  // imports private LIST-ADDRESSTOKENNONCE
  // imports private LIST-ESDTTOKENDATA
  imports private LIST
  // imports private SET-ADDRESSTOKENNONCE
  imports private SET

  syntax AddressTokenNonce
  syntax ESDTTokenData

  syntax MapAddressTokenNonceToESDTTokenData [hook(MAP.Map)]
  syntax MapAddressTokenNonceToESDTTokenData ::= MapAddressTokenNonceToESDTTokenData MapAddressTokenNonceToESDTTokenData
         [ left, function, hook(MAP.concat), klabel(_MapAddressTokenNonceToESDTTokenData_),
           symbol, assoc, comm, unit(.MapAddressTokenNonceToESDTTokenData), element(_AddressTokenNonce2ESDTTokenData|->_),
           index(0), format(%1%n%2)
         ]
  syntax MapAddressTokenNonceToESDTTokenData ::= ".MapAddressTokenNonceToESDTTokenData"
         [ function, total, hook(MAP.unit),
           klabel(.MapAddressTokenNonceToESDTTokenData), symbol, latex(\dotCt{MapAddressTokenNonceToESDTTokenData})
         ]
  syntax MapAddressTokenNonceToESDTTokenData ::= AddressTokenNonce "AddressTokenNonce2ESDTTokenData|->" ESDTTokenData
         [ function, total, hook(MAP.element),
           klabel(_AddressTokenNonce2ESDTTokenData|->_), symbol,
           latex({#1}\mapsto{#2}), injective
         ]

  syntax priorities _AddressTokenNonce2ESDTTokenData|->_ > _MapAddressTokenNonceToESDTTokenData_ .MapAddressTokenNonceToESDTTokenData
  syntax non-assoc _AddressTokenNonce2ESDTTokenData|->_
  syntax ESDTTokenData ::= MapAddressTokenNonceToESDTTokenData "[" AddressTokenNonce "]"
                 [function, hook(MAP.lookup), klabel(MapAddressTokenNonceToESDTTokenData:lookup), symbol]
  syntax ESDTTokenData ::= MapAddressTokenNonceToESDTTokenData "[" AddressTokenNonce "]" "orDefault" ESDTTokenData
                 [ function, total, hook(MAP.lookupOrDefault),
                   klabel(MapAddressTokenNonceToESDTTokenData:lookupOrDefault)
                 ]
  syntax MapAddressTokenNonceToESDTTokenData ::= MapAddressTokenNonceToESDTTokenData "[" key: AddressTokenNonce "<-" value: ESDTTokenData "]"
                 [ function, total, klabel(MapAddressTokenNonceToESDTTokenData:update), symbol,
                   hook(MAP.update), prefer
                 ]
  syntax MapAddressTokenNonceToESDTTokenData ::= MapAddressTokenNonceToESDTTokenData "[" AddressTokenNonce "<-" "undef" "]"
                 [ function, total, hook(MAP.remove),
                   klabel(_MapAddressTokenNonceToESDTTokenData[_<-undef]), symbol
                 ]
  syntax MapAddressTokenNonceToESDTTokenData ::= MapAddressTokenNonceToESDTTokenData "-Map" MapAddressTokenNonceToESDTTokenData
                 [ function, total, hook(MAP.difference),
                   latex({#1}-_{\it MapAddressTokenNonceToESDTTokenDataMap}{#2})
                 ]
  syntax MapAddressTokenNonceToESDTTokenData ::= updateMap(MapAddressTokenNonceToESDTTokenData, MapAddressTokenNonceToESDTTokenData)
                 [function, total, hook(MAP.updateAll)]

  syntax MapAddressTokenNonceToESDTTokenData ::= removeAll(MapAddressTokenNonceToESDTTokenData, Set)
                 [function, total, hook(MAP.removeAll)]
  // syntax MapAddressTokenNonceToESDTTokenData ::= removeAll(MapAddressTokenNonceToESDTTokenData, SetAddressTokenNonce)
  //                [function, total, hook(MAP.removeAll)]

  syntax Set ::= keys(MapAddressTokenNonceToESDTTokenData)
                 [function, total, hook(MAP.keys)]
  // syntax SetAddressTokenNonce ::= keys(MapAddressTokenNonceToESDTTokenData)
  //                [function, total, hook(MAP.keys)]

  syntax List ::= "keys_list" "(" MapAddressTokenNonceToESDTTokenData ")"
                 [function, hook(MAP.keys_list)]
  // syntax ListAddressTokenNonce ::= "keys_list" "(" MapAddressTokenNonceToESDTTokenData ")"
  //                [function, hook(MAP.keys_list)]

  syntax Bool ::= AddressTokenNonce "in_keys" "(" MapAddressTokenNonceToESDTTokenData ")"
                 [function, total, hook(MAP.in_keys)]

  syntax List ::= values(MapAddressTokenNonceToESDTTokenData)
                 [function, hook(MAP.values)]
  // syntax ListESDTTokenData ::= values(MapAddressTokenNonceToESDTTokenData)
  //                [function, hook(MAP.values)]

  syntax Int ::= size(MapAddressTokenNonceToESDTTokenData)
                 [function, total, hook(MAP.size), klabel(MapAddressTokenNonceToESDTTokenData.sizeMap)]
  syntax Bool ::= MapAddressTokenNonceToESDTTokenData "<=Map" MapAddressTokenNonceToESDTTokenData
                 [function, total, hook(MAP.inclusion)]
  syntax AddressTokenNonce ::= choice(MapAddressTokenNonceToESDTTokenData)
                 [function, hook(MAP.choice), klabel(MapAddressTokenNonceToESDTTokenData:choice)]
endmodule

module MAP-ADDRESSTOKENNONCE-TO-ESDTTOKENDATA-KORE-SYMBOLIC
  imports MAP-ADDRESSTOKENNONCE-TO-ESDTTOKENDATA
  imports private K-EQUAL
  imports private BOOL

  syntax Bool ::= definedMapElementConcat(AddressTokenNonce, ESDTTokenData, MapAddressTokenNonceToESDTTokenData)  [function, total]
  rule definedMapElementConcat(K, _V, M:MapAddressTokenNonceToESDTTokenData) => notBool K in_keys(M)

  rule #Ceil(@M:MapAddressTokenNonceToESDTTokenData [@K:AddressTokenNonce])
      => {(@K in_keys(@M)) #Equals true}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule (K AddressTokenNonce2ESDTTokenData|-> _ M:MapAddressTokenNonceToESDTTokenData) [ K <- V ] => (K AddressTokenNonce2ESDTTokenData|-> V M) [simplification]
  rule M:MapAddressTokenNonceToESDTTokenData [ K <- V ] => (K AddressTokenNonce2ESDTTokenData|-> V M) requires notBool (K in_keys(M))
      [simplification]
  rule M:MapAddressTokenNonceToESDTTokenData [ K <- _ ] [ K <- V ] => M [ K <- V ] [simplification]
  rule (K1 AddressTokenNonce2ESDTTokenData|-> V1 M:MapAddressTokenNonceToESDTTokenData) [ K2 <- V2 ] => (K1 AddressTokenNonce2ESDTTokenData|-> V1 (M [ K2 <- V2 ]))
      requires K1 =/=K K2
      [simplification]

  rule (K AddressTokenNonce2ESDTTokenData|-> _ M:MapAddressTokenNonceToESDTTokenData) [ K <- undef ] => M
      ensures notBool (K in_keys(M))
      [simplification]
  rule M:MapAddressTokenNonceToESDTTokenData [ K <- undef ] => M
      requires notBool (K in_keys(M))
      [simplification]
  rule (K1 AddressTokenNonce2ESDTTokenData|-> V1 M:MapAddressTokenNonceToESDTTokenData) [ K2 <- undef ]
      => (K1 AddressTokenNonce2ESDTTokenData|-> V1 (M [ K2 <- undef ]))
      requires K1 =/=K K2
      [simplification]

  rule (K  AddressTokenNonce2ESDTTokenData|->  V M:MapAddressTokenNonceToESDTTokenData) [ K ] => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 AddressTokenNonce2ESDTTokenData|-> _V M:MapAddressTokenNonceToESDTTokenData) [ K2 ] => M [K2]
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapAddressTokenNonceToESDTTokenData [ K  <-  V1 ]) [ K ]  => V1 [simplification]
  rule ( MAP:MapAddressTokenNonceToESDTTokenData [ K1 <- _V1 ]) [ K2 ] => MAP [ K2 ]
      requires K1 =/=K K2
      [simplification]

  rule (K  AddressTokenNonce2ESDTTokenData|->  V M:MapAddressTokenNonceToESDTTokenData) [  K ] orDefault _ => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 AddressTokenNonce2ESDTTokenData|-> _V M:MapAddressTokenNonceToESDTTokenData) [ K2 ] orDefault D
      => M [K2] orDefault D
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapAddressTokenNonceToESDTTokenData [ K  <-  V1 ]) [ K ] orDefault _ => V1 [simplification]
  rule ( MAP:MapAddressTokenNonceToESDTTokenData [ K1 <- _V1 ]) [ K2 ] orDefault D
      => MAP [ K2 ] orDefault D
      requires K1 =/=K K2
      [simplification]
  rule .MapAddressTokenNonceToESDTTokenData [ _ ] orDefault D => D [simplification]

  rule K in_keys(_M:MapAddressTokenNonceToESDTTokenData [ K <- undef ]) => false [simplification]
  rule K in_keys(_M:MapAddressTokenNonceToESDTTokenData [ K <- _ ]) => true [simplification]
  rule K1 in_keys(M:MapAddressTokenNonceToESDTTokenData [ K2 <- _ ])
      => true requires K1 ==K K2 orBool K1 in_keys(M)
      [simplification]
  rule K1 in_keys(M:MapAddressTokenNonceToESDTTokenData [ K2 <- _ ])
      => K1 in_keys(M)
      requires K1 =/=K K2
      [simplification]

  rule K in_keys((K AddressTokenNonce2ESDTTokenData|-> V) M:MapAddressTokenNonceToESDTTokenData)
      => true
    requires definedMapElementConcat(K2, V, M)
    [simplification(50)]
  rule K1 in_keys((K2 AddressTokenNonce2ESDTTokenData|-> V) M:MapAddressTokenNonceToESDTTokenData)
      => K1 in_keys(M)
    requires true
        andBool definedMapElementConcat(K2, V, M)
        andBool K1 =/=K K2
    [simplification(50)]
  rule K1 in_keys((K2 AddressTokenNonce2ESDTTokenData|-> V) M:MapAddressTokenNonceToESDTTokenData)
      => K1 ==K K2 orBool K1 in_keys(M)
    requires definedMapElementConcat(K2, V, M)
    [simplification(100)]
      

  rule {false #Equals @Key in_keys(.MapAddressTokenNonceToESDTTokenData)} => #Ceil(@Key) [simplification]
  rule {@Key in_keys(.MapAddressTokenNonceToESDTTokenData) #Equals false} => #Ceil(@Key) [simplification]
  rule {false #Equals @Key in_keys(Key' AddressTokenNonce2ESDTTokenData|-> Val @M:MapAddressTokenNonceToESDTTokenData)}
      =>  #Ceil(@Key) #And #Ceil(Key' AddressTokenNonce2ESDTTokenData|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {false #Equals @Key in_keys(@M)}
      [simplification]
  rule {@Key in_keys(Key' AddressTokenNonce2ESDTTokenData|-> Val @M:MapAddressTokenNonceToESDTTokenData) #Equals false}
      =>  #Ceil(@Key) #And #Ceil(Key' AddressTokenNonce2ESDTTokenData|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {@Key in_keys(@M) #Equals false}
      [simplification]
endmodule

module MAP-ADDRESSTOKENNONCE-TO-ESDTTOKENDATA-CURLY-BRACE
  imports private BOOL
  imports private K-EQUAL-SYNTAX
  imports MAP-ADDRESSTOKENNONCE-TO-ESDTTOKENDATA

  syntax MapAddressTokenNonceToESDTTokenData ::= MapAddressTokenNonceToESDTTokenData "{" key:AddressTokenNonce "<-" value:ESDTTokenData "}"
      [function, total, klabel(MapAddressTokenNonceToESDTTokenData:curly_update), symbol]
  rule M:MapAddressTokenNonceToESDTTokenData{Key <- Value} => M (Key AddressTokenNonce2ESDTTokenData|-> Value)
    requires notBool Key in_keys(M)
  rule (Key AddressTokenNonce2ESDTTokenData|-> _ M:MapAddressTokenNonceToESDTTokenData){Key <- Value}
      => M (Key AddressTokenNonce2ESDTTokenData|-> Value)
  rule (M:MapAddressTokenNonceToESDTTokenData{Key <- Value})(A AddressTokenNonce2ESDTTokenData|-> B N:MapAddressTokenNonceToESDTTokenData)
      => (M (A AddressTokenNonce2ESDTTokenData|-> B)) {Key <- Value} N
      requires notBool A ==K Key
      [simplification]

  rule M:MapAddressTokenNonceToESDTTokenData{Key1 <- Value1}[Key2 <- Value2]
      => ((M:MapAddressTokenNonceToESDTTokenData[Key2 <- Value2]{Key1 <- Value1}) #And #Not ({Key1 #Equals Key2}))
        #Or ((M:MapAddressTokenNonceToESDTTokenData[Key2 <- Value2]) #And {Key1 #Equals Key2})
      [simplification(20)]
  rule M:MapAddressTokenNonceToESDTTokenData[Key <- Value]
      => M:MapAddressTokenNonceToESDTTokenData{Key <- Value}
      [simplification(100)]
  rule M:MapAddressTokenNonceToESDTTokenData{Key1 <- _Value1}[Key2] orDefault Value2
      => M[Key2] orDefault Value2
      requires Key1 =/=K Key2
      [simplification]
  rule _M:MapAddressTokenNonceToESDTTokenData{Key <- Value1}[Key] orDefault _Value2
      => Value1
      [simplification]
  // rule M:MapAddressTokenNonceToESDTTokenData{Key1 <- Value1}[Key2] orDefault Value2
  //     => (M[Key2] orDefault Value2 #And #Not ({Key1 #Equals Key2}))
  //       #Or (Value1 #And {Key1 #Equals Key2})
  //     [simplification]
  rule M:MapAddressTokenNonceToESDTTokenData{Key1 <- Value1}[Key2]
      => (M[Key2] #And #Not ({Key1 #Equals Key2}))
        #Or (Value1 #And {Key1 #Equals Key2})
      [simplification]

  rule Key1 in_keys(_:MapAddressTokenNonceToESDTTokenData{Key1 <- _})
      => true
      [simplification(50)]
  rule Key1 in_keys(M:MapAddressTokenNonceToESDTTokenData{Key2 <- _})
      => Key1 in_keys(M)
      requires notBool Key1 ==K Key2
      [simplification(50)]
  rule K1 in_keys(M:MapAddressTokenNonceToESDTTokenData { K2 <- _ })
      => K1 ==K K2 orBool K1 in_keys(M)
    [simplification(100)]
      
endmodule


module MAP-BYTESW-TO-BYTESW
  imports private BOOL-SYNTAX
  imports private INT-SYNTAX
  imports private LIST-BYTESW
  imports private LIST-BYTESW
  // imports private LIST
  // imports private SET-BYTESW
  imports private SET

  syntax Bytesw
  syntax Bytesw

  syntax MapByteswToBytesw [hook(MAP.Map)]
  syntax MapByteswToBytesw ::= MapByteswToBytesw MapByteswToBytesw
         [ left, function, hook(MAP.concat), klabel(_MapByteswToBytesw_),
           symbol, assoc, comm, unit(.MapByteswToBytesw), element(_Bytes2Bytes|->_),
           index(0), format(%1%n%2)
         ]
  syntax MapByteswToBytesw ::= ".MapByteswToBytesw"
         [ function, total, hook(MAP.unit),
           klabel(.MapByteswToBytesw), symbol, latex(\dotCt{MapByteswToBytesw})
         ]
  syntax MapByteswToBytesw ::= Bytesw "Bytes2Bytes|->" Bytesw
         [ function, total, hook(MAP.element),
           klabel(_Bytes2Bytes|->_), symbol,
           latex({#1}\mapsto{#2}), injective
         ]

  syntax priorities _Bytes2Bytes|->_ > _MapByteswToBytesw_ .MapByteswToBytesw
  syntax non-assoc _Bytes2Bytes|->_
  syntax Bytesw ::= MapByteswToBytesw "[" Bytesw "]"
                 [function, hook(MAP.lookup), klabel(MapByteswToBytesw:lookup), symbol]
  syntax Bytesw ::= MapByteswToBytesw "[" Bytesw "]" "orDefault" Bytesw
                 [ function, total, hook(MAP.lookupOrDefault),
                   klabel(MapByteswToBytesw:lookupOrDefault)
                 ]
  syntax MapByteswToBytesw ::= MapByteswToBytesw "[" key: Bytesw "<-" value: Bytesw "]"
                 [ function, total, klabel(MapByteswToBytesw:update), symbol,
                   hook(MAP.update), prefer
                 ]
  syntax MapByteswToBytesw ::= MapByteswToBytesw "[" Bytesw "<-" "undef" "]"
                 [ function, total, hook(MAP.remove),
                   klabel(_MapByteswToBytesw[_<-undef]), symbol
                 ]
  syntax MapByteswToBytesw ::= MapByteswToBytesw "-Map" MapByteswToBytesw
                 [ function, total, hook(MAP.difference),
                   latex({#1}-_{\it MapByteswToByteswMap}{#2})
                 ]
  syntax MapByteswToBytesw ::= updateMap(MapByteswToBytesw, MapByteswToBytesw)
                 [function, total, hook(MAP.updateAll)]

  syntax MapByteswToBytesw ::= removeAll(MapByteswToBytesw, Set)
                 [function, total, hook(MAP.removeAll)]
  // syntax MapByteswToBytesw ::= removeAll(MapByteswToBytesw, SetBytesw)
  //                [function, total, hook(MAP.removeAll)]

  syntax Set ::= keys(MapByteswToBytesw)
                 [function, total, hook(MAP.keys)]
  // syntax SetBytesw ::= keys(MapByteswToBytesw)
  //                [function, total, hook(MAP.keys)]

  // syntax List ::= "keys_list" "(" MapByteswToBytesw ")"
  //                [function, hook(MAP.keys_list)]
  syntax ListBytesw ::= "keys_list" "(" MapByteswToBytesw ")"
                 [function, hook(MAP.keys_list)]

  syntax Bool ::= Bytesw "in_keys" "(" MapByteswToBytesw ")"
                 [function, total, hook(MAP.in_keys)]

  // syntax List ::= values(MapByteswToBytesw)
  //                [function, hook(MAP.values)]
  syntax ListBytesw ::= values(MapByteswToBytesw)
                 [function, hook(MAP.values)]

  syntax Int ::= size(MapByteswToBytesw)
                 [function, total, hook(MAP.size), klabel(MapByteswToBytesw.sizeMap)]
  syntax Bool ::= MapByteswToBytesw "<=Map" MapByteswToBytesw
                 [function, total, hook(MAP.inclusion)]
  syntax Bytesw ::= choice(MapByteswToBytesw)
                 [function, hook(MAP.choice), klabel(MapByteswToBytesw:choice)]
endmodule

module MAP-BYTESW-TO-BYTESW-KORE-SYMBOLIC
  imports MAP-BYTESW-TO-BYTESW
  imports private K-EQUAL
  imports private BOOL

  syntax Bool ::= definedMapElementConcat(Bytesw, Bytesw, MapByteswToBytesw)  [function, total]
  rule definedMapElementConcat(K, _V, M:MapByteswToBytesw) => notBool K in_keys(M)

  rule #Ceil(@M:MapByteswToBytesw [@K:Bytesw])
      => {(@K in_keys(@M)) #Equals true}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule (K Bytes2Bytes|-> _ M:MapByteswToBytesw) [ K <- V ] => (K Bytes2Bytes|-> V M) [simplification]
  rule M:MapByteswToBytesw [ K <- V ] => (K Bytes2Bytes|-> V M) requires notBool (K in_keys(M))
      [simplification]
  rule M:MapByteswToBytesw [ K <- _ ] [ K <- V ] => M [ K <- V ] [simplification]
  rule (K1 Bytes2Bytes|-> V1 M:MapByteswToBytesw) [ K2 <- V2 ] => (K1 Bytes2Bytes|-> V1 (M [ K2 <- V2 ]))
      requires K1 =/=K K2
      [simplification]

  rule (K Bytes2Bytes|-> _ M:MapByteswToBytesw) [ K <- undef ] => M
      ensures notBool (K in_keys(M))
      [simplification]
  rule M:MapByteswToBytesw [ K <- undef ] => M
      requires notBool (K in_keys(M))
      [simplification]
  rule (K1 Bytes2Bytes|-> V1 M:MapByteswToBytesw) [ K2 <- undef ]
      => (K1 Bytes2Bytes|-> V1 (M [ K2 <- undef ]))
      requires K1 =/=K K2
      [simplification]

  rule (K  Bytes2Bytes|->  V M:MapByteswToBytesw) [ K ] => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Bytes2Bytes|-> _V M:MapByteswToBytesw) [ K2 ] => M [K2]
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapByteswToBytesw [ K  <-  V1 ]) [ K ]  => V1 [simplification]
  rule ( MAP:MapByteswToBytesw [ K1 <- _V1 ]) [ K2 ] => MAP [ K2 ]
      requires K1 =/=K K2
      [simplification]

  rule (K  Bytes2Bytes|->  V M:MapByteswToBytesw) [  K ] orDefault _ => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Bytes2Bytes|-> _V M:MapByteswToBytesw) [ K2 ] orDefault D
      => M [K2] orDefault D
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapByteswToBytesw [ K  <-  V1 ]) [ K ] orDefault _ => V1 [simplification]
  rule ( MAP:MapByteswToBytesw [ K1 <- _V1 ]) [ K2 ] orDefault D
      => MAP [ K2 ] orDefault D
      requires K1 =/=K K2
      [simplification]
  rule .MapByteswToBytesw [ _ ] orDefault D => D [simplification]

  rule K in_keys(_M:MapByteswToBytesw [ K <- undef ]) => false [simplification]
  rule K in_keys(_M:MapByteswToBytesw [ K <- _ ]) => true [simplification]
  rule K1 in_keys(M:MapByteswToBytesw [ K2 <- _ ])
      => true requires K1 ==K K2 orBool K1 in_keys(M)
      [simplification]
  rule K1 in_keys(M:MapByteswToBytesw [ K2 <- _ ])
      => K1 in_keys(M)
      requires K1 =/=K K2
      [simplification]

  rule K in_keys((K Bytes2Bytes|-> V) M:MapByteswToBytesw)
      => true
    requires definedMapElementConcat(K2, V, M)
    [simplification(50)]
  rule K1 in_keys((K2 Bytes2Bytes|-> V) M:MapByteswToBytesw)
      => K1 in_keys(M)
    requires true
        andBool definedMapElementConcat(K2, V, M)
        andBool K1 =/=K K2
    [simplification(50)]
  rule K1 in_keys((K2 Bytes2Bytes|-> V) M:MapByteswToBytesw)
      => K1 ==K K2 orBool K1 in_keys(M)
    requires definedMapElementConcat(K2, V, M)
    [simplification(100)]
      

  rule {false #Equals @Key in_keys(.MapByteswToBytesw)} => #Ceil(@Key) [simplification]
  rule {@Key in_keys(.MapByteswToBytesw) #Equals false} => #Ceil(@Key) [simplification]
  rule {false #Equals @Key in_keys(Key' Bytes2Bytes|-> Val @M:MapByteswToBytesw)}
      =>  #Ceil(@Key) #And #Ceil(Key' Bytes2Bytes|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {false #Equals @Key in_keys(@M)}
      [simplification]
  rule {@Key in_keys(Key' Bytes2Bytes|-> Val @M:MapByteswToBytesw) #Equals false}
      =>  #Ceil(@Key) #And #Ceil(Key' Bytes2Bytes|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {@Key in_keys(@M) #Equals false}
      [simplification]
endmodule

module MAP-BYTESW-TO-BYTESW-CURLY-BRACE
  imports private BOOL
  imports private K-EQUAL-SYNTAX
  imports MAP-BYTESW-TO-BYTESW

  syntax MapByteswToBytesw ::= MapByteswToBytesw "{" key:Bytesw "<-" value:Bytesw "}"
      [function, total, klabel(MapByteswToBytesw:curly_update), symbol]
  rule M:MapByteswToBytesw{Key <- Value} => M (Key Bytes2Bytes|-> Value)
    requires notBool Key in_keys(M)
  rule (Key Bytes2Bytes|-> _ M:MapByteswToBytesw){Key <- Value}
      => M (Key Bytes2Bytes|-> Value)
  rule (M:MapByteswToBytesw{Key <- Value})(A Bytes2Bytes|-> B N:MapByteswToBytesw)
      => (M (A Bytes2Bytes|-> B)) {Key <- Value} N
      requires notBool A ==K Key
      [simplification]

  rule M:MapByteswToBytesw{Key1 <- Value1}[Key2 <- Value2]
      => ((M:MapByteswToBytesw[Key2 <- Value2]{Key1 <- Value1}) #And #Not ({Key1 #Equals Key2}))
        #Or ((M:MapByteswToBytesw[Key2 <- Value2]) #And {Key1 #Equals Key2})
      [simplification(20)]
  rule M:MapByteswToBytesw[Key <- Value]
      => M:MapByteswToBytesw{Key <- Value}
      [simplification(100)]
  rule M:MapByteswToBytesw{Key1 <- _Value1}[Key2] orDefault Value2
      => M[Key2] orDefault Value2
      requires Key1 =/=K Key2
      [simplification]
  rule _M:MapByteswToBytesw{Key <- Value1}[Key] orDefault _Value2
      => Value1
      [simplification]
  // rule M:MapByteswToBytesw{Key1 <- Value1}[Key2] orDefault Value2
  //     => (M[Key2] orDefault Value2 #And #Not ({Key1 #Equals Key2}))
  //       #Or (Value1 #And {Key1 #Equals Key2})
  //     [simplification]
  rule M:MapByteswToBytesw{Key1 <- Value1}[Key2]
      => (M[Key2] #And #Not ({Key1 #Equals Key2}))
        #Or (Value1 #And {Key1 #Equals Key2})
      [simplification]

  rule Key1 in_keys(_:MapByteswToBytesw{Key1 <- _})
      => true
      [simplification(50)]
  rule Key1 in_keys(M:MapByteswToBytesw{Key2 <- _})
      => Key1 in_keys(M)
      requires notBool Key1 ==K Key2
      [simplification(50)]
  rule K1 in_keys(M:MapByteswToBytesw { K2 <- _ })
      => K1 ==K K2 orBool K1 in_keys(M)
    [simplification(100)]
      
endmodule


module MAP-TOKENNONCE-TO-INTW
  imports private BOOL-SYNTAX
  imports private INT-SYNTAX
  // imports private LIST-TOKENNONCE
  // imports private LIST-INTW
  imports private LIST
  // imports private SET-TOKENNONCE
  imports private SET

  syntax TokenNonce
  syntax Intw

  syntax MapTokenNonceToIntw [hook(MAP.Map)]
  syntax MapTokenNonceToIntw ::= MapTokenNonceToIntw MapTokenNonceToIntw
         [ left, function, hook(MAP.concat), klabel(_MapTokenNonceToIntw_),
           symbol, assoc, comm, unit(.MapTokenNonceToIntw), element(_TokenNonce2Int|->_),
           index(0), format(%1%n%2)
         ]
  syntax MapTokenNonceToIntw ::= ".MapTokenNonceToIntw"
         [ function, total, hook(MAP.unit),
           klabel(.MapTokenNonceToIntw), symbol, latex(\dotCt{MapTokenNonceToIntw})
         ]
  syntax MapTokenNonceToIntw ::= TokenNonce "TokenNonce2Int|->" Intw
         [ function, total, hook(MAP.element),
           klabel(_TokenNonce2Int|->_), symbol,
           latex({#1}\mapsto{#2}), injective
         ]

  syntax priorities _TokenNonce2Int|->_ > _MapTokenNonceToIntw_ .MapTokenNonceToIntw
  syntax non-assoc _TokenNonce2Int|->_
  syntax Intw ::= MapTokenNonceToIntw "[" TokenNonce "]"
                 [function, hook(MAP.lookup), klabel(MapTokenNonceToIntw:lookup), symbol]
  syntax Intw ::= MapTokenNonceToIntw "[" TokenNonce "]" "orDefault" Intw
                 [ function, total, hook(MAP.lookupOrDefault),
                   klabel(MapTokenNonceToIntw:lookupOrDefault)
                 ]
  syntax MapTokenNonceToIntw ::= MapTokenNonceToIntw "[" key: TokenNonce "<-" value: Intw "]"
                 [ function, total, klabel(MapTokenNonceToIntw:update), symbol,
                   hook(MAP.update), prefer
                 ]
  syntax MapTokenNonceToIntw ::= MapTokenNonceToIntw "[" TokenNonce "<-" "undef" "]"
                 [ function, total, hook(MAP.remove),
                   klabel(_MapTokenNonceToIntw[_<-undef]), symbol
                 ]
  syntax MapTokenNonceToIntw ::= MapTokenNonceToIntw "-Map" MapTokenNonceToIntw
                 [ function, total, hook(MAP.difference),
                   latex({#1}-_{\it MapTokenNonceToIntwMap}{#2})
                 ]
  syntax MapTokenNonceToIntw ::= updateMap(MapTokenNonceToIntw, MapTokenNonceToIntw)
                 [function, total, hook(MAP.updateAll)]

  syntax MapTokenNonceToIntw ::= removeAll(MapTokenNonceToIntw, Set)
                 [function, total, hook(MAP.removeAll)]
  // syntax MapTokenNonceToIntw ::= removeAll(MapTokenNonceToIntw, SetTokenNonce)
  //                [function, total, hook(MAP.removeAll)]

  syntax Set ::= keys(MapTokenNonceToIntw)
                 [function, total, hook(MAP.keys)]
  // syntax SetTokenNonce ::= keys(MapTokenNonceToIntw)
  //                [function, total, hook(MAP.keys)]

  syntax List ::= "keys_list" "(" MapTokenNonceToIntw ")"
                 [function, hook(MAP.keys_list)]
  // syntax ListTokenNonce ::= "keys_list" "(" MapTokenNonceToIntw ")"
  //                [function, hook(MAP.keys_list)]

  syntax Bool ::= TokenNonce "in_keys" "(" MapTokenNonceToIntw ")"
                 [function, total, hook(MAP.in_keys)]

  syntax List ::= values(MapTokenNonceToIntw)
                 [function, hook(MAP.values)]
  // syntax ListIntw ::= values(MapTokenNonceToIntw)
  //                [function, hook(MAP.values)]

  syntax Int ::= size(MapTokenNonceToIntw)
                 [function, total, hook(MAP.size), klabel(MapTokenNonceToIntw.sizeMap)]
  syntax Bool ::= MapTokenNonceToIntw "<=Map" MapTokenNonceToIntw
                 [function, total, hook(MAP.inclusion)]
  syntax TokenNonce ::= choice(MapTokenNonceToIntw)
                 [function, hook(MAP.choice), klabel(MapTokenNonceToIntw:choice)]
endmodule

module MAP-TOKENNONCE-TO-INTW-KORE-SYMBOLIC
  imports MAP-TOKENNONCE-TO-INTW
  imports private K-EQUAL
  imports private BOOL

  syntax Bool ::= definedMapElementConcat(TokenNonce, Intw, MapTokenNonceToIntw)  [function, total]
  rule definedMapElementConcat(K, _V, M:MapTokenNonceToIntw) => notBool K in_keys(M)

  rule #Ceil(@M:MapTokenNonceToIntw [@K:TokenNonce])
      => {(@K in_keys(@M)) #Equals true}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule (K TokenNonce2Int|-> _ M:MapTokenNonceToIntw) [ K <- V ] => (K TokenNonce2Int|-> V M) [simplification]
  rule M:MapTokenNonceToIntw [ K <- V ] => (K TokenNonce2Int|-> V M) requires notBool (K in_keys(M))
      [simplification]
  rule M:MapTokenNonceToIntw [ K <- _ ] [ K <- V ] => M [ K <- V ] [simplification]
  rule (K1 TokenNonce2Int|-> V1 M:MapTokenNonceToIntw) [ K2 <- V2 ] => (K1 TokenNonce2Int|-> V1 (M [ K2 <- V2 ]))
      requires K1 =/=K K2
      [simplification]

  rule (K TokenNonce2Int|-> _ M:MapTokenNonceToIntw) [ K <- undef ] => M
      ensures notBool (K in_keys(M))
      [simplification]
  rule M:MapTokenNonceToIntw [ K <- undef ] => M
      requires notBool (K in_keys(M))
      [simplification]
  rule (K1 TokenNonce2Int|-> V1 M:MapTokenNonceToIntw) [ K2 <- undef ]
      => (K1 TokenNonce2Int|-> V1 (M [ K2 <- undef ]))
      requires K1 =/=K K2
      [simplification]

  rule (K  TokenNonce2Int|->  V M:MapTokenNonceToIntw) [ K ] => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 TokenNonce2Int|-> _V M:MapTokenNonceToIntw) [ K2 ] => M [K2]
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapTokenNonceToIntw [ K  <-  V1 ]) [ K ]  => V1 [simplification]
  rule ( MAP:MapTokenNonceToIntw [ K1 <- _V1 ]) [ K2 ] => MAP [ K2 ]
      requires K1 =/=K K2
      [simplification]

  rule (K  TokenNonce2Int|->  V M:MapTokenNonceToIntw) [  K ] orDefault _ => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 TokenNonce2Int|-> _V M:MapTokenNonceToIntw) [ K2 ] orDefault D
      => M [K2] orDefault D
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapTokenNonceToIntw [ K  <-  V1 ]) [ K ] orDefault _ => V1 [simplification]
  rule ( MAP:MapTokenNonceToIntw [ K1 <- _V1 ]) [ K2 ] orDefault D
      => MAP [ K2 ] orDefault D
      requires K1 =/=K K2
      [simplification]
  rule .MapTokenNonceToIntw [ _ ] orDefault D => D [simplification]

  rule K in_keys(_M:MapTokenNonceToIntw [ K <- undef ]) => false [simplification]
  rule K in_keys(_M:MapTokenNonceToIntw [ K <- _ ]) => true [simplification]
  rule K1 in_keys(M:MapTokenNonceToIntw [ K2 <- _ ])
      => true requires K1 ==K K2 orBool K1 in_keys(M)
      [simplification]
  rule K1 in_keys(M:MapTokenNonceToIntw [ K2 <- _ ])
      => K1 in_keys(M)
      requires K1 =/=K K2
      [simplification]

  rule K in_keys((K TokenNonce2Int|-> V) M:MapTokenNonceToIntw)
      => true
    requires definedMapElementConcat(K2, V, M)
    [simplification(50)]
  rule K1 in_keys((K2 TokenNonce2Int|-> V) M:MapTokenNonceToIntw)
      => K1 in_keys(M)
    requires true
        andBool definedMapElementConcat(K2, V, M)
        andBool K1 =/=K K2
    [simplification(50)]
  rule K1 in_keys((K2 TokenNonce2Int|-> V) M:MapTokenNonceToIntw)
      => K1 ==K K2 orBool K1 in_keys(M)
    requires definedMapElementConcat(K2, V, M)
    [simplification(100)]
      

  rule {false #Equals @Key in_keys(.MapTokenNonceToIntw)} => #Ceil(@Key) [simplification]
  rule {@Key in_keys(.MapTokenNonceToIntw) #Equals false} => #Ceil(@Key) [simplification]
  rule {false #Equals @Key in_keys(Key' TokenNonce2Int|-> Val @M:MapTokenNonceToIntw)}
      =>  #Ceil(@Key) #And #Ceil(Key' TokenNonce2Int|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {false #Equals @Key in_keys(@M)}
      [simplification]
  rule {@Key in_keys(Key' TokenNonce2Int|-> Val @M:MapTokenNonceToIntw) #Equals false}
      =>  #Ceil(@Key) #And #Ceil(Key' TokenNonce2Int|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {@Key in_keys(@M) #Equals false}
      [simplification]
endmodule

module MAP-TOKENNONCE-TO-INTW-CURLY-BRACE
  imports private BOOL
  imports private K-EQUAL-SYNTAX
  imports MAP-TOKENNONCE-TO-INTW

  syntax MapTokenNonceToIntw ::= MapTokenNonceToIntw "{" key:TokenNonce "<-" value:Intw "}"
      [function, total, klabel(MapTokenNonceToIntw:curly_update), symbol]
  rule M:MapTokenNonceToIntw{Key <- Value} => M (Key TokenNonce2Int|-> Value)
    requires notBool Key in_keys(M)
  rule (Key TokenNonce2Int|-> _ M:MapTokenNonceToIntw){Key <- Value}
      => M (Key TokenNonce2Int|-> Value)
  rule (M:MapTokenNonceToIntw{Key <- Value})(A TokenNonce2Int|-> B N:MapTokenNonceToIntw)
      => (M (A TokenNonce2Int|-> B)) {Key <- Value} N
      requires notBool A ==K Key
      [simplification]

  rule M:MapTokenNonceToIntw{Key1 <- Value1}[Key2 <- Value2]
      => ((M:MapTokenNonceToIntw[Key2 <- Value2]{Key1 <- Value1}) #And #Not ({Key1 #Equals Key2}))
        #Or ((M:MapTokenNonceToIntw[Key2 <- Value2]) #And {Key1 #Equals Key2})
      [simplification(20)]
  rule M:MapTokenNonceToIntw[Key <- Value]
      => M:MapTokenNonceToIntw{Key <- Value}
      [simplification(100)]
  rule M:MapTokenNonceToIntw{Key1 <- _Value1}[Key2] orDefault Value2
      => M[Key2] orDefault Value2
      requires Key1 =/=K Key2
      [simplification]
  rule _M:MapTokenNonceToIntw{Key <- Value1}[Key] orDefault _Value2
      => Value1
      [simplification]
  // rule M:MapTokenNonceToIntw{Key1 <- Value1}[Key2] orDefault Value2
  //     => (M[Key2] orDefault Value2 #And #Not ({Key1 #Equals Key2}))
  //       #Or (Value1 #And {Key1 #Equals Key2})
  //     [simplification]
  rule M:MapTokenNonceToIntw{Key1 <- Value1}[Key2]
      => (M[Key2] #And #Not ({Key1 #Equals Key2}))
        #Or (Value1 #And {Key1 #Equals Key2})
      [simplification]

  rule Key1 in_keys(_:MapTokenNonceToIntw{Key1 <- _})
      => true
      [simplification(50)]
  rule Key1 in_keys(M:MapTokenNonceToIntw{Key2 <- _})
      => Key1 in_keys(M)
      requires notBool Key1 ==K Key2
      [simplification(50)]
  rule K1 in_keys(M:MapTokenNonceToIntw { K2 <- _ })
      => K1 ==K K2 orBool K1 in_keys(M)
    [simplification(100)]
      
endmodule


module MAP-BYTESW-TO-MAPTOKENNONCETOINTW
  imports private BOOL-SYNTAX
  imports private INT-SYNTAX
  imports private LIST-BYTESW
  // imports private LIST-MAPTOKENNONCETOINTW
  imports private LIST
  // imports private SET-BYTESW
  imports private SET

  syntax Bytesw
  syntax MapTokenNonceToIntw

  syntax MapByteswToMapTokenNonceToIntw [hook(MAP.Map)]
  syntax MapByteswToMapTokenNonceToIntw ::= MapByteswToMapTokenNonceToIntw MapByteswToMapTokenNonceToIntw
         [ left, function, hook(MAP.concat), klabel(_MapByteswToMapTokenNonceToIntw_),
           symbol, assoc, comm, unit(.MapByteswToMapTokenNonceToIntw), element(_Bytes2TokenNonce2Int|->_),
           index(0), format(%1%n%2)
         ]
  syntax MapByteswToMapTokenNonceToIntw ::= ".MapByteswToMapTokenNonceToIntw"
         [ function, total, hook(MAP.unit),
           klabel(.MapByteswToMapTokenNonceToIntw), symbol, latex(\dotCt{MapByteswToMapTokenNonceToIntw})
         ]
  syntax MapByteswToMapTokenNonceToIntw ::= Bytesw "Bytes2TokenNonce2Int|->" MapTokenNonceToIntw
         [ function, total, hook(MAP.element),
           klabel(_Bytes2TokenNonce2Int|->_), symbol,
           latex({#1}\mapsto{#2}), injective
         ]

  syntax priorities _Bytes2TokenNonce2Int|->_ > _MapByteswToMapTokenNonceToIntw_ .MapByteswToMapTokenNonceToIntw
  syntax non-assoc _Bytes2TokenNonce2Int|->_
  syntax MapTokenNonceToIntw ::= MapByteswToMapTokenNonceToIntw "[" Bytesw "]"
                 [function, hook(MAP.lookup), klabel(MapByteswToMapTokenNonceToIntw:lookup), symbol]
  syntax MapTokenNonceToIntw ::= MapByteswToMapTokenNonceToIntw "[" Bytesw "]" "orDefault" MapTokenNonceToIntw
                 [ function, total, hook(MAP.lookupOrDefault),
                   klabel(MapByteswToMapTokenNonceToIntw:lookupOrDefault)
                 ]
  syntax MapByteswToMapTokenNonceToIntw ::= MapByteswToMapTokenNonceToIntw "[" key: Bytesw "<-" value: MapTokenNonceToIntw "]"
                 [ function, total, klabel(MapByteswToMapTokenNonceToIntw:update), symbol,
                   hook(MAP.update), prefer
                 ]
  syntax MapByteswToMapTokenNonceToIntw ::= MapByteswToMapTokenNonceToIntw "[" Bytesw "<-" "undef" "]"
                 [ function, total, hook(MAP.remove),
                   klabel(_MapByteswToMapTokenNonceToIntw[_<-undef]), symbol
                 ]
  syntax MapByteswToMapTokenNonceToIntw ::= MapByteswToMapTokenNonceToIntw "-Map" MapByteswToMapTokenNonceToIntw
                 [ function, total, hook(MAP.difference),
                   latex({#1}-_{\it MapByteswToMapTokenNonceToIntwMap}{#2})
                 ]
  syntax MapByteswToMapTokenNonceToIntw ::= updateMap(MapByteswToMapTokenNonceToIntw, MapByteswToMapTokenNonceToIntw)
                 [function, total, hook(MAP.updateAll)]

  syntax MapByteswToMapTokenNonceToIntw ::= removeAll(MapByteswToMapTokenNonceToIntw, Set)
                 [function, total, hook(MAP.removeAll)]
  // syntax MapByteswToMapTokenNonceToIntw ::= removeAll(MapByteswToMapTokenNonceToIntw, SetBytesw)
  //                [function, total, hook(MAP.removeAll)]

  syntax Set ::= keys(MapByteswToMapTokenNonceToIntw)
                 [function, total, hook(MAP.keys)]
  // syntax SetBytesw ::= keys(MapByteswToMapTokenNonceToIntw)
  //                [function, total, hook(MAP.keys)]

  // syntax List ::= "keys_list" "(" MapByteswToMapTokenNonceToIntw ")"
  //                [function, hook(MAP.keys_list)]
  syntax ListBytesw ::= "keys_list" "(" MapByteswToMapTokenNonceToIntw ")"
                 [function, hook(MAP.keys_list)]

  syntax Bool ::= Bytesw "in_keys" "(" MapByteswToMapTokenNonceToIntw ")"
                 [function, total, hook(MAP.in_keys)]

  syntax List ::= values(MapByteswToMapTokenNonceToIntw)
                 [function, hook(MAP.values)]
  // syntax ListMapTokenNonceToIntw ::= values(MapByteswToMapTokenNonceToIntw)
  //                [function, hook(MAP.values)]

  syntax Int ::= size(MapByteswToMapTokenNonceToIntw)
                 [function, total, hook(MAP.size), klabel(MapByteswToMapTokenNonceToIntw.sizeMap)]
  syntax Bool ::= MapByteswToMapTokenNonceToIntw "<=Map" MapByteswToMapTokenNonceToIntw
                 [function, total, hook(MAP.inclusion)]
  syntax Bytesw ::= choice(MapByteswToMapTokenNonceToIntw)
                 [function, hook(MAP.choice), klabel(MapByteswToMapTokenNonceToIntw:choice)]
endmodule

module MAP-BYTESW-TO-MAPTOKENNONCETOINTW-KORE-SYMBOLIC
  imports MAP-BYTESW-TO-MAPTOKENNONCETOINTW
  imports private K-EQUAL
  imports private BOOL

  syntax Bool ::= definedMapElementConcat(Bytesw, MapTokenNonceToIntw, MapByteswToMapTokenNonceToIntw)  [function, total]
  rule definedMapElementConcat(K, _V, M:MapByteswToMapTokenNonceToIntw) => notBool K in_keys(M)

  rule #Ceil(@M:MapByteswToMapTokenNonceToIntw [@K:Bytesw])
      => {(@K in_keys(@M)) #Equals true}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule (K Bytes2TokenNonce2Int|-> _ M:MapByteswToMapTokenNonceToIntw) [ K <- V ] => (K Bytes2TokenNonce2Int|-> V M) [simplification]
  rule M:MapByteswToMapTokenNonceToIntw [ K <- V ] => (K Bytes2TokenNonce2Int|-> V M) requires notBool (K in_keys(M))
      [simplification]
  rule M:MapByteswToMapTokenNonceToIntw [ K <- _ ] [ K <- V ] => M [ K <- V ] [simplification]
  rule (K1 Bytes2TokenNonce2Int|-> V1 M:MapByteswToMapTokenNonceToIntw) [ K2 <- V2 ] => (K1 Bytes2TokenNonce2Int|-> V1 (M [ K2 <- V2 ]))
      requires K1 =/=K K2
      [simplification]

  rule (K Bytes2TokenNonce2Int|-> _ M:MapByteswToMapTokenNonceToIntw) [ K <- undef ] => M
      ensures notBool (K in_keys(M))
      [simplification]
  rule M:MapByteswToMapTokenNonceToIntw [ K <- undef ] => M
      requires notBool (K in_keys(M))
      [simplification]
  rule (K1 Bytes2TokenNonce2Int|-> V1 M:MapByteswToMapTokenNonceToIntw) [ K2 <- undef ]
      => (K1 Bytes2TokenNonce2Int|-> V1 (M [ K2 <- undef ]))
      requires K1 =/=K K2
      [simplification]

  rule (K  Bytes2TokenNonce2Int|->  V M:MapByteswToMapTokenNonceToIntw) [ K ] => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Bytes2TokenNonce2Int|-> _V M:MapByteswToMapTokenNonceToIntw) [ K2 ] => M [K2]
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapByteswToMapTokenNonceToIntw [ K  <-  V1 ]) [ K ]  => V1 [simplification]
  rule ( MAP:MapByteswToMapTokenNonceToIntw [ K1 <- _V1 ]) [ K2 ] => MAP [ K2 ]
      requires K1 =/=K K2
      [simplification]

  rule (K  Bytes2TokenNonce2Int|->  V M:MapByteswToMapTokenNonceToIntw) [  K ] orDefault _ => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Bytes2TokenNonce2Int|-> _V M:MapByteswToMapTokenNonceToIntw) [ K2 ] orDefault D
      => M [K2] orDefault D
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapByteswToMapTokenNonceToIntw [ K  <-  V1 ]) [ K ] orDefault _ => V1 [simplification]
  rule ( MAP:MapByteswToMapTokenNonceToIntw [ K1 <- _V1 ]) [ K2 ] orDefault D
      => MAP [ K2 ] orDefault D
      requires K1 =/=K K2
      [simplification]
  rule .MapByteswToMapTokenNonceToIntw [ _ ] orDefault D => D [simplification]

  rule K in_keys(_M:MapByteswToMapTokenNonceToIntw [ K <- undef ]) => false [simplification]
  rule K in_keys(_M:MapByteswToMapTokenNonceToIntw [ K <- _ ]) => true [simplification]
  rule K1 in_keys(M:MapByteswToMapTokenNonceToIntw [ K2 <- _ ])
      => true requires K1 ==K K2 orBool K1 in_keys(M)
      [simplification]
  rule K1 in_keys(M:MapByteswToMapTokenNonceToIntw [ K2 <- _ ])
      => K1 in_keys(M)
      requires K1 =/=K K2
      [simplification]

  rule K in_keys((K Bytes2TokenNonce2Int|-> V) M:MapByteswToMapTokenNonceToIntw)
      => true
    requires definedMapElementConcat(K2, V, M)
    [simplification(50)]
  rule K1 in_keys((K2 Bytes2TokenNonce2Int|-> V) M:MapByteswToMapTokenNonceToIntw)
      => K1 in_keys(M)
    requires true
        andBool definedMapElementConcat(K2, V, M)
        andBool K1 =/=K K2
    [simplification(50)]
  rule K1 in_keys((K2 Bytes2TokenNonce2Int|-> V) M:MapByteswToMapTokenNonceToIntw)
      => K1 ==K K2 orBool K1 in_keys(M)
    requires definedMapElementConcat(K2, V, M)
    [simplification(100)]
      

  rule {false #Equals @Key in_keys(.MapByteswToMapTokenNonceToIntw)} => #Ceil(@Key) [simplification]
  rule {@Key in_keys(.MapByteswToMapTokenNonceToIntw) #Equals false} => #Ceil(@Key) [simplification]
  rule {false #Equals @Key in_keys(Key' Bytes2TokenNonce2Int|-> Val @M:MapByteswToMapTokenNonceToIntw)}
      =>  #Ceil(@Key) #And #Ceil(Key' Bytes2TokenNonce2Int|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {false #Equals @Key in_keys(@M)}
      [simplification]
  rule {@Key in_keys(Key' Bytes2TokenNonce2Int|-> Val @M:MapByteswToMapTokenNonceToIntw) #Equals false}
      =>  #Ceil(@Key) #And #Ceil(Key' Bytes2TokenNonce2Int|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {@Key in_keys(@M) #Equals false}
      [simplification]
endmodule

module MAP-BYTESW-TO-MAPTOKENNONCETOINTW-CURLY-BRACE
  imports private BOOL
  imports private K-EQUAL-SYNTAX
  imports MAP-BYTESW-TO-MAPTOKENNONCETOINTW

  syntax MapByteswToMapTokenNonceToIntw ::= MapByteswToMapTokenNonceToIntw "{" key:Bytesw "<-" value:MapTokenNonceToIntw "}"
      [function, total, klabel(MapByteswToMapTokenNonceToIntw:curly_update), symbol]
  rule M:MapByteswToMapTokenNonceToIntw{Key <- Value} => M (Key Bytes2TokenNonce2Int|-> Value)
    requires notBool Key in_keys(M)
  rule (Key Bytes2TokenNonce2Int|-> _ M:MapByteswToMapTokenNonceToIntw){Key <- Value}
      => M (Key Bytes2TokenNonce2Int|-> Value)
  rule (M:MapByteswToMapTokenNonceToIntw{Key <- Value})(A Bytes2TokenNonce2Int|-> B N:MapByteswToMapTokenNonceToIntw)
      => (M (A Bytes2TokenNonce2Int|-> B)) {Key <- Value} N
      requires notBool A ==K Key
      [simplification]

  rule M:MapByteswToMapTokenNonceToIntw{Key1 <- Value1}[Key2 <- Value2]
      => ((M:MapByteswToMapTokenNonceToIntw[Key2 <- Value2]{Key1 <- Value1}) #And #Not ({Key1 #Equals Key2}))
        #Or ((M:MapByteswToMapTokenNonceToIntw[Key2 <- Value2]) #And {Key1 #Equals Key2})
      [simplification(20)]
  rule M:MapByteswToMapTokenNonceToIntw[Key <- Value]
      => M:MapByteswToMapTokenNonceToIntw{Key <- Value}
      [simplification(100)]
  rule M:MapByteswToMapTokenNonceToIntw{Key1 <- _Value1}[Key2] orDefault Value2
      => M[Key2] orDefault Value2
      requires Key1 =/=K Key2
      [simplification]
  rule _M:MapByteswToMapTokenNonceToIntw{Key <- Value1}[Key] orDefault _Value2
      => Value1
      [simplification]
  // rule M:MapByteswToMapTokenNonceToIntw{Key1 <- Value1}[Key2] orDefault Value2
  //     => (M[Key2] orDefault Value2 #And #Not ({Key1 #Equals Key2}))
  //       #Or (Value1 #And {Key1 #Equals Key2})
  //     [simplification]
  rule M:MapByteswToMapTokenNonceToIntw{Key1 <- Value1}[Key2]
      => (M[Key2] #And #Not ({Key1 #Equals Key2}))
        #Or (Value1 #And {Key1 #Equals Key2})
      [simplification]

  rule Key1 in_keys(_:MapByteswToMapTokenNonceToIntw{Key1 <- _})
      => true
      [simplification(50)]
  rule Key1 in_keys(M:MapByteswToMapTokenNonceToIntw{Key2 <- _})
      => Key1 in_keys(M)
      requires notBool Key1 ==K Key2
      [simplification(50)]
  rule K1 in_keys(M:MapByteswToMapTokenNonceToIntw { K2 <- _ })
      => K1 ==K K2 orBool K1 in_keys(M)
    [simplification(100)]
      
endmodule


module MAP-INTW-TO-BYTESW
  imports private BOOL-SYNTAX
  imports private INT-SYNTAX
  // imports private LIST-INTW
  imports private LIST-BYTESW
  imports private LIST
  // imports private SET-INTW
  imports private SET

  syntax Intw
  syntax Bytesw

  syntax MapIntwToBytesw [hook(MAP.Map)]
  syntax MapIntwToBytesw ::= MapIntwToBytesw MapIntwToBytesw
         [ left, function, hook(MAP.concat), klabel(_MapIntwToBytesw_),
           symbol, assoc, comm, unit(.MapIntwToBytesw), element(_Int2Bytes|->_),
           index(0), format(%1%n%2)
         ]
  syntax MapIntwToBytesw ::= ".MapIntwToBytesw"
         [ function, total, hook(MAP.unit),
           klabel(.MapIntwToBytesw), symbol, latex(\dotCt{MapIntwToBytesw})
         ]
  syntax MapIntwToBytesw ::= Intw "Int2Bytes|->" Bytesw
         [ function, total, hook(MAP.element),
           klabel(_Int2Bytes|->_), symbol,
           latex({#1}\mapsto{#2}), injective
         ]

  syntax priorities _Int2Bytes|->_ > _MapIntwToBytesw_ .MapIntwToBytesw
  syntax non-assoc _Int2Bytes|->_
  syntax Bytesw ::= MapIntwToBytesw "[" Intw "]"
                 [function, hook(MAP.lookup), klabel(MapIntwToBytesw:lookup), symbol]
  syntax Bytesw ::= MapIntwToBytesw "[" Intw "]" "orDefault" Bytesw
                 [ function, total, hook(MAP.lookupOrDefault),
                   klabel(MapIntwToBytesw:lookupOrDefault)
                 ]
  syntax MapIntwToBytesw ::= MapIntwToBytesw "[" key: Intw "<-" value: Bytesw "]"
                 [ function, total, klabel(MapIntwToBytesw:update), symbol,
                   hook(MAP.update), prefer
                 ]
  syntax MapIntwToBytesw ::= MapIntwToBytesw "[" Intw "<-" "undef" "]"
                 [ function, total, hook(MAP.remove),
                   klabel(_MapIntwToBytesw[_<-undef]), symbol
                 ]
  syntax MapIntwToBytesw ::= MapIntwToBytesw "-Map" MapIntwToBytesw
                 [ function, total, hook(MAP.difference),
                   latex({#1}-_{\it MapIntwToByteswMap}{#2})
                 ]
  syntax MapIntwToBytesw ::= updateMap(MapIntwToBytesw, MapIntwToBytesw)
                 [function, total, hook(MAP.updateAll)]

  syntax MapIntwToBytesw ::= removeAll(MapIntwToBytesw, Set)
                 [function, total, hook(MAP.removeAll)]
  // syntax MapIntwToBytesw ::= removeAll(MapIntwToBytesw, SetIntw)
  //                [function, total, hook(MAP.removeAll)]

  syntax Set ::= keys(MapIntwToBytesw)
                 [function, total, hook(MAP.keys)]
  // syntax SetIntw ::= keys(MapIntwToBytesw)
  //                [function, total, hook(MAP.keys)]

  syntax List ::= "keys_list" "(" MapIntwToBytesw ")"
                 [function, hook(MAP.keys_list)]
  // syntax ListIntw ::= "keys_list" "(" MapIntwToBytesw ")"
  //                [function, hook(MAP.keys_list)]

  syntax Bool ::= Intw "in_keys" "(" MapIntwToBytesw ")"
                 [function, total, hook(MAP.in_keys)]

  // syntax List ::= values(MapIntwToBytesw)
  //                [function, hook(MAP.values)]
  syntax ListBytesw ::= values(MapIntwToBytesw)
                 [function, hook(MAP.values)]

  syntax Int ::= size(MapIntwToBytesw)
                 [function, total, hook(MAP.size), klabel(MapIntwToBytesw.sizeMap)]
  syntax Bool ::= MapIntwToBytesw "<=Map" MapIntwToBytesw
                 [function, total, hook(MAP.inclusion)]
  syntax Intw ::= choice(MapIntwToBytesw)
                 [function, hook(MAP.choice), klabel(MapIntwToBytesw:choice)]
endmodule

module MAP-INTW-TO-BYTESW-KORE-SYMBOLIC
  imports MAP-INTW-TO-BYTESW
  imports private K-EQUAL
  imports private BOOL

  syntax Bool ::= definedMapElementConcat(Intw, Bytesw, MapIntwToBytesw)  [function, total]
  rule definedMapElementConcat(K, _V, M:MapIntwToBytesw) => notBool K in_keys(M)

  rule #Ceil(@M:MapIntwToBytesw [@K:Intw])
      => {(@K in_keys(@M)) #Equals true}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule (K Int2Bytes|-> _ M:MapIntwToBytesw) [ K <- V ] => (K Int2Bytes|-> V M) [simplification]
  rule M:MapIntwToBytesw [ K <- V ] => (K Int2Bytes|-> V M) requires notBool (K in_keys(M))
      [simplification]
  rule M:MapIntwToBytesw [ K <- _ ] [ K <- V ] => M [ K <- V ] [simplification]
  rule (K1 Int2Bytes|-> V1 M:MapIntwToBytesw) [ K2 <- V2 ] => (K1 Int2Bytes|-> V1 (M [ K2 <- V2 ]))
      requires K1 =/=K K2
      [simplification]

  rule (K Int2Bytes|-> _ M:MapIntwToBytesw) [ K <- undef ] => M
      ensures notBool (K in_keys(M))
      [simplification]
  rule M:MapIntwToBytesw [ K <- undef ] => M
      requires notBool (K in_keys(M))
      [simplification]
  rule (K1 Int2Bytes|-> V1 M:MapIntwToBytesw) [ K2 <- undef ]
      => (K1 Int2Bytes|-> V1 (M [ K2 <- undef ]))
      requires K1 =/=K K2
      [simplification]

  rule (K  Int2Bytes|->  V M:MapIntwToBytesw) [ K ] => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Int2Bytes|-> _V M:MapIntwToBytesw) [ K2 ] => M [K2]
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapIntwToBytesw [ K  <-  V1 ]) [ K ]  => V1 [simplification]
  rule ( MAP:MapIntwToBytesw [ K1 <- _V1 ]) [ K2 ] => MAP [ K2 ]
      requires K1 =/=K K2
      [simplification]

  rule (K  Int2Bytes|->  V M:MapIntwToBytesw) [  K ] orDefault _ => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Int2Bytes|-> _V M:MapIntwToBytesw) [ K2 ] orDefault D
      => M [K2] orDefault D
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapIntwToBytesw [ K  <-  V1 ]) [ K ] orDefault _ => V1 [simplification]
  rule ( MAP:MapIntwToBytesw [ K1 <- _V1 ]) [ K2 ] orDefault D
      => MAP [ K2 ] orDefault D
      requires K1 =/=K K2
      [simplification]
  rule .MapIntwToBytesw [ _ ] orDefault D => D [simplification]

  rule K in_keys(_M:MapIntwToBytesw [ K <- undef ]) => false [simplification]
  rule K in_keys(_M:MapIntwToBytesw [ K <- _ ]) => true [simplification]
  rule K1 in_keys(M:MapIntwToBytesw [ K2 <- _ ])
      => true requires K1 ==K K2 orBool K1 in_keys(M)
      [simplification]
  rule K1 in_keys(M:MapIntwToBytesw [ K2 <- _ ])
      => K1 in_keys(M)
      requires K1 =/=K K2
      [simplification]

  rule K in_keys((K Int2Bytes|-> V) M:MapIntwToBytesw)
      => true
    requires definedMapElementConcat(K2, V, M)
    [simplification(50)]
  rule K1 in_keys((K2 Int2Bytes|-> V) M:MapIntwToBytesw)
      => K1 in_keys(M)
    requires true
        andBool definedMapElementConcat(K2, V, M)
        andBool K1 =/=K K2
    [simplification(50)]
  rule K1 in_keys((K2 Int2Bytes|-> V) M:MapIntwToBytesw)
      => K1 ==K K2 orBool K1 in_keys(M)
    requires definedMapElementConcat(K2, V, M)
    [simplification(100)]
      

  rule {false #Equals @Key in_keys(.MapIntwToBytesw)} => #Ceil(@Key) [simplification]
  rule {@Key in_keys(.MapIntwToBytesw) #Equals false} => #Ceil(@Key) [simplification]
  rule {false #Equals @Key in_keys(Key' Int2Bytes|-> Val @M:MapIntwToBytesw)}
      =>  #Ceil(@Key) #And #Ceil(Key' Int2Bytes|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {false #Equals @Key in_keys(@M)}
      [simplification]
  rule {@Key in_keys(Key' Int2Bytes|-> Val @M:MapIntwToBytesw) #Equals false}
      =>  #Ceil(@Key) #And #Ceil(Key' Int2Bytes|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {@Key in_keys(@M) #Equals false}
      [simplification]
endmodule

module MAP-INTW-TO-BYTESW-CURLY-BRACE
  imports private BOOL
  imports private K-EQUAL-SYNTAX
  imports MAP-INTW-TO-BYTESW

  syntax MapIntwToBytesw ::= MapIntwToBytesw "{" key:Intw "<-" value:Bytesw "}"
      [function, total, klabel(MapIntwToBytesw:curly_update), symbol]
  rule M:MapIntwToBytesw{Key <- Value} => M (Key Int2Bytes|-> Value)
    requires notBool Key in_keys(M)
  rule (Key Int2Bytes|-> _ M:MapIntwToBytesw){Key <- Value}
      => M (Key Int2Bytes|-> Value)
  rule (M:MapIntwToBytesw{Key <- Value})(A Int2Bytes|-> B N:MapIntwToBytesw)
      => (M (A Int2Bytes|-> B)) {Key <- Value} N
      requires notBool A ==K Key
      [simplification]

  rule M:MapIntwToBytesw{Key1 <- Value1}[Key2 <- Value2]
      => ((M:MapIntwToBytesw[Key2 <- Value2]{Key1 <- Value1}) #And #Not ({Key1 #Equals Key2}))
        #Or ((M:MapIntwToBytesw[Key2 <- Value2]) #And {Key1 #Equals Key2})
      [simplification(20)]
  rule M:MapIntwToBytesw[Key <- Value]
      => M:MapIntwToBytesw{Key <- Value}
      [simplification(100)]
  rule M:MapIntwToBytesw{Key1 <- _Value1}[Key2] orDefault Value2
      => M[Key2] orDefault Value2
      requires Key1 =/=K Key2
      [simplification]
  rule _M:MapIntwToBytesw{Key <- Value1}[Key] orDefault _Value2
      => Value1
      [simplification]
  // rule M:MapIntwToBytesw{Key1 <- Value1}[Key2] orDefault Value2
  //     => (M[Key2] orDefault Value2 #And #Not ({Key1 #Equals Key2}))
  //       #Or (Value1 #And {Key1 #Equals Key2})
  //     [simplification]
  rule M:MapIntwToBytesw{Key1 <- Value1}[Key2]
      => (M[Key2] #And #Not ({Key1 #Equals Key2}))
        #Or (Value1 #And {Key1 #Equals Key2})
      [simplification]

  rule Key1 in_keys(_:MapIntwToBytesw{Key1 <- _})
      => true
      [simplification(50)]
  rule Key1 in_keys(M:MapIntwToBytesw{Key2 <- _})
      => Key1 in_keys(M)
      requires notBool Key1 ==K Key2
      [simplification(50)]
  rule K1 in_keys(M:MapIntwToBytesw { K2 <- _ })
      => K1 ==K K2 orBool K1 in_keys(M)
    [simplification(100)]
      
endmodule


module MAP-INTW-TO-INTW
  imports private BOOL-SYNTAX
  imports private INT-SYNTAX
  // imports private LIST-INTW
  // imports private LIST-INTW
  imports private LIST
  // imports private SET-INTW
  imports private SET

  syntax Intw
  syntax Intw

  syntax MapIntwToIntw [hook(MAP.Map)]
  syntax MapIntwToIntw ::= MapIntwToIntw MapIntwToIntw
         [ left, function, hook(MAP.concat), klabel(_MapIntwToIntw_),
           symbol, assoc, comm, unit(.MapIntwToIntw), element(_Int2Int|->_),
           index(0), format(%1%n%2)
         ]
  syntax MapIntwToIntw ::= ".MapIntwToIntw"
         [ function, total, hook(MAP.unit),
           klabel(.MapIntwToIntw), symbol, latex(\dotCt{MapIntwToIntw})
         ]
  syntax MapIntwToIntw ::= Intw "Int2Int|->" Intw
         [ function, total, hook(MAP.element),
           klabel(_Int2Int|->_), symbol,
           latex({#1}\mapsto{#2}), injective
         ]

  syntax priorities _Int2Int|->_ > _MapIntwToIntw_ .MapIntwToIntw
  syntax non-assoc _Int2Int|->_
  syntax Intw ::= MapIntwToIntw "[" Intw "]"
                 [function, hook(MAP.lookup), klabel(MapIntwToIntw:lookup), symbol]
  syntax Intw ::= MapIntwToIntw "[" Intw "]" "orDefault" Intw
                 [ function, total, hook(MAP.lookupOrDefault),
                   klabel(MapIntwToIntw:lookupOrDefault)
                 ]
  syntax MapIntwToIntw ::= MapIntwToIntw "[" key: Intw "<-" value: Intw "]"
                 [ function, total, klabel(MapIntwToIntw:update), symbol,
                   hook(MAP.update), prefer
                 ]
  syntax MapIntwToIntw ::= MapIntwToIntw "[" Intw "<-" "undef" "]"
                 [ function, total, hook(MAP.remove),
                   klabel(_MapIntwToIntw[_<-undef]), symbol
                 ]
  syntax MapIntwToIntw ::= MapIntwToIntw "-Map" MapIntwToIntw
                 [ function, total, hook(MAP.difference),
                   latex({#1}-_{\it MapIntwToIntwMap}{#2})
                 ]
  syntax MapIntwToIntw ::= updateMap(MapIntwToIntw, MapIntwToIntw)
                 [function, total, hook(MAP.updateAll)]

  syntax MapIntwToIntw ::= removeAll(MapIntwToIntw, Set)
                 [function, total, hook(MAP.removeAll)]
  // syntax MapIntwToIntw ::= removeAll(MapIntwToIntw, SetIntw)
  //                [function, total, hook(MAP.removeAll)]

  syntax Set ::= keys(MapIntwToIntw)
                 [function, total, hook(MAP.keys)]
  // syntax SetIntw ::= keys(MapIntwToIntw)
  //                [function, total, hook(MAP.keys)]

  syntax List ::= "keys_list" "(" MapIntwToIntw ")"
                 [function, hook(MAP.keys_list)]
  // syntax ListIntw ::= "keys_list" "(" MapIntwToIntw ")"
  //                [function, hook(MAP.keys_list)]

  syntax Bool ::= Intw "in_keys" "(" MapIntwToIntw ")"
                 [function, total, hook(MAP.in_keys)]

  syntax List ::= values(MapIntwToIntw)
                 [function, hook(MAP.values)]
  // syntax ListIntw ::= values(MapIntwToIntw)
  //                [function, hook(MAP.values)]

  syntax Int ::= size(MapIntwToIntw)
                 [function, total, hook(MAP.size), klabel(MapIntwToIntw.sizeMap)]
  syntax Bool ::= MapIntwToIntw "<=Map" MapIntwToIntw
                 [function, total, hook(MAP.inclusion)]
  syntax Intw ::= choice(MapIntwToIntw)
                 [function, hook(MAP.choice), klabel(MapIntwToIntw:choice)]
endmodule

module MAP-INTW-TO-INTW-KORE-SYMBOLIC
  imports MAP-INTW-TO-INTW
  imports private K-EQUAL
  imports private BOOL

  syntax Bool ::= definedMapElementConcat(Intw, Intw, MapIntwToIntw)  [function, total]
  rule definedMapElementConcat(K, _V, M:MapIntwToIntw) => notBool K in_keys(M)

  rule #Ceil(@M:MapIntwToIntw [@K:Intw])
      => {(@K in_keys(@M)) #Equals true}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule (K Int2Int|-> _ M:MapIntwToIntw) [ K <- V ] => (K Int2Int|-> V M) [simplification]
  rule M:MapIntwToIntw [ K <- V ] => (K Int2Int|-> V M) requires notBool (K in_keys(M))
      [simplification]
  rule M:MapIntwToIntw [ K <- _ ] [ K <- V ] => M [ K <- V ] [simplification]
  rule (K1 Int2Int|-> V1 M:MapIntwToIntw) [ K2 <- V2 ] => (K1 Int2Int|-> V1 (M [ K2 <- V2 ]))
      requires K1 =/=K K2
      [simplification]

  rule (K Int2Int|-> _ M:MapIntwToIntw) [ K <- undef ] => M
      ensures notBool (K in_keys(M))
      [simplification]
  rule M:MapIntwToIntw [ K <- undef ] => M
      requires notBool (K in_keys(M))
      [simplification]
  rule (K1 Int2Int|-> V1 M:MapIntwToIntw) [ K2 <- undef ]
      => (K1 Int2Int|-> V1 (M [ K2 <- undef ]))
      requires K1 =/=K K2
      [simplification]

  rule (K  Int2Int|->  V M:MapIntwToIntw) [ K ] => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Int2Int|-> _V M:MapIntwToIntw) [ K2 ] => M [K2]
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapIntwToIntw [ K  <-  V1 ]) [ K ]  => V1 [simplification]
  rule ( MAP:MapIntwToIntw [ K1 <- _V1 ]) [ K2 ] => MAP [ K2 ]
      requires K1 =/=K K2
      [simplification]

  rule (K  Int2Int|->  V M:MapIntwToIntw) [  K ] orDefault _ => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 Int2Int|-> _V M:MapIntwToIntw) [ K2 ] orDefault D
      => M [K2] orDefault D
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:MapIntwToIntw [ K  <-  V1 ]) [ K ] orDefault _ => V1 [simplification]
  rule ( MAP:MapIntwToIntw [ K1 <- _V1 ]) [ K2 ] orDefault D
      => MAP [ K2 ] orDefault D
      requires K1 =/=K K2
      [simplification]
  rule .MapIntwToIntw [ _ ] orDefault D => D [simplification]

  rule K in_keys(_M:MapIntwToIntw [ K <- undef ]) => false [simplification]
  rule K in_keys(_M:MapIntwToIntw [ K <- _ ]) => true [simplification]
  rule K1 in_keys(M:MapIntwToIntw [ K2 <- _ ])
      => true requires K1 ==K K2 orBool K1 in_keys(M)
      [simplification]
  rule K1 in_keys(M:MapIntwToIntw [ K2 <- _ ])
      => K1 in_keys(M)
      requires K1 =/=K K2
      [simplification]

  rule K in_keys((K Int2Int|-> V) M:MapIntwToIntw)
      => true
    requires definedMapElementConcat(K2, V, M)
    [simplification(50)]
  rule K1 in_keys((K2 Int2Int|-> V) M:MapIntwToIntw)
      => K1 in_keys(M)
    requires true
        andBool definedMapElementConcat(K2, V, M)
        andBool K1 =/=K K2
    [simplification(50)]
  rule K1 in_keys((K2 Int2Int|-> V) M:MapIntwToIntw)
      => K1 ==K K2 orBool K1 in_keys(M)
    requires definedMapElementConcat(K2, V, M)
    [simplification(100)]
      

  rule {false #Equals @Key in_keys(.MapIntwToIntw)} => #Ceil(@Key) [simplification]
  rule {@Key in_keys(.MapIntwToIntw) #Equals false} => #Ceil(@Key) [simplification]
  rule {false #Equals @Key in_keys(Key' Int2Int|-> Val @M:MapIntwToIntw)}
      =>  #Ceil(@Key) #And #Ceil(Key' Int2Int|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {false #Equals @Key in_keys(@M)}
      [simplification]
  rule {@Key in_keys(Key' Int2Int|-> Val @M:MapIntwToIntw) #Equals false}
      =>  #Ceil(@Key) #And #Ceil(Key' Int2Int|-> Val @M)
          #And #Not({@Key #Equals Key'})
          #And {@Key in_keys(@M) #Equals false}
      [simplification]
endmodule

module MAP-INTW-TO-INTW-CURLY-BRACE
  imports private BOOL
  imports private K-EQUAL-SYNTAX
  imports MAP-INTW-TO-INTW

  syntax MapIntwToIntw ::= MapIntwToIntw "{" key:Intw "<-" value:Intw "}"
      [function, total, klabel(MapIntwToIntw:curly_update), symbol]
  rule M:MapIntwToIntw{Key <- Value} => M (Key Int2Int|-> Value)
    requires notBool Key in_keys(M)
  rule (Key Int2Int|-> _ M:MapIntwToIntw){Key <- Value}
      => M (Key Int2Int|-> Value)
  rule (M:MapIntwToIntw{Key <- Value})(A Int2Int|-> B N:MapIntwToIntw)
      => (M (A Int2Int|-> B)) {Key <- Value} N
      requires notBool A ==K Key
      [simplification]

  rule M:MapIntwToIntw{Key1 <- Value1}[Key2 <- Value2]
      => ((M:MapIntwToIntw[Key2 <- Value2]{Key1 <- Value1}) #And #Not ({Key1 #Equals Key2}))
        #Or ((M:MapIntwToIntw[Key2 <- Value2]) #And {Key1 #Equals Key2})
      [simplification(20)]
  rule M:MapIntwToIntw[Key <- Value]
      => M:MapIntwToIntw{Key <- Value}
      [simplification(100)]
  rule M:MapIntwToIntw{Key1 <- _Value1}[Key2] orDefault Value2
      => M[Key2] orDefault Value2
      requires Key1 =/=K Key2
      [simplification]
  rule _M:MapIntwToIntw{Key <- Value1}[Key] orDefault _Value2
      => Value1
      [simplification]
  // rule M:MapIntwToIntw{Key1 <- Value1}[Key2] orDefault Value2
  //     => (M[Key2] orDefault Value2 #And #Not ({Key1 #Equals Key2}))
  //       #Or (Value1 #And {Key1 #Equals Key2})
  //     [simplification]
  rule M:MapIntwToIntw{Key1 <- Value1}[Key2]
      => (M[Key2] #And #Not ({Key1 #Equals Key2}))
        #Or (Value1 #And {Key1 #Equals Key2})
      [simplification]

  rule Key1 in_keys(_:MapIntwToIntw{Key1 <- _})
      => true
      [simplification(50)]
  rule Key1 in_keys(M:MapIntwToIntw{Key2 <- _})
      => Key1 in_keys(M)
      requires notBool Key1 ==K Key2
      [simplification(50)]
  rule K1 in_keys(M:MapIntwToIntw { K2 <- _ })
      => K1 ==K K2 orBool K1 in_keys(M)
    [simplification(100)]
      
endmodule
