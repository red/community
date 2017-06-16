Red [
	Title:   "math-lab.red"
	Author:  "Gregg Irwin"
	File: 	 %math-lab.red
	Needs:	 'View
	Purpose: {
		Experiment, to see what an interactive "Lab" tool might look 
		like, for general language functions. i.e., take the idea of
		font-lab, effect-lab, gradient-lab, etc., and apply it to
		functions to aid in language discovery and learning.
		
		It can serve a few purposes:
		- Show users what functions are available in a given "category"
		- Show them live results
		- Pre-fill values of different types, to show what the funcs
		  support
		- Interactive testing of values, to probe/confirm errors
		- Explore possible new functionality. e.g. pair! * percent!
		
		TBD: Combo boxes on args can provide pre-selected values
		TBD: Click to get detailed help on a function or category
		     (e.g. math precedence note for all math ops)
		TBD: User entry field where they can enter their own combination
			 of ops and see a result. We could even show progressive
			 evaluation, maybe requiring parens.
		TBD: Sliders could be attached to arg fields, in some cases.
 }
 Tabs: 4
]

;-------------------------------------------------------------------------------
;-- General purpose mezzanines

decr: function [
	"Decrements a value or series index"
	value [scalar! series! any-word! any-path!] "If value is a word, it will refer to the decremented value"
	/by "Change by this amount"
		amount [scalar!]
][
	incr/by value negate any [amount 1]
]

incr: function [
	"Increments a value or series index."
	value [scalar! series! any-word! any-path!] "If value is a word, it will refer to the incremented value"
	/by "Change by this amount"
		amount [scalar!]
][
	amount: any [amount 1]
	
	if integer? value [return add value amount]			;-- This speeds up our most common case by 4.5x
														;	though we are still 5x slower than just adding 
														;	1 to an int directly and doing nothing else.

	; All this just to be smart about incrementing percents.
	if all [
		integer? amount
		1 = absolute amount
		any [percent? value  percent? attempt [get value]]
	][amount: to percent! (1% * sign? amount)]			;-- % * int == float, so we cast.
		
	case [
		scalar? value [add value amount]
		any [
			any-word? value
			any-path? value								;!! Check any-path? before series?.
		][
			op: either series? get value [:skip] [:add]
			set value op get value amount
			:value                                      ;-- Return the word for chaining calls.
		]
		series? value [skip value amount]
	]
]

scalar?: func [
	"Returns true if value is any type of scalar value"
	value [any-type!]
][
	find scalar! type? :value
]

;-------------------------------------------------------------------------------
;-- App-specific support

args: make reactor! [							;-- This is where the arg texts get their values, reactively.
	arg-1: 0
	arg-2: 0
]


arity-1-ops: [absolute negate]					;-- We can determine arity dynamically, but it's overkill here.
arity-1?: func [op][find arity-1-ops op]

handle-arg-key: func [face [object!] key [char! word!]][
	switch key [
	    up   [step-face face :incr]
	    down [step-face face :decr]
	]
]

load-num: function [str][						;-- This is obviously basic
	res: attempt [load str]
	if any [none? res  block? res][res: 0]
	res
]

set-args: func [a b][							;-- How the buttons set the arg fields
	f-arg-1/data: a
	f-arg-2/data: b
]

step-face: func [face fn][
	face/text: mold fn load-num face/text		;-- MOLD is used, instead of FORM, for char! values
]

;-------------------------------------------------------------------------------
; UI

show-help: does [
	view/flags [
	    text 400x220 {  Enter values in the arg fields. As you do, changes will immediately
  be reflected for each operation, with the results shown after the
  == label. If no value appears there, it means the operation is not
  valid for the args.
  
  If the second arg column is empty, it means the operation on that
  line is a single arity function (takes just 1 arg).
  
  You can use the up/down arrow keys in the arg fields to increment
  the values up and down.
  
  The buttons at the top will preload the arg fields with values of
  different types, to show you some possibilities you might not know
  about.}
		button "Close" [unview]
	][modal]
]

