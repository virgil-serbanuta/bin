#!/usr/bin/env python3

from pathlib import Path

import sys

class Properties:
    def __init__(self,
                name:str,
                has_set:bool, has_list:bool,
                is_primitive:bool,
                imports:list[str],
                default:str | None) -> None:
        self.__name = name
        self.__has_set = has_set
        self.__has_list = has_list
        self.__is_primitive = is_primitive
        self.__imports = imports
        self.__default = default

    def name(self) -> str:
        return self.__name

    def Name(self) -> str:
        return self.__name.upper()
    
    def has_set(self) -> bool:
        return self.__has_set

    def has_list(self) -> bool:
        return self.__has_list

    def is_primitive(self):
        return self.__is_primitive

    def imports(self):
        return self.__imports

    def setName(self):
        return f'Set{self.__name}'

    def listName(self):
        return f'List{self.__name}'

    def unwrappedType(self):
        return self.name()
    
    def wrappedType(self):
        if self.is_primitive():
            return f'Wrapped{self.name()}'
        return self.name()
    
    def wrap(self, value):
        if (self.is_primitive()):
            return f'wrap({value})'
        return value

    def unWrap(self, value):
        if (self.is_primitive()):
            return f'unwrap( {value} )'
        return value

class Map:
    def __init__(self, short_name:str, key_name:str, value_name:str) -> None:
        self.__short_name = short_name
        self.__key_name = key_name
        self.__value_name = value_name

    def short_name(self):
        return self.__short_name
    
    def key_name(self):
        return self.__key_name
    
    def value_name(self):
        return self.__value_name

def maybeComment(c:bool) -> str:
    if c:
        return '// '
    return ''

