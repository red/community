Red [
    Author: "Nenad Rakocevic"
    Date: 29/11/2013
    Tabs: 4
]

bf: function [prog [string!]][
	size: 30000
	cells: make string! size
	append/dup cells null size

	one-back: [pos: (pos: back pos) :pos]

	jump-back: [
		one-back
		any [
			one-back 
			["]" jump-back "[" | "[" resume: break | skip]
			one-back
		]
	]

	cmd: complement charset "[]"
	nested: [any cmd | "[" nested "]"]

	brainfuck: [
		some [
			  ">" (cells: next cells)
			| "<" (cells: back cells)
			| "+" (cells/1: cells/1 + 1)
			| "-" (cells/1: cells/1 - 1)
			| "." (prin cells/1)
			| "," (cells/1: first input "")
			| "[" [if (cells/1 = null) nested "]" | none]
			| "]" [pos: if (cells/1 <> null) jump-back :resume | none]
			| skip
		]
	]
	parse prog brainfuck
]

; Print Hello World! in brainfuck

bf {
++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.
>++.<<+++++++++++++++.>.+++.------.--------.>+.>.
}
