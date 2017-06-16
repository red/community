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

moveball: does [
while [running] [
   if ball/offset/x >= 400  [move: as-pair negate random 3 (move/y)]
   if ball/offset/x <= 0    [move: as-pair  random 3 (move/y)]
   if ball/offset/y >= 300  [move: as-pair (move/x) negate random 3]
   if ball/offset/y <= 0    [move: as-pair (move/x) random 3]
   ball/offset: ball/offset + move 
   loop 2 [do-events/no-wait wait 0.01] 
   ;;;;;checkinbound?
   ;;;;;system/view/VID/process-reactors
   show gamearea
   ]
]
comment {
checkinbound?: does[
    foreach e gamearea/pane [ attempt [check-all-reactions e]]
]
ch
eckallinvisible: does [
foreach e gamearea/pane [ print e/visible?]
]
}

makebrick:  [  base  40x20 brick
               react[ 
               ;on-click[
               if all[face/visible? within? ball/offset face/offset face/size][
               print ["touche" face] 
               face/visible?: false 
            ]]]

bricks: copy [] 
repeat x 5  [ append bricks reduce['at (as-pair x * 60 20)]  append bricks copy makebrick ] 
repeat x 5  [ append bricks reduce['at (as-pair x * 60 + 30 60)]  append bricks copy makebrick ] 
;probe bricks 

ball: [[pen black fill-pen red] [circle 20x20 10]]
wall: compose/deep [
    title "face  ball"
    button "start" [changemode true moveball ] return 
    button "stop"  [changemode false ]
    gamearea: panel 420x320  white [
        ( append [at 80x100  ball: base 40x40 transwhite  draw ball] (bricks)) 
    ] 
    react [print "reactor"]
]
;probe wall

mainwin:  layout wall
mainwin/actors: context [
                on-close:  func  [face [object!] evt [event!]] [running: false 
                                                                system/view/auto-sync?: yes]
         ]
view/no-wait  mainwin 