def make_map(key:Properties, value:Properties, map_short:str):
    map_name = 'Map%sTo%s' % (key.name(), value.name())
    key_primitive = key.is_primitive()
    value_primitive = value.is_primitive()

    return f'''
{maybeComment(not key_primitive)}requires "{type_code_name(key)}"
{maybeComment(not value_primitive or key.name() == value.name())}requires "{type_code_name(value)}"
{maybeComment(not key.has_list())}requires "{list_name(key)}"

module MAP-{key.Name()}-TO-{value.Name()}
  imports private BOOL-SYNTAX
  imports private INT-SYNTAX
  {maybeComment(not key.has_list())}imports private LIST-{key.Name()}
  {maybeComment(not value.has_list())}imports private LIST-{value.Name()}
  {maybeComment(key.has_list() and value.has_list())}imports private LIST
  {maybeComment(not key.has_set())}imports private SET-{key.Name()}
  {maybeComment(key.has_set())}imports private SET
  {maybeComment(not key_primitive)}imports {type_code_module(key)}
  {maybeComment(not value_primitive)}imports {type_code_module(value)}

  syntax {key.unwrappedType()}
  syntax {value.unwrappedType()}

  syntax {map_name} [hook(MAP.Map)]
  syntax {map_name} ::= {map_name} {map_name}
         [ left, function, hook(MAP.concat), symbol(_{map_name}_),
           assoc, comm, unit(.{map_name}), element(_{map_short}|->_),
           index(0), format(%1%n%2)
         ]
  syntax {map_name} ::= ".{map_name}"
         [ function, total, hook(MAP.unit),
           symbol(.{map_name})
         ]
  syntax {map_name} ::= {key.wrappedType()} "{map_short}|->" {value.wrappedType()}
         [ function, total, hook(MAP.element),
           symbol(_{map_short}|->_),
           injective
         ]

  syntax priority _{map_short}|->_ > _{map_name}_ .{map_name}
  syntax non-assoc _{map_short}|->_
  syntax {value.wrappedType()} ::= {map_name} "[" {key.wrappedType()} "]"
                 [function, hook(MAP.lookup), symbol({map_name}:lookup)]
  syntax {value.wrappedType()} ::= {map_name} "[" {key.wrappedType()} "]" "orDefault" {value.wrappedType()}
                 [ function, total, hook(MAP.lookupOrDefault),
                   symbol({map_name}:lookupOrDefault)
                 ]
  syntax {map_name} ::= {map_name} "[" key: {key.wrappedType()} "<-" value: {value.wrappedType()} "]"
                 [ function, total, symbol({map_name}:update),
                   hook(MAP.update), prefer
                 ]
  syntax {map_name} ::= {map_name} "[" {key.wrappedType()} "<-" "undef" "]"
                 [ function, total, hook(MAP.remove),
                   symbol(_{map_name}[_<-undef])
                 ]
  syntax {map_name} ::= {map_name} "-Map" {map_name}
                 [ function, total, hook(MAP.difference) ]
  syntax {map_name} ::= updateMap({map_name}, {map_name})
                 [function, total, hook(MAP.updateAll)]

  {maybeComment(key.has_set())}syntax {map_name} ::= removeAll({map_name}, Set)
  {maybeComment(key.has_set())}               [function, total, hook(MAP.removeAll)]
  {maybeComment(not key.has_set())}syntax {map_name} ::= removeAll({map_name}, {key.setName()})
  {maybeComment(not key.has_set())}               [function, total, hook(MAP.removeAll)]

  {maybeComment(key.has_set())}syntax Set ::= keys({map_name})
  {maybeComment(key.has_set())}               [function, total, hook(MAP.keys)]
  {maybeComment(not key.has_set())}syntax {key.setName()} ::= keys({map_name})
  {maybeComment(not key.has_set())}               [function, total, hook(MAP.keys)]

  {maybeComment(key.has_list())}syntax List ::= "keys_list" "(" {map_name} ")"
  {maybeComment(key.has_list())}               [function, hook(MAP.keys_list)]
  {maybeComment(not key.has_list())}syntax {key.listName()} ::= "keys_list" "(" {map_name} ")"
  {maybeComment(not key.has_list())}               [function, hook(MAP.keys_list)]

  syntax Bool ::= {key.wrappedType()} "in_keys" "(" {map_name} ")"
                 [function, total, hook(MAP.in_keys)]

  {maybeComment(value.has_list())}syntax List ::= values({map_name})
  {maybeComment(value.has_list())}               [function, hook(MAP.values)]
  {maybeComment(not value.has_list())}syntax {value.listName()} ::= values({map_name})
  {maybeComment(not value.has_list())}               [function, hook(MAP.values)]

  syntax Int ::= size({map_name})
                 [function, total, hook(MAP.size), symbol({map_name}.sizeMap)]
  syntax Bool ::= {map_name} "<=Map" {map_name}
                 [function, total, hook(MAP.inclusion)]
  syntax {key.wrappedType()} ::= choice({map_name})
                 [function, hook(MAP.choice), symbol({map_name}:choice)]
endmodule

module MAP-{key.Name()}-TO-{value.Name()}-PRIMITIVE
  imports MAP-{key.Name()}-TO-{value.Name()}-PRIMITIVE-CONCRETE
  imports MAP-{key.Name()}-TO-{value.Name()}-PRIMITIVE-SYMBOLIC
endmodule

module MAP-{key.Name()}-TO-{value.Name()}-PRIMITIVE-CONCRETE [concrete]
  imports public  BOOL
  imports private K-EQUAL
  imports public  MAP-{key.Name()}-TO-{value.Name()}

  syntax {value.unwrappedType()} ::= {map_name} "{{{{" {key.unwrappedType()} "}}}}"
                 [function, symbol({map_name}:primitiveLookup)]
  syntax {value.unwrappedType()} ::= {map_name} "{{{{" {key.unwrappedType()} "}}}}" "orDefault" {value.unwrappedType()}
                 [ function, total, symbol({map_name}:primitiveLookupOrDefault) ]
  syntax {map_name} ::= {map_name} "{{{{" key: {key.unwrappedType()} "<-" value: {value.unwrappedType()} "}}}}"
                 [ function, total, symbol({map_name}:primitiveUpdate),
                   prefer
                 ]
  syntax {map_name} ::= {map_name} "{{{{" {key.unwrappedType()} "<-" "undef" "}}}}"
                 [ function, total, symbol({map_name}:primitiveRemove) ]
  syntax Bool ::= {key.unwrappedType()} "in_keys" "{{{{" {map_name} "}}}}"
                 [function, total, symbol({map_name}:primitiveInKeys)]

  rule (M:{map_name} {{{{ Key:{key.unwrappedType()} }}}})
      => ({value.unWrap(f'M[{key.wrap("Key")}]')})
  rule M:{map_name} {{{{ Key:{key.unwrappedType()} }}}} orDefault Value:{value.unwrappedType()}
      => {value.unWrap(f'M[{key.wrap("Key")}] orDefault {value.wrap("Value")}')}
  rule M:{map_name} {{{{ Key:{key.unwrappedType()} <- Value:{value.unwrappedType()} }}}}
      => M[{key.wrap('Key')} <- {value.wrap('Value')}]
  rule M:{map_name} {{{{ Key:{key.unwrappedType()} <- undef }}}}
      => M[{key.wrap('Key')} <- undef]
  rule Key:{key.unwrappedType()} in_keys {{{{ M:{map_name} }}}} => {key.wrap('Key')} in_keys(M)
endmodule

module MAP-{key.Name()}-TO-{value.Name()}-PRIMITIVE-SYMBOLIC  [symbolic]
  imports public  BOOL
  imports private K-EQUAL
  imports public  MAP-{key.Name()}-TO-{value.Name()}
  imports private MAP-{key.Name()}-TO-{value.Name()}-KORE-SYMBOLIC

  syntax {value.unwrappedType()} ::= {map_name} "{{{{" {key.unwrappedType()} "}}}}"
                 [function, symbol({map_name}:primitiveLookup)]
  syntax {value.unwrappedType()} ::= {map_name} "{{{{" {key.unwrappedType()} "}}}}" "orDefault" {value.unwrappedType()}
                 [ function, total, symbol({map_name}:primitiveLookupOrDefault) ]
  syntax {map_name} ::= {map_name} "{{{{" key: {key.unwrappedType()} "<-" value: {value.unwrappedType()} "}}}}"
                 [ function, total, symbol({map_name}:primitiveUpdate),
                   prefer
                 ]
  syntax {map_name} ::= {map_name} "{{{{" {key.unwrappedType()} "<-" "undef" "}}}}"
                 [ function, total, symbol({map_name}:primitiveRemove) ]
  syntax Bool ::= {key.unwrappedType()} "in_keys" "{{{{" {map_name} "}}}}"
                 [function, total, symbol({map_name}:primitiveInKeys)]

  // Definitions
  // -----------

  rule ({key.wrap('Key')} {map_short}|-> V:{value.wrappedType()} M:{map_name})
          {{{{ Key:{key.unwrappedType()} }}}}
      => {value.unWrap('V')}
      ensures notBool Key in_keys {{{{ M }}}}

  rule ({key.wrap('Key')} {map_short}|-> V:{value.wrappedType()} M:{map_name})
          {{{{ Key:{key.unwrappedType()} }}}} orDefault _:{value.unwrappedType()}
      => {value.unWrap('V')}
      ensures notBool Key in_keys {{{{ M }}}}
  rule M:{map_name} {{{{ Key:{key.unwrappedType()} }}}} orDefault V:{value.unwrappedType()}
      => V
      requires notBool Key in_keys {{{{ M }}}}

  rule ({key.wrap('Key')} {map_short}|-> _:{value.wrappedType()} M:{map_name})
          {{{{ Key:{key.unwrappedType()} <- Value:{value.unwrappedType()} }}}}
      => ({key.wrap('Key')} {map_short}|-> {value.wrap('Value')}) M
  rule M:{map_name} {{{{ Key:{key.unwrappedType()} <- Value:{value.unwrappedType()} }}}}
      => ({key.wrap('Key')} {map_short}|-> {value.wrap('Value')}) M
      requires notBool Key in_keys {{{{ M }}}}

  rule ({key.wrap('Key')} {map_short}|-> _:{value.wrappedType()} M:{map_name})
          {{{{ Key:{key.unwrappedType()} <- undef }}}}
      => M
      ensures notBool Key in_keys {{{{ M }}}}
  rule M:{map_name} {{{{ Key:{key.unwrappedType()} <- undef }}}}
      => M
      requires notBool Key in_keys {{{{ M }}}}

  rule Key:{key.unwrappedType()} in_keys
          {{{{{key.wrap('Key')} {map_short}|-> _:{value.wrappedType()} M:{map_name}}}}}
      => true
      ensures notBool Key in_keys {{{{ M }}}}
  rule _Key:{key.unwrappedType()} in_keys {{{{ .{map_name} }}}}
      => false
  // TODO: This may create an exponential evaluation tree, depending on how
  // caching works in the backend. It should be rewritten to finish in
  // O(n^2) or something like that, where n is the number of explicit keys
  // in the map.
  rule Key:{key.unwrappedType()} in_keys
          {{{{Key2:{key.wrappedType()} {map_short}|-> _:{value.wrappedType()} M:{map_name}}}}}
      => Key in_keys {{{{ M }}}}
      requires Key =/=K {key.unWrap('Key2')}
      ensures notBool Key2 in_keys (M)
      [simplification]

  // Translation rules
  rule M:{map_name}[Key:{key.wrappedType()}]
      => {value.wrap(f'M{{{{{key.unWrap("Key")}}}}}')}
      [simplification, symbolic(M)]
  rule M:{map_name}[Key:{key.wrappedType()}]
      => {value.wrap(f'M{{{{{key.unWrap("Key")}}}}}')}
      [simplification, symbolic(Key)]
  rule M:{map_name}{{{{Key}}}}
      => {value.unWrap(f'M[{key.wrap("Key")}]')}
      [simplification, concrete]

  rule M:{map_name} [ Key:{key.wrappedType()} ] orDefault Value:{value.wrappedType()}
      => {value.wrap(f'M {{{{ {key.unWrap("Key")} }}}} orDefault {value.unWrap("Value")}')}
      [simplification, symbolic(M)]
  rule M:{map_name} [ Key:{key.wrappedType()} ] orDefault Value:{value.wrappedType()}
      => {value.wrap(f'M {{{{ {key.unWrap("Key")} }}}} orDefault {value.unWrap("Value")}')}
      [simplification, symbolic(Key)]
  rule M:{map_name} [ Key:{key.wrappedType()} ] orDefault Value:{value.wrappedType()}
      => {value.wrap(f'M {{{{ {key.unWrap("Key")} }}}} orDefault {value.unWrap("Value")}')}
      [simplification, symbolic(Value)]
  rule M:{map_name}{{{{Key}}}} orDefault Value
      => {value.unWrap(f'M[{key.wrap("Key")}] orDefault {value.wrap("Value")}')}
      [simplification, concrete]

  rule M:{map_name}[Key:{key.wrappedType()} <- Value:{value.wrappedType()}]
      => M {{{{ {key.unWrap('Key')} <- {value.unWrap('Value')} }}}}
      [simplification, symbolic(M)]
  rule M:{map_name}[Key:{key.wrappedType()} <- Value:{value.wrappedType()}]
      => M {{{{ {key.unWrap('Key')} <- {value.unWrap('Value')} }}}}
      [simplification, symbolic(Key)]
  rule M:{map_name}[Key:{key.wrappedType()} <- Value:{value.wrappedType()}]
      => M {{{{ {key.unWrap('Key')} <- {value.unWrap('Value')} }}}}
      [simplification, symbolic(Value)]
  rule M:{map_name}{{{{Key <- Value}}}} => M[{key.wrap('Key')} <- {value.wrap('Value')} ]
      [simplification, concrete]

  rule M:{map_name}[Key:{key.wrappedType()} <- undef]
      => M {{{{ {key.unWrap('Key')} <- undef }}}}
      [simplification, symbolic(M)]
  rule M:{map_name}[Key:{key.wrappedType()} <- undef]
      => M {{{{ {key.unWrap('Key')} <- undef }}}}
      [simplification, symbolic(Key)]
  rule M:{map_name}{{{{Key <- undef}}}} => M[{key.wrap('Key')} <- undef]
      [simplification, concrete]

  rule Key:{key.wrappedType()} in_keys (M:{map_name})
      => {key.unWrap('Key')} in_keys {{{{M}}}}
      [simplification, symbolic(M)]
  rule Key:{key.wrappedType()} in_keys (M:{map_name})
      => {key.unWrap('Key')} in_keys {{{{M}}}}
      [simplification, symbolic(Key)]
  rule Key in_keys {{{{M:{map_name}}}}} => {key.wrap('Key')} in_keys(M)
      [simplification, concrete]

  // Symbolic execution rules
  // ------------------------
  syntax Bool ::= definedPrimitiveLookup({map_name}, {key.unwrappedType()})  [function, total]
  rule definedPrimitiveLookup(M:{map_name}, K:{key.unwrappedType()}) => K in_keys{{{{M}}}}

  rule #Ceil(@M:{map_name} {{{{@K:{key.unwrappedType()}}}}})
      => {{definedPrimitiveLookup(@M, @K) #Equals true}}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule M:{map_name} {{{{ K <- _ }}}} {{{{ K <- V }}}} => M {{{{ K <- V }}}} [simplification]
  rule (K1 {map_short}|-> V1 M:{map_name}) {{{{ K2 <- V2 }}}}
      => (K1 {map_short}|-> V1 (M {{{{ K2 <- V2 }}}}))
      requires {key.unWrap('K1')} =/=K K2
      [simplification, preserves-definedness]

  rule (K1 {map_short}|-> V1 M:{map_name}) {{{{ K2 <- undef }}}}
      => (K1 {map_short}|-> V1 (M {{{{ K2 <- undef }}}}))
      requires {key.unWrap('K1')} =/=K K2
      [simplification, preserves-definedness]

  rule (K1 {map_short}|-> _V M:{map_name}) {{{{ K2 }}}} => M {{{{K2}}}}
      requires {key.unWrap('K1')} =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:{map_name} {{{{ K  <-  V1 }}}}) {{{{ K }}}}  => V1 [simplification]
  rule ( MAP:{map_name} {{{{ K1 <- _V1 }}}}) {{{{ K2 }}}} => MAP {{{{ K2 }}}}
      requires K1 =/=K K2
      [simplification]

  rule (K1 {map_short}|-> _V M:{map_name}) {{{{ K2 }}}} orDefault D
      => M {{{{K2}}}} orDefault D
      requires {key.unWrap('K1')} =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:{map_name} {{{{ K  <-  V1 }}}}) {{{{ K }}}} orDefault _ => V1 [simplification]
  rule ( MAP:{map_name} {{{{ K1 <- _V1 }}}}) {{{{ K2 }}}} orDefault D
      => MAP {{{{ K2 }}}} orDefault D
      requires K1 =/=K K2
      [simplification]

  rule K in_keys{{{{_M:{map_name} {{{{ K <- undef }}}} }}}} => false [simplification]
  rule K in_keys{{{{_M:{map_name} {{{{ K <- _ }}}} }}}} => true [simplification]
  rule K1 in_keys{{{{ _M:{map_name} {{{{ K2 <- _ }}}} }}}}
      => true requires K1 ==K K2
      [simplification]
  rule K1 in_keys{{{{ M:{map_name} {{{{ K2 <- _ }}}} }}}}
      => K1 in_keys {{{{ M }}}}
      requires K1 =/=K K2
      [simplification]

  rule K1 in_keys {{{{ (K2 {map_short}|-> V) M:{map_name} }}}}
      => K1 ==K {key.unWrap('K2')} orBool K1 in_keys {{{{ M }}}}
    requires definedMapElementConcat(K2, V, M)
    [simplification(100), preserves-definedness]


  rule {{false #Equals @Key in_keys{{{{ Key' {map_short}|-> Val @M:{map_name} }}}}}}
      =>  #Ceil(@Key) #And #Ceil(Key' {map_short}|-> Val @M)
          #And #Not({{ @Key #Equals {key.unWrap("Key'")} }})
          #And {{false #Equals @Key in_keys{{{{@M}}}}}}
      [simplification]
  rule {{@Key in_keys{{{{Key' {map_short}|-> Val @M:{map_name}}}}} #Equals false}}
      =>  #Ceil(@Key) #And #Ceil(Key' {map_short}|-> Val @M)
          #And #Not({{@Key #Equals {key.unWrap("Key'")} }})
          #And {{@Key in_keys{{{{@M}}}} #Equals false}}
      [simplification]

endmodule

module MAP-{key.Name()}-TO-{value.Name()}-KORE-SYMBOLIC
  imports MAP-{key.Name()}-TO-{value.Name()}
  imports private K-EQUAL
  imports private BOOL

  syntax Bool ::= definedMapElementConcat({key.wrappedType()}, {value.wrappedType()}, {map_name})  [function, total]
  rule definedMapElementConcat(K, _V, M:{map_name}) => notBool K in_keys(M)

  rule #Ceil(@M:{map_name} [@K:{key.wrappedType()}])
      => {{(@K in_keys(@M)) #Equals true}}
          #And #Ceil(@M) #And #Ceil(@K)
      [simplification]

  rule (K {map_short}|-> _ M:{map_name}) [ K <- V ] => (K {map_short}|-> V M)
      [simplification, preserves-definedness]
  rule M:{map_name} [ K <- V ] => (K {map_short}|-> V M) requires notBool (K in_keys(M))
      [simplification, preserves-definedness]
  rule M:{map_name} [ K <- _ ] [ K <- V ] => M [ K <- V ] [simplification]
  rule (K1 {map_short}|-> V1 M:{map_name}) [ K2 <- V2 ] => (K1 {map_short}|-> V1 (M [ K2 <- V2 ]))
      requires K1 =/=K K2
      [simplification, preserves-definedness]

  rule (K {map_short}|-> _ M:{map_name}) [ K <- undef ] => M
      ensures notBool (K in_keys(M))
      [simplification]
  rule M:{map_name} [ K <- undef ] => M
      requires notBool (K in_keys(M))
      [simplification]
  rule (K1 {map_short}|-> V1 M:{map_name}) [ K2 <- undef ]
      => (K1 {map_short}|-> V1 (M [ K2 <- undef ]))
      requires K1 =/=K K2
      [simplification, preserves-definedness]

  rule (K  {map_short}|->  V M:{map_name}) [ K ] => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 {map_short}|-> _V M:{map_name}) [ K2 ] => M [K2]
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:{map_name} [ K  <-  V1 ]) [ K ]  => V1 [simplification]
  rule ( MAP:{map_name} [ K1 <- _V1 ]) [ K2 ] => MAP [ K2 ]
      requires K1 =/=K K2
      [simplification]

  rule (K  {map_short}|->  V M:{map_name}) [  K ] orDefault _ => V
      ensures notBool (K in_keys(M))
      [simplification]
  rule (K1 {map_short}|-> _V M:{map_name}) [ K2 ] orDefault D
      => M [K2] orDefault D
      requires K1 =/=K K2
      ensures notBool (K1 in_keys(M))
      [simplification]
  rule (_MAP:{map_name} [ K  <-  V1 ]) [ K ] orDefault _ => V1 [simplification]
  rule ( MAP:{map_name} [ K1 <- _V1 ]) [ K2 ] orDefault D
      => MAP [ K2 ] orDefault D
      requires K1 =/=K K2
      [simplification]
  rule .{map_name} [ _ ] orDefault D => D [simplification]

  rule K in_keys(_M:{map_name} [ K <- undef ]) => false [simplification]
  rule K in_keys(_M:{map_name} [ K <- _ ]) => true [simplification]
  rule K1 in_keys(M:{map_name} [ K2 <- _ ])
      => true requires K1 ==K K2 orBool K1 in_keys(M)
      [simplification]
  rule K1 in_keys(M:{map_name} [ K2 <- _ ])
      => K1 in_keys(M)
      requires K1 =/=K K2
      [simplification]

  rule K in_keys((K {map_short}|-> V) M:{map_name})
      => true
    requires definedMapElementConcat(K, V, M)
    [simplification(50), preserves-definedness]
  rule K1 in_keys((K2 {map_short}|-> V) M:{map_name})
      => K1 in_keys(M)
    requires true
        andBool definedMapElementConcat(K2, V, M)
        andBool K1 =/=K K2
    [simplification(50), preserves-definedness]
  rule K1 in_keys((K2 {map_short}|-> V) M:{map_name})
      => K1 ==K K2 orBool K1 in_keys(M)
    requires definedMapElementConcat(K2, V, M)
    [simplification(100), preserves-definedness]


  rule {{false #Equals @Key in_keys(.{map_name})}} => #Ceil(@Key) [simplification]
  rule {{@Key in_keys(.{map_name}) #Equals false}} => #Ceil(@Key) [simplification]
  rule {{false #Equals @Key in_keys(Key' {map_short}|-> Val @M:{map_name})}}
      =>  #Ceil(@Key) #And #Ceil(Key' {map_short}|-> Val @M)
          #And #Not({{@Key #Equals Key'}})
          #And {{false #Equals @Key in_keys(@M)}}
      [simplification]
  rule {{@Key in_keys(Key' {map_short}|-> Val @M:{map_name}) #Equals false}}
      =>  #Ceil(@Key) #And #Ceil(Key' {map_short}|-> Val @M)
          #And #Not({{@Key #Equals Key'}})
          #And {{@Key in_keys(@M) #Equals false}}
      [simplification]
endmodule

module MAP-{key.Name()}-TO-{value.Name()}-CURLY-BRACE
  imports private BOOL
  imports private K-EQUAL-SYNTAX
  imports MAP-{key.Name()}-TO-{value.Name()}

  syntax {map_name} ::= {map_name} "{{" key:{key.wrappedType()} "<-" value:{value.wrappedType()} "}}"
      [function, total, symbol({map_name}:curly_update)]
  rule M:{map_name}{{Key <- Value}} => M (Key {map_short}|-> Value)
    requires notBool Key in_keys(M)
  rule (Key {map_short}|-> _ M:{map_name}){{Key <- Value}}
      => M (Key {map_short}|-> Value)
  rule (M:{map_name}{{Key <- Value}})(A {map_short}|-> B N:{map_name})
      => (M (A {map_short}|-> B)) {{Key <- Value}} N
      requires notBool A ==K Key
      [simplification, preserves-definedness]

  rule M:{map_name}{{Key1 <- Value1}}[Key2 <- Value2]
      => ((M:{map_name}[Key2 <- Value2]{{Key1 <- Value1}}) #And #Not ({{Key1 #Equals Key2}}))
        #Or ((M:{map_name}[Key2 <- Value2]) #And {{Key1 #Equals Key2}})
      [simplification(20)]
  rule M:{map_name}[Key <- Value]
      => M:{map_name}{{Key <- Value}}
      [simplification(100)]
  rule M:{map_name}{{Key1 <- _Value1}}[Key2] orDefault Value2
      => M[Key2] orDefault Value2
      requires Key1 =/=K Key2
      [simplification]
  rule _M:{map_name}{{Key <- Value1}}[Key] orDefault _Value2
      => Value1
      [simplification]
  // rule M:{map_name}{{Key1 <- Value1}}[Key2] orDefault Value2
  //     => (M[Key2] orDefault Value2 #And #Not ({{Key1 #Equals Key2}}))
  //       #Or (Value1 #And {{Key1 #Equals Key2}})
  //     [simplification]
  rule M:{map_name}{{Key1 <- Value1}}[Key2]
      => (M[Key2] #And #Not ({{Key1 #Equals Key2}}))
        #Or (Value1 #And {{Key1 #Equals Key2}})
      [simplification]

  rule Key1 in_keys(_:{map_name}{{Key1 <- _}})
      => true
      [simplification(50)]
  rule Key1 in_keys(M:{map_name}{{Key2 <- _}})
      => Key1 in_keys(M)
      requires notBool Key1 ==K Key2
      [simplification(50)]
  rule K1 in_keys(M:{map_name} {{ K2 <- _ }})
      => K1 ==K K2 orBool K1 in_keys(M)
    [simplification(100)]

endmodule
'''

