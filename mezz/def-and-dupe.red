Red [
   Tabs: 4
]

e.g.: :comment

; Using a context here, because Red's compiler doesn't like inner funcs yet.
defaulting-ctx: context [
	def: func [w "Word" v "Value"][
		; We're setting one word, so don't need to use set/only.
		if any [not value? :w  none? get w][set w :v]
		get w
	]
	set 'default function [
		"Sets the value(s) one or more words refer to, if the word is none or unset"
		'word "Word, or block of words, to set."
		value "Value, or block of values, to assign to words."
	][
		; CASE is used, rather than COMPOSE, to avoid the block allocation.
		case [
			word?  :word [def word :value]
			block? :word [
				collect [
					repeat i length? word [
						keep/only def word/:i either block? :value [value/:i][:value]
					]
				]
			]
		]
	]
	e.g. [
		default a 1
		default [a b c] [2 3 4]
		default f :append
		default [g h i j k l m] [1 2 [3] 4 5 6 7]
		default [g h i j k l m n o] [. . . . . . . .]
	]
]

; Haven't decided on a name yet.
dup: dupe: dupl: func [
	"Returns a new block with 'value duplicated 'count times."
	value "Series values are deep copied, functions are evaluated and passed count index"
	count [integer!]
	/str "Return a string, rather than a block; /into overrides this"
	/into "Put results in 'out, instead of creating a new block/string"
		out [series!] "Target for results, when /into is used"
	/local i
][
	default out make either str [string!][block!] count
	if not positive? count [return out]
	out: case [
		series? :value [
			loop count [insert/only out copy/deep value]
		]
		any-function? :value [
			repeat i count [insert/only out value i]
		]
		'else [insert/dup out value count]
	]
	either into [out][head out]
]
e.g. [
	dupe #"-" 5
	dupe/str #"-" 5
	dupe/into #"-" 5 s: "abc"
	print s
	dupe/into #"-" 5 tail s: "abc"
	print s
	blk: dupe [] 5
	append blk/1 'x
	print mold blk		; show that sub blocks are copied
	blk: dupe func [i][dupe/str to char! #"@" + i i] 5
	print mold blk
]

halt
