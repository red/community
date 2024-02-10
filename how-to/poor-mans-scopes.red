Red [
   author: "Maxim Velesyuk"
   description: "Dynamic variables implementation for Red"
   Tabs: 4
]

; utils
forskip: func ['series skipn body /local s] [
   s: get series
   while [ not tail? s ] [
      do body
      s: set series skip s skipn
   ]
]

dynamic-words: copy #[]

; gets dynamic word value
dynamic: func ['word /safe /local binds] [
   either binds: dynamic-words/(word) [ last binds ] [
      either safe [ none ] [
         cause-error 'script 'no-value [to-path append "dynamic/" word]
      ]
   ]
]

; executes body with dynamically binded words
with-dynamic: func [words-values body /local tmp] [
   forskip words-values 2 [
      either tmp: dynamic-words/(words-values/1) [
         append tmp words-values/2
      ] [
         dynamic-words/(words-values/1): reduce [words-values/2]
      ]
   ]
   do body
   words-values: head words-values
   forskip words-values 2 [
      tmp: dynamic-words/(words-values/1)
      take/last tmp
      if empty? tmp [ dynamic-words/(words-values/1): none ]
   ]
]


; example

f: does [ print [dynamic a dynamic b dynamic c] ]

with-dynamic [a 1 b 2] [
   print [dynamic a dynamic b]
   with-dynamic [a 5 c 6] [
      f
      with-dynamic [b 3 c 10] [ f ]
      f
   ]
   print [dynamic a dynamic b]
]

; output:
; 1 2
; 5 2 6
; 5 3 10
; 5 2 6
; 1 2
