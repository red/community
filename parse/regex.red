Red [
	Author: 	"Toomas Vooglaid"
	file: 		"%regex.red"
	Purpose: 	{Simple regex to parse converter}
  Tabs: 4
]

re-ctx: context [
	spec: 		clear []
	starting: 	'loose
	ending: 	'loose
	nest-level: 0
	;outergroup: no
	;startgroup: yes
	
	matching-paren: func [s /local l e][
		;startgroup: yes
		l: nest-level: nest-level + 1
		parse s [any [
			"\(" | "\)"
			| #"(" (l: l + 1) 
			| e: #")" (
				either l = nest-level [
					nest-level: l - 1 
					return copy/part s e
				][l: l - 1]
			)
			| skip ;(startgroup: no)
		]]
	]
	group: 	[
		;#"(" s: keep (c: copy/part s e: find s #")" copy build2 c) :e skip
		#"(" s:  keep (
			t: find/tail s c: matching-paren s 
			;print reduce [s t] 
			copy build2 copy c
		) :t skip
	]
	class: 	[
		"[[:" 		copy cl to ":]]" 3 skip keep (to-word cl)
		| "\d" 		keep ('digit)
		| "\w" 		keep ('wordletter)
		| "\s" 		keep ('wspace)
		| #"." 		keep ('anychar)
	]
	paren: 			charset [#"(" #")"]
	lower: 			charset [#"a" - #"z" #"ß" - #"ö" #"ø" - #"ÿ"]
	upper: 			charset [#"A" - #"Z" #"À" - #"Ö" #"Ø" - #"Þ"]
	alpha: 			union lower upper
	digit: 			charset "0123456789"
	number:			[some digit]
	alnum:			union alpha digit
	wordletter:		union alpha charset "_-"
	wspace: 		charset reduce [space tab cr lf]
	punctuation:	charset [#"," #";" #"!" #"^"" #"'"] ;"
	meta: 			[#"\" #"^^" #"$"  #"." #"|" #"?" #"*" #"+" #"(" #")" #"[" #"^{"]
	altern: 		[#"|" keep ('|)]
	metaset: 		charset meta
	literal: 		charset compose [not (meta)]
	escaped:		[#"\" keep metaset]
	anychar:		union metaset union alnum union wspace punctuation
	char: 			[keep [#")" (print "Warning! Invalid use of closing paren") | literal]]
	;start-end:		[#"^^" (starting: 'strict) | #"$" keep ('end)]
	
	sequence: [
		  escaped
		| altern
		;| start-end
		| group
		| class
		| char 
	]
	to-int: func [char][to-integer to-string char]
	repeater: [
		  #"^{" copy n1 number #"," copy n2 number #"^}" 	keep (reduce [to-int n1 to-int n2])
		| "{," 	copy n2 number #"^}" 					 	keep (reduce [0  to-int n2])
		| #"^{" copy n1 number ",}"						 	keep (reduce [to-int n1 100])
		| #"^{" copy n1 number #"^}"					 	keep (to-int n1)
		| #"?" 											 	keep ('opt)
		| #"+" 												keep ('some)
		| #"*" 												keep ('any) ;s: keep	(to-lazy copy s 'any)
	]
comment {
	lazy-num: 0 lazy: off										; lazy-num and lazy check
	next-lazy: does [to-word append copy "_" lazy-num: lazy-num + 1] ; lazy-number-word generator
	to-lazy: func [re rpt /local out nl bre][					; make a solution for lazy operators
		lazy: on
		out: clear []
			; construct helper bloc of the final form: [copy _1 to [tail] if (parse _1 compose/deep [rpt [(seq)]]) [tail]]
		append out compose/deep [copy (nl: next-lazy) to [(bre: build2 copy re)] if]	; first part of the block
		append/only out to-paren compose/deep [parse (nl) compose/deep [(rpt) [(quote (seq))]]] ; additional parse helper
		append/only out compose [(bre)]													; ending of the block
	]
}
	build2: func [inner /local out seq rpt s e c t][			; copy of main build fn for nesting cases -- unsatisfactory workaround
		out: clear []											;    of the nesting problem
		parse inner rule: [
			any [ 
				collect set seq sequence 
				opt collect set rpt repeater 
				(
					;print mold reduce ["b2:" rpt seq] 
					unless empty? rpt [append out first rpt] 
					append out seq
					;print mold reduce ["group:" out]
				)
			]
		]
		out
	]
	build: func [inner /local out rpt seq s e c t][				; should be main workhorse (problem of nesting calls)
		out: clear []
		parse inner rule: [
			any [ 
				collect set seq sequence 						; take next sequence
				opt collect set rpt repeater 					; take optional repeater (special case of lazy repeaters)
				(
					;print mold reduce ["b:" rpt seq] 			; just check
					unless empty? rpt [append out first rpt] 	; if there is a repeater, append it to the output
					;unless lazy [append out seq]				; unless we have lazy repeater, append sequence to the output
					append out seq
					;print mold reduce ["out:" out]				; just check
				)
			]
		]
		out
	]
	
	finish: func [inner /local middle][
		middle: build copy inner
		append spec switch starting [strict [middle] loose [compose/deep [thru [(middle)]]]]
		append spec switch ending [strict ['end] loose [[to end]]]
		;if starting [append spec switch starting [strict [middle] loose [compose/deep [thru [(middle)]]]]]
		;if false 	[append spec switch ending [strict ['end] loose [[to end]]]]
	]

	set 'regex func [string re /case /withspec /speconly /local inner][
		lazy-num: 0 lazy: off
		spec: 	clear []
		inner: 	clear ""
		parse re [
			[
				  "^^"					(starting: 'strict) 
				;| ahead #"("			(starting: no outergroup: yes) 
				| 						(starting: 'loose)
			]
			copy inner [
				  to [#"$" end]			(ending: 'strict) 
				;| thru [#")" end]		(ending: no)
				| to end				(ending: 'loose)
			] 
			(finish copy inner)
		]
		if any [withspec speconly] [print mold spec]
		unless speconly [either case [parse/case string spec][parse string spec]]
	]
]
comment []
