Red [
   author: {Maxim Velesyuk}
   description: {draw dialect playground}
   Tabs: 4
]

demo: trim {
   fill-pen gray
   box 0x0 400x400
   do [c: to-tuple reduce [
         random 255 random 255 random 255]
      ]
   fill-pen (c)
   do [p1: 150x150 p2: 250x200]
   box (p1) (p2)
   box (p1 + -50x50) (p2 + 50x50)
   box (p1 + -100x100) (p2 + 100x100)
   fill-pen yellow
   box 180x100 220x150 8
   circle 200x110 20
}

to-draw: func [ block /local res ] [
   res: []
   clear res
   forall block [
      case [
         'do = block/1 [ do block/2 block: next block ]
         paren! = type? block/1 [ append res do block/1 ]
         true [ append res block/1 ]
      ]
   ]
   head res
]

img-swap: make image! 400x400
initial: make image! 400x400
draw initial to-draw load demo

tmp: none

view [
   title "Draw dialect playground"
   across
   source: area 400x400 demo font [
      name: "Consolas"
      size: 9
   ] on-change [
      either error? e: try [ draw img-swap to-draw load/all source/text ] [
         probe e
      ] [
         tmp: canvas/image
         canvas/image: img-swap
         show canvas
         img-swap: tmp
         img-swap/rgb: head change/dup img-swap/rgb white length? img-swap
      ]
   ]
   canvas: image initial
]
