Red [
    Title: "JSON parser"
    File: %json.red
    Author: "Nenad Rakocevic"
    License: "BSD-3 - https://github.com/red/red/blob/master/BSD-3-License.txt"
    Tabs: 4
]

json: context [
	quoted-char:	 charset {"\/bfnrt}
	exponent:	 charset "eE"
	sign:		 charset "+-"
	digit-nz:	 charset "123456789"
	digit:		 union digit-nz "0"
	hexa:		 union digit charset "ABCDEFabcdef"
	blank:		 charset " ^(09)^(0A)^(0D)"
	ws:		 [any blank]
	dbl-quote:	 #"^""
	s: e: 		 none
	
	decode-str: func [start end /local new rule s][
		new: copy/part start back end					;-- exclude ending quote
		rule: [
			any [
				s: remove #"\" [
					#"b" 	(s/1: #"^H")
					| #"f"  (s/1: #"^(0C)")
					| #"n"  (s/1: #"^/")
					| #"r"  (s/1: #"^M")
					| #"u" 4 hexa
				]
				| skip
			]
		]
		parse new rule
		new
	]
		
	value: [
		string	  keep (decode-str s e)
		| number  keep (load copy/part s e)
		| "true"  keep (true)
		| "false" keep (false)
		| "null"  keep ('null)
		| object-rule
		| array
	]

	number: [s: opt #"-" some digit opt [dot some digit opt [exponent sign 1 3 digit]] e:]
	
	string: [dbl-quote s: any [#"\" [quoted-char | #"u" 4 hexa] | dbl-quote break | skip] e:]
	
	couple: [ws string keep (load decode-str s e) ws #":" ws value]
	
	object-rule: [
		#"{" collect set list opt [any [couple #","] couple] ws #"}"
		keep (make map! list)
	]
	
	array: [#"[" collect opt [any [ws value #","] ws value] ws #"]"]
	
	decode: function [data [string!] return: [block! object!]][
		parse data [collect any [blank | object-rule | array]]
	]
]
