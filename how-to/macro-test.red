Red [
   Tabs: 4   
]



;Hello Doc!

;I have made two functions  with the following definitions:

purify: func [str [string!]] [ 
    remove-each value str [
        any [
            value = #"]" 
            value = #"[" 
            value = #"^/"
        ]
    ]
    trim str
]

transmogrify: function [code [block!]] [
    code-2-return: copy []
    rule: [  
        copy func-with-args thru [newline | "]"] (if not empty? temp: load purify func-with-args [append/only code-2-return temp]) rule 
        | end
    ]
    parse mold code rule
    code-2-return
]

;When transmogrify is called it seems to work fine when called outside of macro...

transmogrify [
    hi there
    this will
    divide up the code
    when a newline is made
    in the block!
]

; This returns:
; == [[hi there] [this will] [divide up the code] [when a newline is made] [in the block!]]

; These functions are defined within a #do directive, so that they can be invoked by a macro like so:

expand-directives [
    #do [
        purify: func [str [string!]] [ 
            remove-each value str [
                any [
                    value = #"]" 
                    value = #"[" 
                    value = #"^/"
                ]
            ]
            trim str
        ]

        transmogrify: function [code [block!]] [
            code-2-return: copy []
            rule: [  
                copy func-with-args thru [newline | "]"] (if not empty? temp: load purify func-with-args [append/only code-2-return temp]) rule 
                | end
            ]
            parse mold code rule
            code-2-return
        ]       
    ]

    #macro ['~> word! block!] func [s e] [
        data: take remove s
        ;probe transmogrify first s
        probe first s
        e
    ]
    ~> hi [
        there _ 1 
        whoa 1 _ 3
    ]
]

;Whenever I actually call transmogrify, it crashes, even though it works on structures like this outside of the macro.
