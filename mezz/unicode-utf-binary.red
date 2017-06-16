Red [
    Title: "Unicode (red-string!) and Utf Binary Conversions"
    Author: "Thomas C. Royko"
    About:  "compile with -r, won't work under redlib"
    Tabs: 4
]

_to-utf-binary: routine [
    cell    [value!]
    utf16?  [logic!]
    return: [binary!]
    /local
        len
        str
        cstr
        bin
        scalar
] [
    switch cell/header [
        TYPE_STRING [
            str: as red-string! cell
            len: string/rs-abs-length? str
            either utf16? = true [
                cstr: unicode/to-utf16 str :len
                scalar: 2
            ] [
                cstr: unicode/to-utf8  str :len
                scalar: 1
            ]
            bin: as byte-ptr! cstr
        ]
        TYPE_CHAR [
            print "In the works..."
            halt
        ]
        default [
            fire [TO_ERROR(script type)]
        ]
    ]
    ;Get rid of the two args blocking the return
    ;I'm probably not cleaning up the stack right lol
    stack/pop 2
    binary/load bin (len * scalar)
]

_from-utf-binary: routine [
    utf-binary [binary!]
    utf16?     [logic!]
    return:    [string!]
    /local
        len
        cstr
        str
        scalar
        enc
] [
    len: binary/rs-length? utf-binary
    cstr: as c-string! binary/rs-head utf-binary
    either utf16? = true [
        enc: UTF-16LE
        scalar: 2
    ][
        enc: UTF-8
        scalar: 1
    ]
    
    stack/pop 2
    string/load cstr (len / scalar) enc
]

to-utf-binary: func [
    {Converts red-string!s to utf encoded binary}
    unicode-string [string!]
    /utf16
    return:        [binary!]
] [
    return _to-utf-binary unicode-string utf16
]

from-utf-binary: func [
    {Converts utf encoded binary to string!}
    utf-binary     [binary!]
    /utf16
    return:        [string!]
] [
    return _from-utf-binary utf-binary utf16
]
