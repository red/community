Red [
	Title:	"Planet orbits a star"
	file:	%one-planet.red
	Author:	"Arnold van Hofwegen"
	needs:	view
  Tabs: 4
]

cycle: make block! 361
repeat i 360 [append cycle i]
append cycle 1

n: 360
tau: pi * 2

step-orbit: func [][
    n: select cycle n
    flo: tau * n / 360
    b1/draw: compose [pen yellow fill-pen yellow circle 200x200 50 pen blue fill-pen blue circle (200x200 + as-pair 150 * sin flo 150 * cos flo) 10]
    show b1
]

view [
	title "Planet orbits a star"
    size 400x460
    origin 0x0
    b1: base 0.0.0 400x400 draw [] rate 100 on-time [step-orbit]
    return
    btn: button "Stop this Universe" [unview] 
]
