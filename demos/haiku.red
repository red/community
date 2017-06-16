Red [
   description: {
      Attempt to copy Haiku Editor 
      http://forthsalon.appspot.com/haiku-editor
   }
   todo: {
      * Optimize GUI
      * Add memory and words: @ !
      * Add return stack and words: push pop r@
      * Add mouse handling: mx my button buttons
      * Add complex numbers operations: z+ z*
      * Add word definition: :;
      * Add if/else/then condition
      * Add comments support
      * Write some haikus
   }
   needs: 'View
   Tabs: 4
]

debug: off

forth-words: copy []
silent-tests: off

test-everything: func [/silently /local w] [
   forall forth-words [
      w: get forth-words/1
      if silently [ silent-tests: on ] 
      w/test []
   ]
]

run-test: function [name stack-in stack-out] [
   unless silent-tests [ print [ "testing" name "with" mold stack-in ] ]
   me: get name
   res: me copy stack-in
   either res = stack-out [
      unless silent-tests [ print "passed" ]
      yes
   ] [
      if silent-tests [
         print [ "testing" name "with" mold stack-in ]
      ]
      print [lf "! failed !"]
      print [ "result:" res ]
      print [ "expected:" stack-out lf]
      no
   ]
]

run-tests: function [name tests /local stack-in stack-out] [
   results: copy []
   rule: [
      set stack-in block! '=> set stack-out block!
      (append results run-test name stack-in stack-out)
   ]
   parse tests [any rule]
   either all results [ yes ] [ no ]
]

