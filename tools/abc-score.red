Red [
   author: {Maxim Velesyuk}
   usage: {
      abc-score? <block of code>
      abc-score? %file.red
      abc-score? :some-function
   }
   description: {
      Toy implementation of ABC test:

      The ABC software metric defines an ABC score as a triplet of values that represent the size of a set of source code statements.
      An ABC score is calculated by counting the number of assignments (A), number of branches (B), and number of conditionals (C) in a program.
      ABC score can be applied to individual methods, functions, classes, modules or files within a program.
      https://en.wikipedia.org/wiki/ABC_score
   }
]

abc: context [
   cond-words: make hash! []
   branch-words: make hash! []
   is-cond?: func [word] [ find cond-words word ]
   is-branch?: func [word] [ find branch-words word ]

   init: func [/local w x t] [
      w: words-of system/words
      forall w [
         if not error? try [t: type?/word get w/1] [
            if value? 't [
               try [spec: spec-of get w/1]
               if all [
                  #"?" = last to-string w/1
                  value? 'spec
               ] [
               if find spec [return [logic!]] [ append cond-words w/1 continue ]
               if all [
                  string? spec/1
                  any [
                     find lowercase spec/1 "returns true"
                     find lowercase spec/1 "returns false"
                  ]
                  ] [ append cond-words w/1 continue ]
               ]
               if x: find [function! action! native! routine! op!] t [
                  append branch-words w/1
               ]
            ]
         ]
      ]
   ]

   test: func [arg /local code rules assigns branches conds tmp] [
      {Reflection on action!, native! is not yet implemented}
      assigns: branches: conds: 0
      code: switch type?/word :arg [
         block! [arg]
         file! [load arg]
         function! routine! op! [body-of :arg]
      ]
      rules: [
         any [
            [['set | set-word!] (assigns: assigns + 1)]
            | [['> | '< | '= | '>= | '<= | '<> ] ( conds: conds + 1 )]
            | set tmp word! (
               if is-cond? tmp [ conds: conds + 1 ]
               if is-branch? tmp [ branches: branches + 1 ]
            )
            | ahead block! into rules
            | skip
         ]
      ]
      parse code rules
      compose [assigns (assigns) branches (branches) conditions (conds)]
   ]
]

abc/init
abc-score?: :abc/test


{
>> abc-score? %red/environment/functions.red
== [assigns 231 branches 656 conditions 89]
>> abc-score? %red/environment/console/gui-console.red
== [assigns 88 branches 76 conditions 7]
>> abc-score? %red/environment/console/engine.red
== [assigns 72 branches 164 conditions 39]
>> abc-score? :abc-score?
== [assigns 7 branches 7 conditions 6]
}
