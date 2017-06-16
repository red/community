Red [
   Tabs: 4
]

; It might seem like just a party trick, out of context. The goal is not "look how 
; we can twist the language around!". Think, instead, of how you can use the language 
; to most clearly express intent in different domains, or for different users. Quite 
; often, when a user wants a different way to express things, we can accommodate them. 
; It's also true that we can suggest a form that exists natively in Red, and they will 
; be just as happy.
;
; Don't twist the language because you can. But don't be afraid to when it helps.

```
; Interpolate tuple
tup: function ['tuple [word!]][
    words: split form tuple #"."
    forall words [change/only words to word! first words]
    make tuple! reduce words
]
e.g. [
    r: 0
    g: 128
    b: 255

    print tup r.g.b

    set [a b c d e f g h i j] [1 2 3 4 5 6 7 8 9 10]

    print tup a.b.c.d.e.f.g.h.i.j
]

untup: func [tuple [tuple!]][
	collect [repeat i length? tuple [keep tuple/:i]]
]
e.g. [
	set [r g b] untup 0.128.255
	print [r g b]

	set [a b c d e f g h i j] untup 1.2.3.4.5.6.7.8.9.10
	print [a b c d e f g h i j]

	set [x . y . . . z] untup 1.0.2.0.0.0.3
	print [x y z]
]
```
