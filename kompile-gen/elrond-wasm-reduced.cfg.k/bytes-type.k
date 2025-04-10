
module BYTES-TYPE
  import BYTES-SYNTAX

  syntax WrappedBytes
  syntax Bytes

  syntax WrappedBytes ::= wrap(Bytes)  [symbol(wrapBytes)]
  syntax Bytes ::= unwrap(WrappedBytes)  [function, total, injective, symbol(unwrapBytes)]
  rule unwrap(wrap(A:Bytes)) => A
endmodule
