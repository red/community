Red [
   author: { Maxim Velesyuk }
   description: {
      colors palette showcase
   }
]

sys-words: words-of system/words
colors: copy []
forall sys-words [
   word: sys-words/1
   error: error? value: try [ get word ]
   if all [
      not error
      tuple? :value
      value/1 < 255
      value/2 < 255
      value/3 < 255
   ] [
      append colors word
   ]
]

tile-size: 4x3 * 30
rows: 1 + to-integer round/ceiling sqrt length? colors
cols: to-integer (length? colors) / rows

color-complement: func [color /local c] [
   to-tuple reduce [255 - color/1 255 - color/2 255 - color/3]
]

size: to-pair reduce [tile-size/x * rows tile-size/y * cols]

draw-block: collect/into [
   repeat r rows [
      repeat c cols [
         index: r * cols + c
         if index <= length? colors [
            tile-coords: tile-size * to-pair reduce [r - 1 c - 1]
            color: pick colors index
            keep compose [
               fill-pen (color)
               box (tile-coords)
                   (tile-coords + tile-size)
               pen (reverse get color)
               text (tile-coords + 10) (to-string color)
               pen (color-complement get color)
               text (tile-coords + 10x30) (to-string color)
            ]
         ]
      ]
   ]
] copy [] 

view compose [
   title "Colors showcase"
   base (size) draw draw-block
]
