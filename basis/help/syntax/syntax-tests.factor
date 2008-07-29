IN: help.syntax.tests
USING: tools.test parser vocabs help.syntax namespaces eval ;

[
    [ "foobar" ] [
        "IN: help.syntax.tests USE: help.syntax ABOUT: \"foobar\"" eval
        "help.syntax.tests" vocab vocab-help
    ] unit-test
    
    [ { "foobar" } ] [
        "IN: help.syntax.tests USE: help.syntax ABOUT: { \"foobar\" }" eval
        "help.syntax.tests" vocab vocab-help
    ] unit-test
    
    [ ] [ f "help.syntax.tests" vocab set-vocab-help ] unit-test
] with-file-vocabs
