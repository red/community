Red [
        Title: "ballbounce with Faces"
        Needs: 'view
        Tabs: 4
]

;; random/seed now ;;;;now do not exist yet
transwhite: 255.255.255.255  ; white transparent for drag area 

move: 2x2
running: false
changemode: func [mode][
        either mode [
             running: true
             system/view/auto-sync?: no
             ][
             running: false
             system/view/auto-sync?: yes
             ]
]

ball: [[pen black fill-pen red] [circle 20x20 10]]

mainwin: layout [
    title "face bouncing ball"
    button "start" [changemode true moveball ] return 
    button "stop"  [changemode false ]
    playground: panel 420x320 white [
       at 80x20   b: base 40x40 transwhite  draw ball
    ]
]

moveball: does [
while [running] [
   if b/offset/x >= 400  [move: as-pair negate random 3 (move/y)]
   if b/offset/x <= 0    [move: as-pair  random 3 (move/y)]
   if b/offset/y >= 300  [move: as-pair (move/x) negate random 3]
   if b/offset/y <= 0    [move: as-pair (move/x) random 3]
   b/offset: b/offset + move 
   loop 2 [do-events/no-wait wait 0.01] 
   show playground
   ]
]

 mainwin/actors: context [
                on-close:  func  [face [object!] evt [event!]] [running: false 
                                                                system/view/auto-sync?: yes]
         ]
view mainwin 