; We start with a static "header" area in our layout. Then we'll add a
; bunch of other stuff dynamically.
lay-spec: copy [
	title "Red Math Lab"
	space 4x2

	button "integer!"	[set-args 1 2]
	button "float!" 	[set-args 1.0 2.0]
	button "percent!"	[set-args 10% 20%]
	button "pair!"		[set-args 10x10 5x15]
	button "pair! int"	[set-args 100x50 3]
	pad 10x0
	button "Help" 		[show-help]
	return
	button "char! int"	[set-args mold #"R" 2]
	button "tuple!"		[set-args 1.2.3 2.2.2]
	button "tuple! int"	[set-args 1.2.3 3]
	button "time!"		[set-args 1:2:3 2:2:2]
	button "time! int"	[set-args 1:2:3 4]
	pad 10x0
	button "Quit" [quit]
	pad 0x10
	return
	
	text "Args" 100x18 right
	pad 12x0
	style arg-fld: field 60 center on-key [handle-arg-key face event/key]
	f-arg-1: arg-fld "10"
	f-arg-2: arg-fld "3"
	return
	pad 0x10
	
	;-- It might seem silly to have so many styles in such a small script, when
	;	they don't add functionality. They're here largely to make the layout
	;	spec more clear in its intent, describing what each face is. In a dynamic
	;	script, where you never see the generated code, it may not matter, but
	;	sometimes you may start out with a dynamic plan, and later decide that
	;	you can just copy the generated code and paste it in somewhere. Or you
	;	may write code generators, but only want to distribute static layouts for
	;	easier maintenance.
	style text: text 60x18 center
	style arg-1-ref: text ;extra 'arg-1
	style arg-2-ref: text ;extra 'arg-2
	style spacer:    text ""
	style op-lbl:    text 100x18 right
	style op-result: text 115x18 left

	;!! IMPORTANT: This is how everything propagates reactively. It tells our
	;	'args reactor to respond to changes in the arg field faces. When the
	;	user changes a field it reactively triggers 'load-num which converts
	;	the text to a number and updates 'args. In turn, as you will see below,
	;	all the faces that mirror changes to the args react to 'args changing.
	react [
		args/arg-1: load-num f-arg-1/text
		args/arg-2: load-num f-arg-2/text
	]
]

;-- This function dynamically adds all the necessary components to the layout
;	for a give math op. 
add-op: function [op][
	;!! You MUST use copy/deep for reactor blocks to work properly, because
	;	each is uniquely related to its associated face object.
	append lay-spec compose/deep copy/deep [

		;ii The two parens here, with set-word!/lit-word! conversions in them,
		;ii are not needed in this app, but they show how you can dynamically
		;ii generate words that will refer to the faces, and tag them with 
		;ii extra data for later use.
		;(to set-word! append copy "f-op-" op) 
		op-lbl (form op) ;extra (to lit-word! form op)
		pad 10x0

		;-- Here we add our 2 arg "mirror" labels, that reflect changes to the
		;   fields. Note that we set up a static relation to the arg fields,
		;	since all we want to do is mirror their text. But the next two
		;	commented lines show how we could also react to the 'args reactor!
		arg-1-ref react [face/text: f-arg-1/text]
		(either arity-1? op ['spacer][ [arg-2-ref react [face/text: f-arg-2/text]] ])
		;arg-1-ref react [face/text: form args/arg-1]
		;(either arity-1? op ['spacer][ [arg-2-ref react [face/text: form args/arg-2]] ])

		text 25 "=="

		;-- This is our "output" text, showing the result of each op applied
		;	to the args the user entered.
		op-result react [
			;-- Wrap things in ATTEMPT to catch errors. We could add more 
			;	details later if it proves helpful.
			face/text: attempt [
				;ii In our reactors above, we relate directly to the arg fields.
				;ii But here we use the 'args reactor! because it has already
				;ii done the work of converting the text to numbers for us, to
				;ii apply the op to.
				;ii Don't forget that we're still generating layout data here!
				;ii And generating reactors only for the args an op uses.
				form (to word! op) args/arg-1 (either arity-1? op [][ [args/arg-2] ])
				;form (to word! op) load-num f-arg-1/text (either arity-1? op [][ [load-num f-arg-2/text] ])
			]
		]

		return
	]	
]

;-- This is what drives the above function, to dynamically generate the
;	faces and all their reactive relations in the layout. We just define
;	the list of operations we want to include, and and add each one.
ops: [
	absolute negate
	add subtract multiply divide modulo remainder power
	shift
	;shift/left shift/logical					;-- Have to think about how to handle these.
	;and or xor
	same? equal? strict-equal? not-equal?
	greater? lesser? greater-or-equal? lesser-or-equal?
]
foreach op ops [add-op op]

;print mold lay-spec							;-- View the generated layout spec.
view lay-spec