forth-word: func ['name spec body tests /local args new-body out-type to-boolean?] [
   append forth-words name
   args: first parse spec [collect [keep to '--]]
   if not args [ args: copy [] ]
   unless block? args [
      args: reduce [args]
   ]
   out-type: parse spec [collect [skip thru '-- keep to end]]
   word-body: [
      name2:                    ; actualy value will be inserted here
      args2:                    ; same
      body2:                    ; same
      tests2:                   ; same
      out-type:                 ; same
      if debug [ print ["stack:" mold stack] ]
      if test [ return run-tests name2 tests2 ]
      blk: copy []
      if (length? args2) > (length? stack) [
         print [
            "stack underflow at" name2
            "(" args2 ") stack:" mold stack
         ]
         return head stack
      ]
      args-rev: reverse copy args2
      forall args-rev [
         append blk reduce [to-set-word args-rev/1 take/last stack]
      ]
      ; ctx: make object! blk
      bind body2 ctx
      res: do body2
      if out-type = [b] [
         res: to-forth-boolean res
      ]
      if out-type = [n] [
         res: to-float res
      ]
      head append stack res
   ]
   insert next find word-body quote tests2: reduce [copy tests]
   insert next find word-body quote name2: reduce ['quote name]
   insert next find word-body quote args2: reduce [copy args]
   insert next find word-body quote body2: reduce [copy body]
   insert next find word-body quote out-type: reduce [out-type]

   set name function [stack /test] word-body
]

to-forth-boolean: func [value] [
   if logic? value [ return either value [1] [0] ]
   if number? value [ return either zero? value [0] [1] ]
   print ["don't know how to convert" value "to forth-boolean"]
]

current-time: does [
   ; current time in seconds since midnight
   time: now/time
   time/second + (time/minute * 60) + (time/hour * 3600)
]

; Forth dictionary

; put value
forth-word forth-dt [ -- n] [ make error! "not implemented" ] [
   ; no tests
]
forth-word forth-mx [ -- n] [ make error! "not implemented" ] [
   ; no tests
]
forth-word forth-my [ -- n] [ make error! "not implemented" ] [
   ; no tests
]
forth-word forth-button [ -- n] [ make error! "not implemented" ] [
   ; no tests
]
forth-word forth-buttons [ -- n] [ make error! "not implemented" ] [
   ; no tests
]
forth-word forth-audio [ -- n] [ make error! "not implemented" ] [
   ; no tests
]


; memory
forth-word forth-at [ -- n] [ make error! "not implemented" ] [
   ; no tests
]
forth-word forth-! [ -- n] [ make error! "not implemented" ] [
   ; no tests
]
forth-word forth-push [ -- n] [ make error! "not implemented" ] [
   ; no tests
]
forth-word forth-pop [ -- n] [ make error! "not implemented" ] [
   ; no tests
]
forth-word forth-rat [ -- n] [ make error! "not implemented" ] [
   ; no tests
]


; math
forth-word forth-+ [x y -- n] [ x + y ] [
   [1 2] => [3]
]
forth-word forth-- [x y -- n] [ x - y ] [
   [3 1] => [2]
]
forth-word forth-* [x y -- n] [ x * y ] [
   [2 3] => [6]
]
forth-word forth-div [x y -- n] [ x / to-float y ] [
   [6 3] => [2.0]
]
forth-word forth-min [x y -- n] [ min x y ] [
   [6 3] => [3]
   [3 6] => [3]
]
forth-word forth-max [x y -- n] [ max x y ] [
   [6 3] => [6]
   [3 6] => [6]
]
forth-word forth-mod [x y -- n] [ mod x y ] [
   [5 3] => [2]
]
forth-word forth-pow [x y -- n] [ power x y ] [
   [2 2] => [4]
   [3 4] => [81]
]
forth-word forth-atan2 [x y -- n] [ atan2 x y ] [
   ; no tests
]
forth-word forth-negate [x -- n] [ negate x ] [
   [5] => [-5]
]
forth-word forth-sin [x -- n] [ sin x ] [
   ; no tests
]
forth-word forth-cos [x -- n] [ cos x ] [
   ; no tests
]
forth-word forth-tan [x -- n] [ tan x ] [
   ; no tests
]
forth-word forth-log [x -- n] [ log-e x ] [
   ; no tests
]
forth-word forth-exp [x -- n] [ exp x ] [
   ; no tests
]
forth-word forth-exp [x -- n] [ exp x ] [
   ; no tests
]
forth-word forth-sqrt [x -- n] [ sqrt x ] [
   [4] => [2.0]
]
forth-word forth-floor [x -- n] [ to-integer x ] [
   [4.5] => [4]
]
forth-word forth-ceil [x -- n] [ 1 + to-integer x ] [
   [4.5] => [5]
]
forth-word forth-abs [x -- n] [ absolute x ] [
   [-4.5] => [4.5]
   [4.5] => [4.5]
]
forth-word forth-z+ [x -- n] [ absolute x ] [
   [-4.5] => [4.5]
   [4.5] => [4.5]
]
forth-word forth-z* [x -- n] [ absolute x ] [
   [-4.5] => [4.5]
   [4.5] => [4.5]
]


; comparison
forth-word forth-= [x y -- b]  [ x = y ] [
   [2 2] => [1]
   [2 1] => [0]
]
forth-word forth-!= [x y -- b] [ x <> y ] [
   [2 2] => [0]
   [2 1] => [1]
]
forth-word forth-> [x y -- b]  [ x > y ] [
   [1 2] => [0]
   [2 1] => [1]
   [2 2] => [0]
]
forth-word forth->= [x y -- b] [ x >= y ] [
   [1 2] => [0]
   [2 1] => [1]
   [2 2] => [1]
]
forth-word forth-< [x y -- b]  [ x < y ] [
   [1 2] => [1]
   [2 1] => [0]
   [2 2] => [0]
]
forth-word forth-<= [x y -- b] [ x <= y ] [
   [1 2] => [1]
   [2 1] => [0]
   [2 2] => [1]
]

; stack manipulations
forth-word forth-dup [x -- x x] [reduce [x x]] [
   [1] => [1 1]
]
forth-word forth-over [a b -- a b a] [reduce [a b a]] [
   [1 2] => [1 2 1]
]
forth-word forth-dup2 [a b -- a b a b] [reduce [a b a b]] [
   [1 2] => [1 2 1 2]
]
forth-word forth-drop [x -- ] [[]] [
   [1] => []
]
forth-word forth-swap [a b -- b a] [reduce [b a]] [
   [1 2] => [2 1]
]
forth-word forth-rot  [a b c -- b c a] [reduce [b c a]] [
   [1 2 3] => [2 3 1]
]
forth-word forth--rot [a b c -- c a b] [reduce [c a b]] [
   [1 2 3] => [3 1 2]
]

; logic
forth-word forth-not [x -- b] [ either zero? x [1] [0] ] [
   [0] => [1]
   [1] => [0]
]
forth-word forth-and [x y -- b] [ x and y ] [
   [0 0] => [0]
   [0 1] => [0]
   [1 0] => [0]
   [1 1] => [1]
]
forth-word forth-or [x y -- b] [ x or y ] [
   [0 0] => [0]
   [0 1] => [1]
   [1 0] => [1]
   [1 1] => [1]
]

parse-forth: function [x y code /local n s] [
   stack: copy []

   words: [
      ; '( skip thru ') |
      set n number! (append stack n) |
      'x (append stack x) |
      'y (append stack y) |
      't (append stack current-time) |
      'dt (forth-dt stack) |
      'mx (forth-mx stack) |
      'my (forth-my stack) |
      'button (forth-button stack) |
      'buttons (forth-buttons stack) |
      'audio (forth-audio stack) |
      '@ (forth-at stack) |
      '! (forth-! stack) |
      'push (forth-push stack) |
      '>r (forth-push stack) |
      'pop (forth-pop stack) |
      'r> (forth-pop stack) |
      'r@ (forth-rat stack) |
      'dup (forth-dup stack) |
      'over (forth-over stack) |
      'dup2 (forth-dup2 stack) |
      'drop (forth-drop stack) |
      'swap (forth-swap stack) |
      'rot (forth-rot stack) |
      '-rot (forth--rot stack) |
      '= (forth-= stack) |
      '<> (forth-!= stack) |
      '< (forth-< stack) |
      '> (forth-> stack) |
      '<= (forth-<= stack) |
      '>= (forth->= stack) |
      'and (forth-and stack) |
      'or (forth-or stack) |
      'not (forth-not stack) |
      'min (forth-min stack) |
      'max (forth-max stack) |
      '+ (forth-+ stack) |
      '- (forth-- stack) |
      '* (forth-* stack) |
      ; '/ (forth-div stack) |
      'mod (forth-mod stack) |
      'pow (forth-pow stack) |
      '** (forth-pow stack) |
      'atan2 (forth-atan2 stack) |
      'negate (forth-negate stack) |
      'sin (forth-sin stack) |
      'cos (forth-cos stack) |
      'tan (forth-tan stack) |
      'log (forth-log stack) |
      'exp (forth-exp stack) |
      'sqrt (forth-sqrt stack) |
      'floor (forth-floor stack) |
      'ceil (forth-ceil stack) |
      'abs (forth-abs stack) |
      'pi (append stack pi) |
      'z+ (forth-z+ stack) |
      'z* (forth-z* stack) |
      'random (append stack (random 100) / 100.0) |

      ;; if-else-then
      ; 'if if-rule |
      ; ahead 'else break |
      ; ahead 'then break |

      set s skip (print ["skipped:" s])
   ]
   rules: compose/deep [any [(words)]]

   if-rule: [
      if (take back tail stack <> 0) rules ['else if-true-part] |
      if-else-part
   ]


 ; [ if a if b then 3 then 'test ]
   ; skip-nested-ifs: [skip to ['if | 'then] skip-nested-ifs-helper]
   ; skip-nested-ifs-helper: ['then | skip-nested-ifs skip-nested-ifs-helper ]

   ; if-true-part: [skip to ['if | 'else | 'then] ['if if-true-part skip thru 'then if-true-part |   | 'then]]
   ; if-else-part: [skip to ['if | 'else | 'then] ['if skip thru 'then if-else-part | 'else rules 'then | 'then]

   parse code rules
   stack
]

; hack for 2dup word, because words in Red can't start with a digit
dup2hack: func [text] [ replace/all text "2dup" "dup2" ]

; test-everything/silently

; probe parse-forth 1 1 2 2 [ 0.5 ]
; quit

; runs forth code and returns color
run-forth: function [x y code] [
   colors: [0 0 0]
   colors/1: 0
   colors/2: 0
   colors/3: 0

   upd: parse-forth x y code
   ; print [code upd]
   change colors copy/part upd 3
   colors/1: to-integer colors/1 * 255
   colors/2: to-integer colors/2 * 255
   colors/3: to-integer colors/3 * 255
   forall colors [
      if colors/1 > 255 [
         colors/1: 255
      ]
      if colors/1 < 0 [
         colors/1: 0
      ]
   ]
   head colors
]

; probe run-forth 1 1 2 2 [ 0.5 ]
; quit

; runs code for each pixel in image and updates its color
generate: function [text] [
   code: load/all text
   probe code
   image: img/image
   x-scale: 1.0 / image/size/x
   y-scale: 1.0 / image/size/y
   x: y: x-scaled: y-scaled: 0
   forall image [
      image/1: to-tuple run-forth x-scaled y-scaled code
      either (x + 1) >= image/size/x [
         x: x-scaled: 0
         y: y + 1
         y-scaled: y-scaled + y-scale
      ] [
         x: x + 1
         x-scaled: x-scaled + x-scale
      ]
   ]
]

demo: {
   0.5
}

system/view/auto-sync?: true

view [
   title "Demo"
   backdrop #2C3339
   across

   source: area #13181E 410x300 no-border demo font [
      name: "Consolas"
      size: 9
      color: hex-to-rgb #9EBACB
   ]

   img: image 200x200 #2C3339
   return

   button "Run" on-click [
      generate dup2hack source/text
   ]
]