def make_set(key:Properties):
    return f'''
module SET-{key.Name()}
  imports private INT-SYNTAX
  imports private BASIC-K

  syntax {key.setName()} [hook(SET.Set)]
  syntax {key.setName()} ::= {key.setName()} {key.setName()}
          [ left, function, hook(SET.concat), symbol(_{key.setName()}_),
            assoc, comm, unit(.{key.setName()}), idem, element({key.setName()}Item), format(%1%n%2)
          ]
  syntax {key.setName()} ::= ".{key.setName()}"
          [ function, total, hook(SET.unit), symbol(.{key.setName()}) ]
  syntax {key.setName()} ::= {key.setName()}Item({key.name()})
          [ function, total, hook(SET.element), symbol({key.setName()}Item),
            injective
          ]
  syntax {key.setName()} ::= {key.setName()} "|Set" {key.setName()}
          [left, function, total, hook(SET.union), comm]
  rule S1:{key.setName()} |Set S2:{key.setName()}
      => S1 (S2 -Set S1) [concrete]
  syntax {key.setName()} ::= intersectSet({key.setName()}, {key.setName()})
          [function, total, hook(SET.intersection), comm]
  syntax {key.setName()} ::= {key.setName()} "-Set" {key.setName()}
          [ function, total, hook(SET.difference),
            symbol({key.setName()}:difference)
          ]
  syntax Bool ::= {key.Name()} "in" {key.setName()}
          [function, total, hook(SET.in), symbol({key.setName()}:in)]
  syntax Bool ::= {key.setName()} "<=Set" {key.setName()}
          [function, total, hook(SET.inclusion)]
  syntax Int ::= size({key.setName()})
          [function, total, hook(SET.size)]
  syntax {key.Name()} ::= choice({key.setName()})
          [function, hook(SET.choice), symbol({key.setName()}:choice)]
endmodule

module SET-{key.Name()}-KORE-SYMBOLIC [kore,symbolic]
  imports SET
  imports private K-EQUAL
  imports private BOOL

  rule #Ceil(@S:Set SetItem(@E:{key.Name()})) =>
         {{(@E in @S) #Equals false}} #And #Ceil(@S) #And #Ceil(@E)
    [simplification]

  rule S                          -Set .{key.setName()}           => S
      [simplification]
  rule .{key.setName()}           -Set _                          => .{key.setName()}
      [simplification]
  rule {key.setName()}Item(X)     -Set (S {key.setName()}Item(X)) => .{key.setName()}
      ensures notBool (X in S)
      [simplification]
  rule S                          -Set (S {key.setName()}Item(X)) => .{key.setName()}
      ensures notBool (X in S)
      [simplification]
  rule (S {key.setName()}Item(X)) -Set S                          => {key.setName()}Item(X)
      ensures notBool (X in S)
      [simplification]
  rule (S {key.setName()}Item(X)) -Set {key.setName()}Item(X)     => S
      ensures notBool (X in S)
      [simplification]

  rule S                          |Set .{key.setName()}       => S    [simplification, comm]
  rule S                          |Set S                      => S    [simplification]
  rule (S {key.setName()}Item(X)) |Set {key.setName()}Item(X) => S {key.setName()}Item(X)
      ensures notBool (X in S)
      [simplification, comm]

  rule intersectSet(.{key.setName()}, _   ) => .{key.setName()}    [simplification, comm]
  rule intersectSet( S  , S   ) =>  S      [simplification]

  rule intersectSet( S {key.setName()}Item(X), {key.setName()}Item(X))
          => {key.setName()}Item(X)
      ensures notBool (X in S)
      [simplification, comm]
  rule intersectSet( S1 {key.setName()}Item(X), S2 {key.setName()}Item(X))
          => intersectSet(S1, S2) {key.setName()}Item(X)
      ensures   notBool (X in S1)
        andBool notBool (X in S2)
      [simplification]

  rule _E in .{key.setName()}           => false   [simplification]
  rule E  in (S {key.setName()}Item(E)) => true
              ensures notBool (E in S) [simplification]

  rule X in (({key.setName()}Item(X) S) |Set  _            ) => true
                                    ensures notBool (X in S) [simplification]
  rule X in ( _                         |Set ({key.setName()}Item(X) S)) => true
                                    ensures notBool (X in S) [simplification]

endmodule
'''

