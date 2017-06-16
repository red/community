Red[
   Tabs: 4
]
Arial: make font! [name: "Consolas" size: 20]
d0: [
    pen 240.240.240 
    fill-pen 240.240.240 
    box 0x0 80x40 
    fill-pen
]
d1: compose [
    (d0) red 
    triangle 0x40 40x0 80x40
]
d2: [fill-pen white pen black box 0x1 79x29 font Arial pen black text 0x0 "0" ]
d3: compose [
    (d0) blue 
    triangle 0x0 40x40 80x0
]
old-color: none

start-anim: func [face dir] [
    switch dir [
        up [old-color: d1/9 d1/9: gray]
        down [old-color: d3/9 d3/9: gray]
    ]
    face/rate: 6
]
do-anim: function [dir] [
    switch dir [
        up [op: :+ comp: :< val: 5]
        down [op: :- comp: :> val: 0]
    ]
    if (i: to integer! d2/14) comp val [
        d2/14: form i op 1
    ]
]
stop-anim: func [face dir] [
    switch dir [
        up [d1/9: old-color]
        down [d3/9: old-color]
    ]
    face/rate: none
]

w: view/no-wait [
    base 800x600 transparent
    at 5x5 
    text font-size 20 "Spinner (0 to 5)" return
    at 340x235
    panel [
        space 0x0
        base 80x40 draw d1 
            on-down [start-anim face 'up]
            on-up [stop-anim face 'up]
            on-time [do-anim 'up]
        return
        b: base 80x30 draw d2
            on-key [
                all [
                    event/key >= #"0" 
                    event/key <= #"5"
                    d2/14: form event/key
                ]
            ]
        return
        base 80x40 draw d3 
            on-down [start-anim face 'down]
            on-up [stop-anim face 'down]
            on-time [do-anim 'down]
        return
    ]
]

w/selected: b
do-events
