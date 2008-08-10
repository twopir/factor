IN: compiler.tree.loop.detection.tests
USING: compiler.tree.loop.detection tools.test
kernel combinators.short-circuit math sequences accessors
compiler.tree
compiler.tree.builder
compiler.tree.combinators ;

[ { f f f f } ] [ f { f t f f } (tail-calls) ] unit-test
[ { f f f t } ] [ t { f t f f } (tail-calls) ] unit-test
[ { f t t t } ] [ t { f f t t } (tail-calls) ] unit-test
[ { f f f t } ] [ t { f f t f } (tail-calls) ] unit-test

\ detect-loops must-infer

: label-is-loop? ( nodes word -- ? )
    [
        {
            [ drop #recursive? ]
            [ drop label>> loop?>> ]
            [ swap label>> word>> eq? ]
        } 2&&
    ] curry contains-node? ;

\ label-is-loop? must-infer

: label-is-not-loop? ( nodes word -- ? )
    [
        {
            [ drop #recursive? ]
            [ drop label>> loop?>> not ]
            [ swap label>> word>> eq? ]
        } 2&&
    ] curry contains-node? ;

\ label-is-not-loop? must-infer

: loop-test-1 ( a -- )
    dup [ 1+ loop-test-1 ] [ drop ] if ; inline recursive
                          
[ t ] [
    [ loop-test-1 ] build-tree detect-loops
    \ loop-test-1 label-is-loop?
] unit-test

[ t ] [
    [ loop-test-1 1 2 3 ] build-tree detect-loops
    \ loop-test-1 label-is-loop?
] unit-test

[ t ] [
    [ [ loop-test-1 ] each ] build-tree detect-loops
    \ loop-test-1 label-is-loop?
] unit-test

[ t ] [
    [ [ loop-test-1 ] each ] build-tree detect-loops
    \ (each-integer) label-is-loop?
] unit-test

: loop-test-2 ( a -- )
    dup [ 1+ loop-test-2 1- ] [ drop ] if ; inline recursive

[ t ] [
    [ loop-test-2 ] build-tree detect-loops
    \ loop-test-2 label-is-not-loop?
] unit-test

: loop-test-3 ( a -- )
    dup [ [ loop-test-3 ] each ] [ drop ] if ; inline recursive

[ t ] [
    [ loop-test-3 ] build-tree detect-loops
    \ loop-test-3 label-is-not-loop?
] unit-test

: loop-test-4 ( a -- )
    dup [
        loop-test-4
    ] [
        drop
    ] if ; inline recursive

[ f ] [
    [ [ [ ] map ] map ] build-tree detect-loops
    [
        dup #recursive? [ label>> loop?>> not ] [ drop f ] if
    ] contains-node?
] unit-test

: blah f ;

DEFER: a

: b ( -- )
    blah [ b ] [ a ] if ; inline recursive

: a ( -- )
    blah [ b ] [ a ] if ; inline recursive

[ t ] [
    [ a ] build-tree detect-loops
    \ a label-is-loop?
] unit-test

[ t ] [
    [ a ] build-tree detect-loops
    \ b label-is-loop?
] unit-test

[ t ] [
    [ b ] build-tree detect-loops
    \ a label-is-loop?
] unit-test

[ t ] [
    [ a ] build-tree detect-loops
    \ b label-is-loop?
] unit-test

DEFER: a'

: b' ( -- )
    blah [ b' b' ] [ a' ] if ; inline recursive

: a' ( -- )
    blah [ b' ] [ a' ] if ; inline recursive

[ f ] [
    [ a' ] build-tree detect-loops
    \ a' label-is-loop?
] unit-test

[ f ] [
    [ b' ] build-tree detect-loops
    \ b' label-is-loop?
] unit-test

! I used to think this should be f, but doing this on pen and
! paper almost convinced me that a loop conversion here is
! sound.

[ t ] [
    [ b' ] build-tree detect-loops
    \ a' label-is-loop?
] unit-test

[ f ] [
    [ a' ] build-tree detect-loops
    \ b' label-is-loop?
] unit-test