def make_list(value:Properties):
    wrapped_value = value.wrap('Value')
    return f'''{maybeComment(not value.is_primitive())}requires "{type_code_name(value)}"

module LIST-{value.Name()}
  imports private INT-SYNTAX
  imports private BASIC-K
  {maybeComment(not value.is_primitive)}imports {type_code_module(value)}

  syntax {value.name()}

  syntax {value.listName()} [hook(LIST.List)]
  syntax {value.listName()} ::= {value.listName()} {value.listName()}
          [ left, function, total, hook(LIST.concat),
            symbol(_{value.listName()}_), smtlib(smt_seq_concat),
            assoc, unit(.{value.listName()}), element({value.listName()}Item),
            format(%1%n%2)
          ]
  syntax {value.listName()} ::= ".{value.listName()}"
          [ function, total, hook(LIST.unit), symbol(.{value.listName()}),
            smtlib(smt_seq_nil)
          ]
  syntax {value.listName()} ::= ListItem({value.wrappedType()})
          [ function, total, hook(LIST.element), symbol({value.listName()}Item),
            smtlib(smt_seq_elem)
          ]
  syntax {value.wrappedType()} ::= {value.listName()} "[" Int "]"
          [ function, hook(LIST.get), symbol({value.listName()}:get) ]
  syntax {value.listName()} ::= {value.listName()} "[" index: Int "<-" value: {value.wrappedType()} "]"
          [function, hook(LIST.update), symbol({value.listName()}:set)]
  syntax {value.listName()} ::= make{value.listName()}(length: Int, value: {value.wrappedType()})
          [function, hook(LIST.make)]
  syntax {value.listName()} ::= updateList(dest: {value.listName()}, index: Int, src: {value.listName()})
          [function, hook(LIST.updateAll)]
  syntax {value.listName()} ::= fillList({value.listName()}, index: Int, length: Int, value: {value.wrappedType()})
          [function, hook(LIST.fill)]
  syntax {value.listName()} ::= range({value.listName()}, fromFront: Int, fromBack: Int)
          [function, hook(LIST.range), symbol({value.listName()}:range)]
  syntax Bool ::= {value.wrappedType()} "in" {value.listName()}
          [function, total, hook(LIST.in), symbol(_in{value.listName()}_)]
  syntax Int ::= size({value.listName()})
          [function, total, hook(LIST.size), symbol(size{value.listName()}), smtlib(smt_seq_len)]
endmodule

module LIST-{value.Name()}-PRIMITIVE
  imports BOOL
  imports INT
  imports LIST-{value.Name()}

  syntax {value.wrappedType()} ::= {value.listName()} "[" Int "]" "orDefault" {value.wrappedType()}
          [ function, total, symbol({value.listName()}:getOrDefault) ]

  syntax {value.unwrappedType()} ::= {value.listName()} "{{{{" Int "}}}}"
                 [function, symbol({value.listName()}:primitiveLookup)]
// -----------------------------------------------------------
  rule L:{value.listName()} {{{{ I:Int }}}} => {value.unWrap('L[ I ]')}

  syntax {value.unwrappedType()} ::= {value.listName()} "{{{{" Int "}}}}" "orDefault" {value.unwrappedType()}
                 [ function, total, symbol({value.listName()}:primitiveLookupOrDefault) ]
// -----------------------------------------------------------------------------
  rule L:{value.listName()} {{{{ I:Int }}}} orDefault Value:{value.unwrappedType()}
      => {value.unWrap(f'L [I] orDefault {wrapped_value}')}

  rule ListItem(V:{value.wrappedType()}) _:{value.listName()} [0] orDefault _:{value.wrappedType()}
      => V
  rule _:{value.listName()} ListItem(V:{value.wrappedType()}) [-1] orDefault _:{value.wrappedType()}
      => V
  rule .{value.listName()} [_:Int] orDefault D:{value.wrappedType()} => D

  rule ListItem(_:{value.wrappedType()}) L:{value.listName()} [I:Int] orDefault D:{value.wrappedType()}
      => L[I -Int 1] orDefault D
    requires 0 <Int I
  rule L:{value.listName()} ListItem(_:{value.wrappedType()}) [I:Int] orDefault D:{value.wrappedType()}
      => L[I +Int 1] orDefault D
    requires I <Int 0

  rule L:{value.listName()}[I:Int] orDefault D:{value.wrappedType()} => D
    requires notBool (0 -Int size(L) <=Int I andBool I <Int size(L))
    [simplification]

  syntax {value.listName()} ::= ListItemWrap( {value.unwrappedType()} )
      [function, total, symbol({value.listName()}ItemWrap)]
  rule ListItemWrap( B:{value.unwrappedType()} ) => ListItem({value.wrap('B')})


  syntax {value.listName()} ::= {value.listName()} "{{{{" Int "<-" {value.unwrappedType()} "}}}}"
                 [function, symbol({value.listName()}:primitiveSet)]
// -----------------------------------------------------------
  rule L:{value.listName()} {{{{ I:Int <- V:{value.unwrappedType()} }}}}
      => L[ I <- {value.wrap('V')}]

  // Workaround for the Haskell backend missing the range hook.
  // See https://github.com/runtimeverification/haskell-backend/issues/3706
  rule range(ListItem(_) L:{value.listName()}, FromStart:Int, FromEnd:Int)
      => range(L, FromStart -Int 1, FromEnd)
      requires 0 <Int FromStart
  rule range(L:{value.listName()} ListItem(_), 0, FromEnd:Int)
      => range(L, 0, FromEnd -Int 1)
      requires 0 <Int FromEnd
  rule range(L:{value.listName()}, 0, 0)
      => L

  syntax Bool ::= rangeDefined({value.listName()}, fromStart:Int, fromEnd:Int)  [function, total]
  rule rangeDefined(L:{value.listName()}, FromStart:Int, FromEnd:Int)
      => 0 <=Int FromStart
        andBool 0 <=Int FromEnd
        andBool FromStart +Int FromEnd <=Int size(L)

  rule #Ceil(range(L:{value.listName()}, FromStart:Int, FromEnd:Int))
      => {{true #Equals rangeDefined(L, FromStart, FromEnd)}}
      [simplification]

  syntax {value.listName()} ::= rangeTotal({value.listName()}, Int, Int)
      [function, total, symbol({value.listName()}:rangeTotal)]
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
  
  rule rangeTotal(L, Front, Back) => .{value.listName()}
    requires 0 <=Int Front
     andBool 0 <=Int Back 
     andBool size(L) <Int Front +Int Back

endmodule
'''

