Red [
   author: "Maxim Velesyuk"
   description: "Common Lisp condition-restart system implementation for Red"
   Tabs: 4
]

; utils
*word-counter*: 0
gen-word: does [
   *word-counter*: *word-counter* + 1
   to-word append "G-" to-string *word-counter*
]

; register custom error type

system/catalog/errors: make system/catalog/errors [
   condition: object [
      code: 42
      type: "CL-style condition"
      simple: ["simple" :arg1]
      tag: ["tag" :arg1]
   ]
]

; stacks for handlers and restarts

*handler-stack*: copy []
*restart-stack*: copy []

; adds handler to handlers stack to be executed in case of error inside body
; removes handler afterwards

handler-bind: func [signal-type bind-callback body /local ret] [
   insert *handler-stack* reduce [signal-type :bind-callback]
   error? ret: try [body]
   take/part *handler-stack* 2
   ret
]

; runs code with custom callback provided
; this callback is called in case of error with error object as an argument
; result of this callback will be the result of whole call in case of error

handler-case: func [signal-type case-callback body 
                    /local ret tag bind-callback] [
   tag: gen-word
   bind-callback: func [e /local value] compose/deep [
      value: case-callback e
      cause-error 'condition 'tag [(to-lit-word tag) value]
   ]
   if error? ret: try [ handler-bind signal-type :bind-callback :body ] [
      if all [ ret/type = 'condition ret/id = 'tag ret/arg1 = tag ] [ 
         ; return saved value
         return ret/arg2
      ]
   ]
   ret
]

; lookups for closest matching handler in handlers stack
; runs this handler with custom error
; (handler may raise new error to change execution flow, e.g. `handler-case`)
; continues normal execution flow afterwords

fire-signal: func [signal-type data /local e handler] [
   e: make error! [type: 'condition id: 'simple arg1: signal-type arg2: data]
   if handler: select *handler-stack* e/arg1 [ handler :e ]
]

; runs fire-signal handler
; if handler was found - it will raise another error and go through different execution path
; otherwise re-raise original error

fire-error: func [error] [
   fire-signal error
   ; error stops program if handler not found
   ; CL invokes debugger here
   error
]

; same as handler-bind but for restart stack
; instead of error type uses arbitary `name`
restart-bind: func [name bind-callback body] [
   insert *restart-stack* reduce [name :bind-callback]
   error? ret: try [body]
   take/part *restart-stack* 2
   ret
]

; same as handler-aces but for restart stack
; same thing, accepts arbitary name
restart-case: func [name case-callback body] [
   tag: gen-word
   bind-callback: func [e /local value] compose/deep [
      value: case-callback e
      cause-error 'condition 'tag [(to-lit-word tag) value]
   ]
   if error? ret: try [ restart-bind name :bind-callback :body] [
      if all [ ret/type = 'condition ret/id = 'tag ret/arg1 = tag ] [ 
         return ret/arg2
      ]
   ]
   ret
]

; similar to fire-signal, lookups for name instead and just returns it
find-restart: func [name /throw-not-found /local restart] [
   if restart: select *restart-stack* name [ return :restart ]
   if throw-not-found [ throw 'restart-not-found ]
]

; finds and executes restart
invoke-restart: func [name param /local restart] [
   restart: find-restart/throw-not-found name
   restart param
]

; runs body and actions afterwards regardless if body had an error or not 
unwind-protect: func [body actions /local ret] [
   error? ret: try [body]
   forall actions [ do actions/1 ]
   ret
]



; how it works, examples


; simple signal with executing handler

; function fires signal if y is zero
; returns 0 regardless if signal was handled or not
div-signal: func [x y] [
   if zero? y [
      fire-signal 'zero x
      return 0
   ]
   x / y
]

; handler-bind catches 'zero signal, runs simple handler and returns what `div-signal` returns
val: handler-bind 'zero does [
   print "i'm inside div-signal"
] has [res] [
   print "entering signal-func"
   res: div-signal 5 0
   print ["returning" res "from body"]
   res
]

print ["value:" val newline]

; handle error and return custom value from handler

; same, but fire error this time
; if handler is not found error is propagated to the top level
div-error: func [x y] [
   if zero? y [
      fire-error 'zero x
   ]
   x / y
]

; handler-case catches 'zero error, and overrides original return value, stopping the error
val: handler-case 'zero func [e] [
   print ["i'm in div-error, found " e/type ", returning -1 instead"]
   -1
] has [res] [
   print "entering error-func"
   res: div-error 5 0
   res
]

print ["value:" val newline]

; restart invocation example

; function by itself provides a way to solve the problem:
; restart `return-value` returns arbitary value on error
div-restart: func [x y /local callback] [
   callback: func [param] [
      print "entering restart return-value"
      print ["returning" param "from restart"]
      param
   ]
   print "before restart-case"
   restart-case "return-value" :callback does compose [div-error (x) (y)]
]

; we bind 'zero handler which decides to lookup for restart `return-value` 
; and invoke that restart with value 42
val: handler-bind 'zero func [e] [
   print "entering handler callback"
   print "invoking restart return-value with param = 42"
   invoke-restart "return-value" 42
] has [res] [
   print "entering handler-bind with restart"
   div-restart 5 0
]

print ["value:" val newline]


; unwind-protect
; ensures that actions code runs in any case

val: handler-case 'zero func [e] [
   print ["i'm in div-error, found " e/type ", returning -5 instead"]
   -5
] has [res] [
   print "entering error-func under unwind-protect"
   res: unwind-protect does [div-error 5 0] [
      [print "change 0 in div-error above, I'll be invoked anyway, usually to do the clean-up"]
   ]
   res
]

print ["value:" val newline]


; >red restarts.red
; entering signal-func
; i'm inside div-signal
; returning 0 from body
; value: 0 

; entering error-func
; i'm in div-error, found  condition , returning -1 instead
; value: -1 

; entering handler-bind with restart
; before restart-case
; entering handler callback
; invoking restart return-value with param = 42
; entering restart return-value
; returning 42 from restart
; value: 42 

; entering error-func under unwind-protect
; i'm in div-error, found  condition , returning -5 instead
; change 0 in div-error above, I'll be invoked anyway
; value: -5 
