Red [
  Author: ["Didier Cadieu" "Nenad Rakocevic"]
  File: %worm.red
  Needs: 'View
  Tabs: 4
]

win: layout [
    size 400x500
    across
    style ball: base 30x30 transparent draw [fill-pen blue circle 15x15 14]
    ball ball ball ball ball ball ball ball return
    ball ball ball ball ball ball ball ball return
    ball ball ball ball ball ball ball ball return
    b: ball loose
    do [b/draw/2: red]
]

follow: function [left right][
    if pair? o: left/extra [left/offset: left/offset + o / 2]
    left/extra: right/offset
]

faces: win/pane
while [not tail? next faces][
    react/link/later :follow [faces/1 faces/2]        ;-- construct a chain of reactions linking all balls, two by two.
    faces: next faces
]
view win