def make_collections_module(value:Properties) -> str:
    if value.has_list():
        if value.has_set():
          return f'''
module COLLECTIONS-{value.Name()}
  imports LIST-{value.Name()}
  imports SET-{value.Name()}

  syntax {value.listName()} ::= Set2List({value.setName()}) [function, total, hook(SET.set2list)]
  syntax {value.setName()} ::= List2Set({value.listName()}) [function, total, hook(SET.list2set)]

endmodule
'''
    return ''


def make_type(value:Properties):
    if value.is_primitive():
        unwrapped_type = value.name()
        wrapped_type = f'Wrapped{value.name()}'
        imports = '\n'.join([f'  import {i}' for i in value.imports()])
        if imports:
            imports = imports + '\n'
        return f'''
module {type_code_module(value)}
{imports}
  syntax {wrapped_type}
  syntax {unwrapped_type}

  syntax {wrapped_type} ::= wrap({unwrapped_type})  [symbol(wrap{unwrapped_type})]
  syntax {unwrapped_type} ::= unwrap({wrapped_type})  [function, total, injective, symbol(unwrap{unwrapped_type})]
  rule unwrap(wrap(A:{unwrapped_type})) => A
endmodule
'''
    return ''


def set_name(value:Properties) -> str:
    return f'set-{value.Name().lower()}.k'


