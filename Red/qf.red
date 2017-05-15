Red [
   author: {Maxim Velesyuk}
   file: %qf.red
   date: "15-May-2017"
   title: {Quick functions definitions}
   purpose: {
      Quick in-place function definitions without explicit arguments specification.
      `_` is next arugment, `_N` is N-th argument
   }
   license: 'MIT
   comm-code: [
      level: 'advanced
      platform: 'all
      type: [code dialect]
      domain: [dialects productivity]
   ]
   example: {
      f: qf [ _ + _3 - _ ]
      f 1 2 3 ; => 1 + 3 - 2 => 2
   }
]

qf: function [body] [
   inc: func ['word] [set word 1 + get word]
   args: copy []
   counter: 1
   max-n: 0
   rule: [
      any [
         pos: '_ (
            pos/1: to-word rejoin ["_" counter]
            append args pos/1
            inc counter
         ) |
         pos: word!
         if (#"_" = first s: to-string pos/1) (
            arg-n: to-integer next s
            max-n: max max-n arg-n
         ) |
         into rule |
         skip
      ]
   ]
   parse body rule
   if counter <= max-n [
      repeat c max-n - (counter - 1) [
         append args to-word rejoin ["_" counter]
         inc counter
      ]
   ]
   func args body
]

