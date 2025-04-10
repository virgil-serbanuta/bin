
module INT-TYPE
  import INT

  syntax WrappedInt
  syntax Int

  syntax WrappedInt ::= wrap(Int)  [symbol(wrapInt)]
  syntax Int ::= unwrap(WrappedInt)  [function, total, injective, symbol(unwrapInt)]
  rule unwrap(wrap(A:Int)) => A
endmodule