def list_name(value:Properties) -> str:
    return f'list-{value.Name().lower()}.k'


def map_name(m:Map) -> str:
    return f'map-{m.key_name().lower()}-to-{m.value_name().lower()}.k'


def type_code_name(value:Properties) -> str:
    return f'{type_code_module(value).lower()}.k'


def type_code_module(value:Properties) -> str:
    return f'{value.Name()}-TYPE'


def make_collections(types:dict[str, Properties], maps:list[Map], destination:Path) -> None:
    for s in types.keys():
        t = types[s]
        type_code = make_type(t)
        if type_code:
            (destination / type_code_name(t)).write_text(type_code)
        if t.has_list():
          list_code = make_list(t)
          (destination / list_name(t)).write_text(list_code)
        if t.has_set():
          set_code = make_set(t)
          (destination / set_name(t)).write_text(set_code)
    for m in maps:
        map_code = make_map(types[m.key_name()], types[m.value_name()], m.short_name())
        if map_code:
            (destination / map_name(m)).write_text(map_code)

def writeCollections(types:dict[str, Properties], maps:list[Map], file:Path) -> None:
    # with open(file, 'w') as f:
        # f.write(make_collections(types, maps))
    make_collections(types, maps, file)

def loadType(line, types):
    items = line.split(' ')
    assert items[0] == 'type'
    assert len(items) > 1, [line]
    assert len(items) < 8, [line]
    name = items[1]
    has_list = False
    has_set = False
    is_primitive = False
    imports = []
    default = None
    for item in items[2:]:
        if item == 'list':
            assert not has_list
            has_list = True
        elif item == 'set':
            assert not has_set
            has_set = True
        elif item == 'primitive':
            assert not is_primitive
            is_primitive = True
        elif item.startswith('import:'):
            imports.append(item[len('import:'):])
        elif item.startswith('default:'):
            default = item[len('default:'):]
        else:
            assert False, [item, line]
    types[name] = Properties(
        name=name, has_set=has_set, has_list=has_list,
        is_primitive=is_primitive, imports=imports,
        default=default
    )

def loadMap(line:str, maps:list[Map]) -> None:
    items = line.split(' ')
    assert items[0] == 'map'
    assert len(items) == 4, [line]
    short_name = items[1]
    key_name = items[2]
    value_name = items[3]
    maps.append(Map(short_name=short_name, key_name=key_name, value_name=value_name))

def loadConfig(file:str) -> tuple[dict[str, Properties], list[Map]]:
    types = {}
    maps = []
    with open(file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith('type '):
                loadType(line, types)
            else:
                assert line.startswith('map '), [line]
                loadMap(line, maps)
    return (types, maps)

def main(argv):
    types, maps = loadConfig(argv[0])

    destination = Path(f"{argv[0]}.k")
    destination.mkdir(parents=True, exist_ok=True)
    writeCollections(types, maps, destination)

if __name__ == '__main__':
    main(sys.argv[1:])
