requires "../lemmas.k"

module VERIFICATION
    imports LEMMAS

    syntax StepSort ::= Map | WordStack
 // -----------------------------------

    syntax KItem ::= runLemma ( StepSort )
                   | doneLemma( StepSort )
 // --------------------------------------
    rule runLemma( T ) => doneLemma( T )

endmodule

module LEMMAS-SPEC
    imports VERIFICATION

 // Buffer write simplifications
 // ----------------------------

    rule <k> runLemma  ( M [ L := .WordStack ] [ N := WS:WordStack ]                             ) => doneLemma ( M [ N := WS ]                        ) ... </k>
    rule <k> runLemma  ( M [ L := WS:WordStack ] [ N := .WordStack ]                             ) => doneLemma ( M [ L := WS ]                        ) ... </k>
    rule <k> runLemma  ( M [ 32 := (0 : 1 : 2 : .WordStack) ] [ 32 := (3 : 4 : 5 : .WordStack) ] ) => doneLemma ( M [ 32 := (3 : 4 : 5 : .WordStack) ] ) ... </k>

 // #range selection operation
 // --------------------------

    // Non-positive range
    rule <k> runLemma ( #range(M, N,  0) ) => doneLemma ( .WordStack ) ... </k>
    rule <k> runLemma ( #range(M, N, -3) ) => doneLemma ( .WordStack ) ... </k>

    // Range outside of previous buffer write
    rule <k> runLemma ( #range(M [ 32 := BUF:WordStack ], 20, 4) ) => doneLemma ( #range(M, 20, 4) ) ... </k>
    rule <k> runLemma ( #range(M [ 32 := BUF:WordStack ], 48, 4) ) => doneLemma ( #range(M, 48, 4) ) ... </k> requires #sizeWordStack(BUF) <=Int 12
    rule <k> runLemma ( #range(M [ 32 := BUF:WordStack ], 31, 1) ) => doneLemma ( #range(M, 31, 1) ) ... </k>
    rule <k> runLemma ( #range(M [ 32 := #buf(1, BUF) ], 33, 1) )  => doneLemma ( #range(M, 33, 1) ) ... </k>

    // Range starting before buffer write
    rule <k> runLemma ( #range(M [ 32 := BUF:WordStack ]            , 30 , 8) ) => doneLemma ( #range(M, 30, 2) ++ (BUF [ 0 .. 6 ])                             ) ... </k> requires #sizeWordStack(BUF) >=Int 6
    rule <k> runLemma ( #range(M [ 32 := (0 : 1 : 2 : .WordStack) ] , 30 , 8) ) => doneLemma ( #range(M, 30, 2) ++ (0 : 1 : 2 : .WordStack) ++ #range(M, 35, 3) ) ... </k>
    rule <k> runLemma ( #range(M [ 32 := #buf(2, BUF) ]             , 31 , 2) ) => doneLemma ( #range(M, 31, 1) ++ (#buf(2, BUF) [ 0 .. 1 ])                    ) ... </k>
    rule <k> runLemma ( #range(M [ 32 := #buf(1, BUF) ]             , 31 , 2) ) => doneLemma ( #range(M, 31, 1) ++ #buf(1, BUF)                                 ) ... </k>
    rule <k> runLemma ( #range(M [ 32 := #buf(1, BUF) ]             , 31 , 3) ) => doneLemma ( #range(M, 31, 1) ++ #buf(1, BUF) ++ #range(M, 33, 1)             ) ... </k>

    // Range starting at same point as buffer write
    rule <k> runLemma ( #range(M [ 32 := BUF:WordStack ]            , 32 , 7) ) => doneLemma( BUF [ 0 .. 7 ]                               ) ... </k> requires #sizeWordStack(BUF) >=Int 7
    rule <k> runLemma ( #range(M [ 32 := (0 : 1 : 2 : .WordStack) ] , 32 , 7) ) => doneLemma( (0 : 1 : 2 : .WordStack) ++ #range(M, 35, 4) ) ... </k>
    rule <k> runLemma ( #range(M [ 32 := #buf(2, BUF) ]             , 32 , 1) ) => doneLemma( #buf(2, BUF) [ 0 .. 1 ]                      ) ... </k>
    rule <k> runLemma ( #range(M [ 32 := #buf(1, BUF) ]             , 32 , 1) ) => doneLemma( #buf(1, BUF)                                 ) ... </k>
    rule <k> runLemma ( #range(M [ 32 := #buf(1, BUF) ]             , 32 , 2) ) => doneLemma( #buf(1, BUF) ++ #range(M, 33, 1)             ) ... </k>

    // Range starting in the middle of the buffer write
    rule <k> runLemma ( #range(M [ 32 := (0 : 1 : 2 : 3 : 4 : .WordStack) ] , 35 , 2) ) => doneLemma( (3 : 4 : .WordStack)                      ) ... </k>
    rule <k> runLemma ( #range(M [ 32 := (0 : 1 : 2 : 3 : 4 : .WordStack) ] , 35 , 8) ) => doneLemma( (3 : 4 : .WordStack) ++ #range(M, 37, 6)  ) ... </k>
    rule <k> runLemma ( #range(M [ 32 := (0 : 1 : 2 : .WordStack)         ] , 33 , 1) ) => doneLemma( (1 : .WordStack)                          ) ... </k>
    rule <k> runLemma ( #range(M [ 32 := (0 : 1 : 2 : .WordStack)         ] , 33 , 2) ) => doneLemma( (1 : 2 : .WordStack)                      ) ... </k>
    rule <k> runLemma ( #range(M [ 32 := (0 : 1 : 2 : .WordStack)         ] , 33 , 3) ) => doneLemma( (1 : 2 :  .WordStack) ++ #range(M, 35, 1) ) ... </k>

endmodule