Red [
   Title: "Untitled"
   Author: "Maxim Velesyuk"
   Version: 0.0.1
   Tabs: 4
]

to-getword: func [w] [ load append copy ":" w ]
to-setword: func [w] [ to set-word! append copy "" w]

parse-spec: func [spec] [
   pos-args1: copy []
   opt-args1: copy []
   key-args1: copy []

   argument: [word!]
   arg-with-default: [word! skip opt word!]
   opt-argument: [word! | into arg-with-default ]
   key-argument: [get-word! | into arg-with-default ]

   arg-spec-rule: [
      any [
         collect into pos-args1
         [ahead ['&optional | '&key | '&rest] break | keep argument]
      ]
      opt [
         '&optional collect into opt-args1
         [some [ahead ['&key | '&rest] break | keep opt-argument]]
      ]
      opt [
         '&key collect into key-args1
         [some [ahead '&rest break | [keep key-argument]]]
      ]
      opt ['&rest argument]
   ]
   parse spec arg-spec-rule
   context [
      pos-args: pos-args1
      opt-args: opt-args1
      key-args: key-args1
   ]
]

parse-args: func [args] [
   pos-args1: copy []
   opt-args1: copy []
   key-args1: copy []

   argument: [skip]
   key-argument: [keep get-word! keep skip]

   arg-rule: [
      any [
         collect into pos-args1
         [ahead [get-word! | '&rest] break | keep argument]
      ]
      opt [
         collect into key-args1
         [some [ahead '&rest break | key-argument]]
      ]
      opt ['&rest argument]
   ]
   parse args arg-rule
   context [
      pos-args: pos-args1
      opt-args: opt-args1
      key-args: key-args1
   ]
]

; parse-args: func [args spec] [
;    specials: [&optional &key &rest]
;    while [length? args > 0 and not find specials head args] [
      
;       args: next args
;    ]
; ]

lfun: func [spec body] [
   arg-spec: parse-spec spec
   addon: [
      args: parse-args arg
      unless (length? args/pos-args) = (length? arg-spec/pos-args) [
         throw "positional arguments mismatch"
      ]
      args-block: copy []
      a: args/pos-args
      forall a [
         i: index? a
         append args-block compose [(to-setword arg-spec/pos-args/(i)) (first a)]
      ]

      a: arg-spec/opt-args
      forall a [
         i: index? a
         either i > length? args/opt-args [
            append args-block compose [(to-setword a/(i)) none]
         ] [
            append args-block compose [(to-setword a/(i)) (at args/opt-args i)] 
         ]
      ]

      a: arg-spec/key-args
      forall a [
         either pos: find args/key-args first a [
            i: index? pos
            append args-block compose [(to-setword first a) (args/key-args/(i + 1))]
         ] [
            append args-block compose [(to-setword first a) none]
         ]
      ]
      ; probe args-block
      do args-block
   ]
   insert body addon
   func [arg] body
]

; probe parse-spec [a b c &optional d &key :k :z :x]
; probe parse-args [1 2 :k 3]


l: lfun [a b c &optional d &key :k :z :x] [reduce [a b c d k z x]]
probe l [1 2 3 :x 6 :k 4 :z 5] ;; => [1 2 3 none 4 5 6]
 
