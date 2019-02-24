Red [
    Title: "Red debug step script"
    File: %rdbstep.red
    Date:  27-Jan-2019
    Author: "JLM cyclo07"
    Purpose: "Debug step by step a Red script (tool for do/next)."
    Usage: "From REPL : do/args %rdbstep.red <Red Script>"
    Arguments: "<Red Script> [file! url! string! block!]"
]
rdbstep: context [
   iprev: 1
   redsrc: none
   flist: function [ arg /extern redsrc iprev ][
      unless iprev = (index? redsrc) [
         bl: split mold/only copy/deep/part redsrc ( iprev - (index? redsrc)) newline
         repeat i length? bl [
            prin "  "
            print pick bl i
         ]
      ]
      bl: split mold/only redsrc newline
      unless (length? bl) = 0 [
         if (length? bl/1) = 0 [
            remove bl
         ]
      ]
      len: min 10 length? bl
      prin "->"
      print pick bl 1
      repeat i ( len - 1 ) [
         prin "  "
         print pick bl ( i + 1 )
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
n(ext) | s(tep) | <enter>
^(tab)execute the current line and stop at the next step.^(line)
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
   run: function [ rsrc [file! url! string! block!] /extern redsrc iprev] [
      either any [file? rsrc url? rsrc] [
         redsrc: load rsrc 
      ][
         redsrc: rsrc
      ]
      bstep: true
      print "Type help or h or ? for help at the prompt (rdbstep)"
      forever [
         brst: false
         redsrc: head redsrc
         bquit: false
         while [ all [ not tail? redsrc not bquit ] ] [
            if bstep [
               forever [
                  bfin: false
                  icmd: ask "(rdbstep) "
                  either (length? icmd) = 0 [ 
                     bfin: true
                  ][
                     icmd: split icmd " "
                     bcmd: make block! [
                           "list"      (pfunc: :flist)   | "l" (pfunc: :flist)
                         | "help"      (pfunc: :fhelp)   | "h" (pfunc: :fhelp) | "?" (pfunc: :fhelp)
                         | "next"      (pfunc: :ffin)    | "n" (pfunc: :ffin)
                         | "step"      (pfunc: :ffin)    | "s" (pfunc: :ffin)
                         | "red"       (pfunc: :fred)    | "r" (pfunc: :fred)  | "!" (pfunc: :fred)
                         | "cont"      (pfunc: :ffin bstep: false)   | "c" (pfunc: :ffin bstep: false) | "continue" (bfin: true bstep: false)
                         | "restart"   (pfunc: :ffin bquit: true brst: true)   | "run" (pfunc: :ffin bquit: true brst: true)
                         | "quit"      (pfunc: :ffin bquit: true)    | "q"   (pfunc: :ffin bquit: true)
                     ]
                     pfunc: none parm: none
                     parse icmd [ bcmd parm: ]
                     bfin: pfunc parm
                  ]
                  if bfin [
                     break
                  ]
               ]
            ]
            iprev: index? redsrc
            do/next redsrc 'redsrc
         ]
         unless brst [
            break
         ]
      ]
      print "rdbstep End"
   ]
] ; end rdbstep context
;print system/script/args
rdbstep/run system/script/args

