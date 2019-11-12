Red [
    Title: "Red debug step script"
    File: %rdbstep.red
    Date:  28-Oct-2019
    Version: 2.1
    Author: "JLM cyclo07"
    Purpose: "Debug step by step a Red script (tool for do/next)."
    Usage: "From REPL : do/args %rdbstep.red <Red Script>"
    Arguments: "<Red Script> [file! url! string! block!]"
    Help: { Some Hints for usage:
            - Before using %rdbstep.red : Verify that your script is well formed according to Red syntax
              with the Red command load (load <Red Script>)
            - At using %rdbstep.red: If you have the error message "Error Id:", try to use the rdb command
              "next", not to step into a level (against rdb command "step"), and then verify
              if the error message still appears.
            - To print the spec-of of a function <funct>, use the rdb command: ! probe spec-of <funct>
    }
	History: [
		1.0 "Only next step overall"
		2.0 "Add commands step into and where"
		2.1 {Enable replay using a file for input/output
             Values for rdbstep/dbgout/replay are 'no (default), 'new or 'yes
                    'no : not to save input/output
                    'new: to save input/output
                    'yes: to replay input from input file and to save output }
	]
]
rdbstep: context [
   dbgout: object [
      linp: i: 0
      outfile: %p_out.txt
      infile: %p_in.txt
      replay: 'no ; enable values are 'no 'yes 'new
      out_prin: function [ arg /extern replay outfile] [
         prin arg
         if any [ replay = 'yes replay = 'new ] [
            write/append outfile arg
         ]
      ]
      out_print: function [ arg /extern replay outfile] [
         print arg
         if any [ replay = 'yes replay = 'new ] [
            write/append outfile append arg newline
         ]
      ]
      in_ask: function [ arg /extern replay i linp infile] [
         switch replay [
            no      [ cmd: ask arg ]
            yes     [
                        if i = 0 [
                           linp: read/lines infile
                        ]
                        i: i + 1
                        cmd: pick linp i
            ]
            new [
                        cmd: ask arg
                        if i = 0 [
                           delete infile
                        ]
                        i: 1
                        write/append infile append copy cmd newline
            ]
         ]
         cmd
      ]
   ] ;-- end object dbgout
   trc: false
   blevl: compose/deep [ 0 [(to-logic false)] ]
   lret: copy ""
   flist: function [ redsrc [block!] upsrc [block!] /range iprev [integer!] /where ][
      if where [
         foreach ins upsrc [
            dbgout/out_prin ">"
            dbgout/out_print form ins
         ]
      ]
      if range [
         unless iprev = (index? redsrc) [
            bl: split mold/only copy/deep/part redsrc (iprev - (index? redsrc)) newline
            repeat i length? bl [
               dbgout/out_prin "  "
               dbgout/out_print pick bl i
            ]
         ]
      ]
      bl: split mold/only redsrc newline
      unless (length? bl) = 0 [
         if (length? bl/1) = 0 [
            remove bl
         ]
      ]
      dbgout/out_prin "->"
      dbgout/out_print pick bl 1
      if range [
         len: min 10 length? bl
         repeat i ( len - 1 ) [
            dbgout/out_prin "  "
            dbgout/out_print pick bl ( i + 1 )
         ]
         if len = length? bl [
            either ( length? upsrc ) = 0 [
               dbgout/out_print "[EOB]"
            ][
               dbgout/out_print form reduce [ "[EOB] level" length? upsrc ]
            ]
         ]
      ]
      return false
   ]
   fred: function [ arg ][
      attempt [ do form arg ]
      return false
   ]
   fhelp: function [ arg ][
       shelp: {
h(elp) | ?
^(tab)This help.^(line)
l(ist)
^(tab)list the execution lines (-> indicate the current line to execute).^(line)
w(here)
^(tab)print a stack trace, with the most recent frame at the bottom.^(line)
n(ext) | <enter>
^(tab)execute the whole current word/line and stop at the next step.^(line)
s(tep)
^(tab)execute into the current word/line and stop at the first possible occasion.^(line)
r(ed) | ! <Red code>
^(tab)execute <Red code>.^(line)
c((ont)inue)
^(tab)continue execution until end.^(line)
restart | run
^(tab)restart the debugger from the begin.^(line)
q(uit)
^(tab)quit the debugger.
       }
       print shelp
       return false
   ]
   ffin: function [ arg ][
       return true
   ]
   flevl: function [ isign [integer!] /extern blevl] [
      if any [ ( length? blevl ) = 2 blevl/1 > absolute ( last blevl ) ] [
         append blevl isign * blevl/1
      ]
      if ( last blevl ) <> ( isign * blevl/1 ) [
         poke blevl length? blevl isign * blevl/1
      ]
   ]
   floopfetch: function [ code [block!] upsrc [block!] ] [
      while [ not tail? code ] [
         ideb: index? code 
         code: preprocessor/fetch-next code
         if block? code/1 [
            bt: append/only copy [ stepnext ] copy/deep code/1
            tmp: rdbstep/fmoldsrc code ideb - (index? code)
            tmp: rejoin [ "(" tmp ")" ]
            bt: append/only bt append copy upsrc tmp
            poke code 1 bt
         ]
      ]       
   ]
   fmoldsrc: function [ code [block!] inb [integer!] ] [
      tmp: copy ""
      either inb > 0 [
         ioff: 0
      ][
         ioff: inb - 1
      ]
      repeat itmp absolute inb [
         append tmp mold pick code itmp + ioff
         append tmp " "
      ]
      tmp
   ]

   funcpath?: function [ "returns [ true funcname] if arg is any-func" arg [path!] "path to analyse" ] [
      if any-function? get arg/1 [
         return reduce [ true arg/1 ]
      ]
      tpath: to-path arg/1
      f: false
      foreach elm next arg [
         append tpath elm
         if any-function? get tpath [
            f: true
            break
         ] 
      ]
      return reduce [ f tpath ]
   ]
   stepnext: function [ redsrc [block!] upsrc [block!] /extern bstep brst bquit blevl lret] [
         redsrc: head redsrc
         ret: none
         blevl/1: blevl/1 + 1
         iprev: 1
         if rdbstep/trc [
            print [ "<stepnext:begin>" blevl]
         ]
         while [ all [ not tail? redsrc not bquit ] ] [
            if bstep [
               bfin: true
               forever [
                  plist: none
                  binner: false
                  if bfin [
                     bfin: false
                     if all [ head? redsrc (length? upsrc) <> 0 ] [
                        dbgout/out_print form reduce [ ">" last upsrc ] ; -- print first step into 
                     ]
                     flist redsrc []
                  ]
                  icmd: dbgout/in_ask "(rdbstep) "
                  either (length? icmd) = 0 [ 
                     bfin: true
                  ][
                     icmd: split icmd " "
                     bcmd: make block! [
                           "list"      (pfunc: :flist plist: true)   | "l" (pfunc: :flist plist: true)
                         | "help"      (pfunc: :fhelp)   | "h" (pfunc: :fhelp) | "?" (pfunc: :fhelp)
                         | "next"      (pfunc: :ffin)    | "n" (pfunc: :ffin)
                         | "step"      (pfunc: :ffin binner: true)    | "s" (pfunc: :ffin binner: true)
                         | "red"       (pfunc: :fred)    | "r" (pfunc: :fred)  | "!" (pfunc: :fred)
                         | "cont"      (pfunc: :ffin bstep: false)   | "c" (pfunc: :ffin bstep: false) | "continue" (bfin: true bstep: false)
                         | "restart"   (pfunc: :ffin bquit: true brst: true)   | "run" (pfunc: :ffin bquit: true brst: true)
                         | "quit"      (pfunc: :ffin bquit: true)    | "q"   (pfunc: :ffin bquit: true)
                         | "where"     (pfunc: :flist plist: false)  | "w"   (pfunc: :flist plist: false)
                     ]
                     pfunc: none parm: none
                     parse icmd [ bcmd parm: ]
                     either logic? plist [
                        either plist [
                           bfin: flist/range redsrc upsrc iprev
                        ][
                           bfin: flist/where redsrc upsrc
                        ]
                     ][
                        bfin: pfunc parm
                     ]
                  ]
                  if bfin [
                     break
                  ]
               ]
            ]
            ; -- to execute step
            blbefore: copy []
            fblbefore: copy []
            if any [ binner all [ ( length? blevl ) > 2 ( last blevl ) > 0 ] ] [  ;-- if case step into
            if word? redsrc/1 [
               if ( type? get redsrc/1 ) = native! [
               switch/default redsrc/1 [
                  until    [ i: 2 ] ; index block code
                  forever  [ i: 2 ] ; index block code
                  loop     [ i: 3 ] ; index block body
                  forall   [ i: 3 ] ; index block body
                  while    [ i: 3 ] ; index block body
                  repeat   [ i: 4 ] ; index block body
                  foreach  [ i: 4 ] ; index block body
                  if       [ i: -1 ] ; after fetch-next, block body is last
                  unless   [ i: -1 ] ; after fetch-next, block body is last
                  either   [ i: -2 ] ; after fetch-next, 2 block bodies are last
                  case     [
                             if block? redsrc/2 [
                                append blbefore (index? redsrc) + 1
                                append/only blbefore copy/deep redsrc/2
                                rdbstep/floopfetch redsrc/2 append copy upsrc "case ["
                             ]
                             i: 0
                           ]
                  switch   [
                             nredsrc: preprocessor/fetch-next redsrc
                             i: -1
                             if block? nredsrc/:i [
                                append blbefore (index? nredsrc) + i
                                append/only blbefore copy/deep nredsrc/:i
                                tmp: rdbstep/fmoldsrc redsrc (index? nredsrc) - (index? redsrc) + i
                                rdbstep/floopfetch nredsrc/:i append copy upsrc append tmp " ["
                             ]
                             i: 0
                           ]
               ][ i: 0 
               ]  ;-- end switch/default
               if all [ i > 0 block? redsrc/:i ] [
                  rdbstep/flevl 1
                  append blbefore (index? redsrc) + i - 1
                  append/only blbefore redsrc/:i
                  bt: append/only copy [ stepnext ] copy/deep redsrc/:i
                  tmp: rdbstep/fmoldsrc redsrc ( i - 1 )
                  bt: append/only bt append copy upsrc append tmp " ["
                  poke redsrc i bt
               ]
               if i < 0 [
                  nredsrc: preprocessor/fetch-next redsrc
                  tmp: rdbstep/fmoldsrc redsrc (index? nredsrc) - (index? redsrc) + i
                  n: 0
                  while [ i < 0 ] [
                     if block? nredsrc/:i [
                        append blbefore (index? nredsrc) + i
                        append/only blbefore nredsrc/:i
                        bt: append/only copy [ stepnext ] copy/deep nredsrc/:i
                        either n = 0 [
                           append tmp " ["
                        ] [
                           append tmp "..] ["
                        ]
                        bt: append/only bt append copy upsrc copy tmp
                        poke nredsrc i bt
                     ]
                     i: i + 1
                     n: n + 1
                  ]
               ]  ;-- end if i < 0
			  ]  ;-- end if ( type? get redsrc/1 ) = native!
            ]  ;-- end if word? redsrc/1 
            if path? redsrc/1 [
               ;--> specific analyses : case/all switch/all 
               if ( type? get redsrc/1/1 ) = native! [
                  switch redsrc/1 [
                     case/all   [ 
                                  if block? redsrc/2 [
                                     append blbefore (index? redsrc) + 1
                                     append/only blbefore copy/deep redsrc/2
                                     rdbstep/floopfetch redsrc/2 append copy upsrc "case/all ["
                                  ]
                     ]
                     switch/default [
                             nredsrc: preprocessor/fetch-next redsrc
                             tmp: rdbstep/fmoldsrc redsrc (index? nredsrc) - (index? redsrc) - 2
                             i: -1
                             if block? nredsrc/:i [
                                append blbefore (index? nredsrc) + i
                                append/only blbefore copy/deep nredsrc/:i
                                bt: append/only copy [ stepnext ] copy/deep nredsrc/:i
                                bt: append/only bt append copy upsrc append copy tmp " [..] ["
                                poke nredsrc i bt
                             ]
                             i: -2
                             if block? nredsrc/:i [
                                append blbefore (index? nredsrc) + i
                                append/only blbefore copy/deep nredsrc/:i
                                rdbstep/floopfetch nredsrc/:i append copy upsrc append copy tmp " ["
                             ]
                     ]
                  ]
               ]
            ]
            either any [ set-word? redsrc/1 set-path? redsrc/1 ] [
               i: 2
            ] [
               i: 1
            ]
            bfun: reduce [ false none]
            case [
               word? redsrc/:i [ bfun: reduce [true redsrc/:i ] ]
               path? redsrc/:i [ bfun: rdbstep/funcpath? redsrc/:i ]
            ]
            if all [ bfun/1 function? get bfun/2 ] [
			   ;-- treatment for function!
               rdbstep/flevl -1
               append/only fblbefore bfun/2
               append/only fblbefore copy/deep body-of get bfun/2
               bt: append/only copy [ stepnext ] copy/deep body-of get bfun/2
               tmp: rejoin [ "In function " mold bfun/2 ]
               bt: append/only bt append copy upsrc tmp
;               append clear body-of get bfun/2 copy/deep bt ;-- ok for user function but not for embedded Red functions
               either word? bfun/2 [
                  do reduce [ to set-word! bfun/2 'func spec-of get bfun/2 copy/deep bt ]
               ][
                  do reduce [ to set-path! bfun/2 'func spec-of get bfun/2 copy/deep bt ]
               ]
               dbgout/out_print form reduce [ "--Call" mold bfun/2 "--" ]
               if rdbstep/trc [
                  print "<Save before calling>" probe fblbefore
               ]
            ]
            ]  ;-- end if binner (case step into)
            iprev: index? redsrc
            trts: copy [
               break [
                  lret: copy ""
                  redsrc: tail redsrc
                  blevl/2: compose [ (to-logic true) loop]
               ]
               return [
                  lret: mold do/next redsrc/2 'redsrc
                  redsrc: tail redsrc
                  blevl/2: compose [ (to-logic true) func]
               ]
               exit [
                  lret: copy ""
                  redsrc: tail redsrc
                  blevl/2: compose [ (to-logic true) func]
               ]
            ]
            either redsrc/1 = 'break/return [
               trt: copy [
                  lret: mold do/next redsrc/2 'redsrc
                  redsrc: tail redsrc
                  blevl/2: compose [ (to-logic true) loop]
               ]
            ] [
               trt: select trts redsrc/1
            ]
            either none? trt [
;            do/next redsrc 'redsrc
               if rdbstep/trc [
                     i: index? redsrc
               ]
               ret: none
               if error? err: try [ ret: do/next redsrc 'redsrc ] [
                  unless err/id = 'need-value [ dbgout/out_print form reduce [ "Error Id:" err/id ] dbgout/out_print form err ]
                  if rdbstep/trc [
                     print [ "<do/next error Id:>" err/id "index" i index? redsrc ]
                     probe redsrc
                  ]
               ]
               unless (length? blbefore) = 0 [
                  foreach [ i b ] blbefore [
                     poke (head redsrc) i b
                  ]
               ]
               unless (length? fblbefore) = 0 [
                  foreach [ i b ] fblbefore [
                     if rdbstep/trc [
                         print ["<Restore after calling>" i type? get i] probe b
                     ]
;                     append clear body-of get i copy/deep b ;-- ok for user function but not for embedded Red functions
                     either word? i [
                        do reduce [ to set-word! i 'func spec-of get i copy/deep b ]
                     ][
                        do reduce [ to set-path! i 'func spec-of get i copy/deep b ]
                     ]
                     dbgout/out_print form reduce [ "--Return" mold i "--" ]
                  ]
               ]
            ] [
               ; break or return or exit
               do trt
            ]  ;-- end either none? trt
            if blevl/2/1 [
               if blevl/1 > absolute (last blevl) [
                  redsrc: tail redsrc ; to ignore the rest of commands because of break
               ]
            ]
         ]   ;-- end while [ all [ not tail? redsrc not bquit ] ]
         blevl/1: blevl/1 - 1
         if blevl/2/1 [
            tmp: last blevl
            if blevl/1 = absolute ( last blevl ) [
              take/last blevl
              either blevl/2/2 = 'loop [
                 ;--- loop break
                 if positive? tmp [
                    blevl/2/1: false
                 ]
              ] [
                 ;--- func return
                 if negative? tmp [
                    blevl/2/1: false
                 ]
              ]
            ]
            either any [ blevl/2/2 = 'loop positive? tmp] [
               ;--- loop break
               if rdbstep/trc [
                  print [ "<loop break>" probe lret]
               ]
               either ( length? lret ) = 0 [
                  break
               ] [
                  break/return load lret
               ]
            ] [
               ;--- func return
               if rdbstep/trc [
                  print [ "<func return>" probe lret]
               ]
               either ( length? lret ) = 0 [
                  exit
               ] [
                  return load lret
               ]
            ]
         ]
         if rdbstep/trc [
            print [ "<stepnext:end>" blevl "return type?" type? :ret ]
         ]
         if not none? :ret [
            :ret
         ]
   ]
   run: function [ rsrc [file! url! string! block!] /replay wrep [word!] /extern bstep brst bquit] [
      upsrc: copy []
      either replay [
         dbgout/replay: wrep
         dbgout/i: 0
         delete dbgout/outfile
      ][
         dbgout/replay: 'no
      ]
      either any [file? rsrc url? rsrc] [
         redsrc: load rsrc 
         append upsrc mold rsrc
      ][
         redsrc: rsrc
      ]
      bstep: true
      print "Type help or h or ? for help at the prompt (rdbstep)"
      forever [
         brst: false
         bquit: false
         r: stepnext redsrc copy upsrc
         unless brst [
            break
         ]
      ]
      dbgout/out_prin "rdbstep End"
      either (length? upsrc) = 0 [
         dbgout/out_print ""
      ][
         dbgout/out_print form reduce ["(" upsrc/1 ")"]
      ]
      either none? r [] [ r ]
   ]
] ; end rdbstep context
;print system/script/args
;rdbstep/trc: true ;-- to enable some traces
rdbstep/run system/script/args  ;-- default usage
;rdbstep/run/replay system/script/args 'new  ;-- save input/output in files %p_in.txt/%p_out.txt
;rdbstep/run/replay system/script/args 'yes   ;-- replay input file %p_in.txt and save output in file %p_out.txt

