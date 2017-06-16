Red [
   description: {simple game}
   author: {Maxim Velesyuk}
   version: 2.2
   changelog: {
      2.2
      * added sleep to the loop to reduce CPU load

      2.1
      * added win screen display time
      * added win screen background
      * added win screen win time
      
      2.0
      * rate updates rewritten into a time-controlled loop
      * added game object as a global storage
      * added collision detection
      * added win/restart conditions
      * added restart with initial states of all objects
      * now any key restarts game after it finished
      * player moves are now bounded to the world's size
   }
   Tabs: 4
]

random/seed now/time

game: object [
   debug: "test"
   show-debug?: on
   size: 640x480
   debug-pos: to-pair reduce [size/x - 200 0]
]

debug: func [b] [ if game/show-debug? [ do b ] ]

base: make face! [
   type: 'base
   size: game/size
   color: gray
]

world: object [
   size: base/size
   canvas: copy []
   game-objects: copy []
   initial-state: copy []
   collidable: copy []
   pause?: false
   end?: false
   reupdate?: false
   win-screen-show-time: 2
   win-time: none
   start-time: none

   init: does [
      start-time: now/time/precise
   ]

   win-screen: does [
      compose [
         pen black
         box 0x0 (to-pair reduce [ world/size/x 100 ])
         pen orange
         font (make font! [size: 16])
         text 250x30 "You Win!! :)"
         text 200x70 (append copy "your time: " to-string win-time - start-time)
      ]
   ]

   win: does [
      win-time: now/time/precise
      end?: true
   ]

   update: function [/extern collidable reupdate? game-objects win-time] [
      if pause? [ return none ]
      if end? [
         append canvas win-screen 
         show base
         return none 
      ]
      clear canvas
      game-objects: head game-objects
      collidable: head collidable
      
      forall game-objects [
         game-objects/1/draw canvas
         if select o: game-objects/1 'collide [
            forall collidable [
               if o <> collidable/1 [
                  if collided o collidable/1 [ 
                     o/collide collidable/1
                     if reupdate? [
                        collidable: head collidable
                        reupdate?: false 
                        return update 
                     ]
                  ]
               ]
            ]
         ]
      ]
      debug [
         append canvas compose [ fill-pen black text (game/debug-pos) (game/debug) ]
      ]
      show base
   ]
   collided: function [a b] [
      all [
         a/pos/x < (b/pos/x + b/size/x)
         (a/pos/x + a/size/x) > b/pos/x
         a/pos/y < (b/pos/y + b/size/y)
         (a/pos/y + a/size/y) > b/pos/y
      ]
   ]
   add-object: func [o] [ 
      append game-objects o
      append initial-state copy/deep o
      if in o 'collide [
         append collidable o
      ]
   ]
   reset: has [k v game-object seconds] [
      seconds: pick now/time/precise 3
      if all [ end? seconds < (win-time/3 + win-screen-show-time) ] [
         return none
      ]
      end?: false
      game-object: head game-objects
      forall initial-state [
         k: keys-of initial-state/1
         forall k [
            if not function? v: :initial-state/1/(k/1) [
               set in game-object/1 k/1 v
            ]
         ]
         game-object: next game-object
      ]
      reupdate?: true
      init
   ]
]

base/draw: world/canvas

safe-zone: object [
   class: 'safe-zone
   size: 50x50
   draw: func [c] [
      append c compose [ fill-pen green box 0x0 (size) ]
   ]
]

world/add-object safe-zone

player: object [
   class: 'player
   pos: 10x10
   size: 10x10
   step: func [direction /local new-pos] [ 
      new-pos: pos + select [ left -10x0 right 10x0 up 0x-10 down 0x10 ] direction
      if all [ 
         new-pos/x >= 0 
         new-pos/y >= 0 
         new-pos/x < world/size/x
         new-pos/y < world/size/y
       ] [
         pos: new-pos
      ]
   ]
   draw: func [c] [
      append c compose [ fill-pen blue box (pos) (pos + size) ]
   ]
   collide: func [something] [
      do select [ 
         enemy [world/reset]
         exit-zone [world/win]
      ] something/class
   ]
]

world/add-object player

enemy: object [
   class: 'enemy
   initial: safe-zone/size + random (world/size - safe-zone/size)
   pos: initial
   step: 10x0
   distance: 40
   size: 10x10
   collide: does []
   draw: func [c] [
      append c compose [ fill-pen red circle (pos) (size/x / 2)]
      pos: pos + step
      if any [
         pos/1 > (initial/1 + distance) 
         pos/1 < (initial/1 - distance)
         pos/2 > (initial/2 + distance) 
         pos/2 < (initial/2 - distance)
      ] [ step: negate step ]
   ]
]

loop 20 [
   world/add-object make enemy [
      initial: safe-zone/size + random (world/size - safe-zone/size)
      pos: initial
      step: 0x10
   ]
   world/add-object make enemy [
      initial: safe-zone/size + random (world/size - safe-zone/size)
      pos: initial
      step: 10x0
   ]
]

exit-zone: object [
   class: 'exit-zone
   size: 150x50
   pos: (world/size / 2) + random (world/size / 2 - size)
   draw: func [c] [
      append c compose [ fill-pen cyan box (pos) (pos + size) text (pos + 60x20) "Exit" ]
   ]
   collide: does []
]

world/add-object exit-zone

key-map: [
   #"q" [ quit ]
   #" " [ world/pause?: not world/pause? ]
   left [ player/step 'left ]
  right [ player/step 'right ]
   up   [ player/step 'up ]
   down [ player/step 'down ]
   #"w" [ world/win ]
   #"d" [ game/show-debug?: not game/show-debug?]
   #"r" [ world/reset ]
]

win: make face! [
   type: 'window
   text: "The Game"
   size: game/size
   pane: reduce [ base ]
   actors: object [
      on-key: func [face event /local s] [
         if world/end? [ world/reset ]
         do s: select key-map event/key
         if not s [ print ["key" event/key "has no binding" ] ]
      ]
   ]
]

system/view/auto-sync?: off

view/no-wait win

frame-rate: 15
max-time: 1.0 / frame-rate

count: 0
world/init
forever [
   t1: now/time/precise
   world/update
   game/debug: append copy "updates per frame " to-string count
   passed: (now/time/precise - t1)
   remaining: pick max-time - passed 3
   sleep-time: remaining / 20
   count: 0
   while [max-time > (pick now/time/precise - t1 3) ] [
      count: count + 1
      do-events/no-wait
      wait sleep-time
   ]
]
