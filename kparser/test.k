// 
/*@

This is the syntax of LLVM.

The LLVM code representation is designed to be used in three different forms:
 as an in-memory compiler IR, as an on-disk bitcode representation 
(suitable for fast loading by a Just-In-Time compiler), 
and as a human readable assembly language representation. 
This allows LLVM to provide a powerful intermediate representation 
for efficient compiler transformations and analysis, 
while providing a natural means to debug and visualize the transformations. 
The three different forms of LLVM are all equivalent. 
This document describes the human readable representation and notation.

This syntax requires a input LLVM program without comments.
*/

module LLVM-PARSING-ONLY-SYNTAX
    /*@
      Define syntactic constructors for non-keyword tokens. 
      Standard integers (such as ‘4’) are constants of the integer type.
      Negative numbers may be used with integer types.
    */
    syntax HexConstant ::= r"[us]?[0][x][KMLH]?[0-9a-fA-F]*" [token]
    syntax UnsignedInt ::= r"[0-9][0-9]*" [token]

endmodule