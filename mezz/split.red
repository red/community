Red [
   Tabs: 4
]

map-each: function [
	"Evaluates body for each value(s) in a series, returning all results."
	'word [word! block!] "Word, or words, to set on each iteration"
	data [series! map!] 
	body [block!]
] [
	collect [
		foreach :word data [
			if not unset? set/any 'tmp do body [keep/only :tmp]
		]
	]
]

collect: function [
	"Collect in a new block all the values passed to KEEP function from the body block"
	body [block!]	"Block to evaluate"
	/into			"Insert into a buffer instead (returns position after insert)"
		collected [series!] "The buffer series (modified)"
][
	keep: func [v /only][either only [append/only collected v][append collected v]]
	
	unless collected [collected: make block! 16]
	parse body rule: [									;-- selective binding (needs BIND/ONLY support)
		any [pos: ['keep | 'collected] (pos/1: bind pos/1 'keep) | any-string! | into rule | skip]
	]
	do body
	either into [collected][head collected]
]

split: function [
	"Split a series into pieces; fixed or variable size, fixed number, or at delimiters"
	series [series!] "The series to split"
	;!! If we support /at, dlm could be any-value.
	dlm    ;[block! integer! char! bitset! any-string! any-function!] "Split size, delimiter(s), predicate, or rule(s)." 
	/parts "If dlm is an integer, split into n pieces, rather than pieces of length n."
	/at "Split into 2, at the index position if an integer or the first occurrence of the dlm"
][
	if any-function? :dlm [
		res: reduce [ copy [] copy [] ]
		foreach value series [
			append/only pick res make logic! dlm :value :value
		]
		return res
	]
	if at [
		return reduce either integer? dlm [
			[
				copy/part series dlm
				copy system/words/at series dlm + 1
			]
		][
			;-- Without adding a /tail refinement, we don't know if they want
			;	to split at the head or tail of the delimiter, so we'll exclude
			;	the delimiter from the result entirely. They know what the dlm
			;	was that they passed in, so they can add it back to either side
			;	of the result if they want to.
    		[
    			copy/part series find series :dlm
    			copy find/tail series :dlm
    		]
		]
	]
	;print ['split 'parts? parts mold series mold dlm]
	either all [block? dlm  parse dlm [some integer!]][
		map-each len dlm [
			either positive? len [
				copy/part series series: skip series len
			][
				series: skip series negate len
				()										;-- return unset so that nothing is added to output
			]
		]
	][
		size: dlm										;-- alias for readability
		res: collect [
			;print ['split 'parts? parts mold series mold dlm newline]
			parse series case [
				all [integer? dlm  parts][
					if size < 1 [cause-error 'Script 'invalid-arg size]
					count: size - 1
					piece-size: to integer! round/down divide length? series size
					if zero? piece-size [piece-size: 1]
					[
						count [copy series piece-size skip (keep/only series)]
						copy series to end (keep/only series)
					]
				]
				integer? dlm [
					if size < 1 [cause-error 'Script 'invalid-arg size]
					[any [copy series 1 size skip (keep/only series)]]
				]
				'else [									;-- = any [bitset? dlm  any-string? dlm  char? dlm]
					[any [mk1: some [mk2: dlm break | skip] (keep/only copy/part mk1 mk2)]]
				]
			]
		]
		;-- Special processing, to handle cases where they spec'd more items in
		;   /parts than the series contains (so we want to append empty items),
		;   or where the dlm was a char/string/charset and it was the last char
		;   (so we want to append an empty field that the above rule misses).
		fill-val: does [copy either any-block? series [ [] ][ "" ]]
		add-fill-val: does [append/only res fill-val]
		case [
			all [integer? size  parts][
				;-- If the result is too short, i.e., less items than 'size, add
				;   empty items to fill it to 'size.
				;   We loop here, because insert/dup doesn't copy the value inserted.
				if size > length? res [
					loop (size - length? res) [add-fill-val]
				]
			]
			;-- integer? size
			;	If they spec'd an integer size, but did not use /parts, there is
			;	no special filing to be done. The final element may be less than
			;	size, which is intentional.
			;--
			'else [ 									;-- = any [bitset? dlm  any-string? dlm  char? dlm]
				;-- If the last thing in the series is a delimiter, there is an
				;   implied empty field after it, which we add here.
				case [
					bitset? dlm [
						;-- ATTEMPT is here because LAST will return NONE for an 
						;   empty series, and finding none in a bitest is not allowed.
						if attempt [find dlm last series][add-fill-val]
					]
					char? dlm [
						if dlm = last series [add-fill-val]
					]
					string? dlm [
						if all [
							find series dlm
							empty? find/last/tail series dlm
						][add-fill-val]
					]
				]
			]
		]

		res
	]
]
 
test: func [block expected-result /local res err] [
	if error? set/any 'err try [
		print [mold/only :block newline tab mold res: do block]
		if res <> expected-result [print [tab 'FAILED! tab 'expected mold expected-result]]
	][
		print [mold/only :block newline tab "ERROR!" mold err]
	]
]

test [split "1234567812345678" 4]  ["1234" "5678" "1234" "5678"]

test [split "1234567812345678" 3]  ["123" "456" "781" "234" "567" "8"]
test [split "1234567812345678" 5]  ["12345" "67812" "34567" "8"]

test [split/parts [1 2 3 4 5 6] 2]       [[1 2 3] [4 5 6]]
test [split/parts "1234567812345678" 2]  ["12345678" "12345678"]
test [split/parts "1234567812345678" 3]  ["12345" "67812" "345678"]
test [split/parts "1234567812345678" 5]  ["123" "456" "781" "234" "5678"]

; Dlm longer than series
test [split/parts "123" 6]       ["1" "2" "3" "" "" ""] ;or ["1" "2" "3"]
test [split/parts [1 2 3] 6]     [[1] [2] [3] [] [] []] ;or [1 2 3]
;test [split/parts [1 2 3] 6]     [[1] [2] [3] none none none] ;or [1 2 3]


test [split [1 2 3 4 5 6] [2 1 3]]                  [[1 2] [3] [4 5 6]]
test [split "1234567812345678" [4 4 2 2 1 1 1 1]]   ["1234" "5678" "12" "34" "5" "6" "7" "8"]
test [split first [(1 2 3 4 5 6 7 8 9)] 3]          [(1 2 3) (4 5 6) (7 8 9)]
;!! Red doesn't have binary! yet
;test [split #{0102030405060708090A} [4 3 1 2]]      [#{01020304} #{050607} #{08} #{090A}]

test [split [1 2 3 4 5 6] [2 1]]                [[1 2] [3]]

test [split [1 2 3 4 5 6] [2 1 3 5]]            [[1 2] [3] [4 5 6] []]

test [split [1 2 3 4 5 6] [2 1 6]]              [[1 2] [3] [4 5 6]]

; Old design for negative skip vals
;test [split [1 2 3 4 5 6] [3 2 2 -2 2 -4 3]]    [[1 2 3] [4 5] [6] [5 6] [3 4 5]]
; New design for negative skip vals
test [split [1 2 3 4 5 6] [2 -2 2]]             [[1 2] [5 6]]

test [split "abc,de,fghi,jk" #","]              ["abc" "de" "fghi" "jk"]
;!! Red doesn't have tag! yet
;test [split "abc<br>de<br>fghi<br>jk" <br>]     ["abc" "de" "fghi" "jk"]

test [split "a.b.c" "."]     ["a" "b" "c"]
test [split "c c" " "]       ["c" "c"]
test [split "1,2,3" " "]     ["1,2,3"]
test [split "1,2,3" ","]     ["1" "2" "3"]
test [split "1,2,3," ","]    ["1" "2" "3" ""]
test [split "1,2,3," charset ",."]    ["1" "2" "3" ""]
test [split "1.2,3." charset ",."]    ["1" "2" "3" ""]

test [split "-a-a" ["a"]]    ["-" "-"]
test [split "-a-a'" ["a"]]    ["-" "-" "'"]

;-------------------------------------------------------------------------------
; to/thru bitset! is broken in R3 now.
test [split "abc|de/fghi:jk" charset "|/:"]                     ["abc" "de" "fghi" "jk"]

; to/thru block! is broken in R3 now.
test [split "abc^M^Jde^Mfghi^Jjk" [crlf | #"^M" | newline]]     ["abc" "de" "fghi" "jk"]
test [split "abc     de fghi  jk" [some #" "]]                  ["abc" "de" "fghi" "jk"]

;-------------------------------------------------------------------------------

test [split [1 2 3 4 5 6] :even?]	[[2 4 6] [1 3 5]]
test [split [1 2 3 4 5 6] :odd?]	[[1 3 5] [2 4 6]]
test [split [1 2.3 /a word "str" #iss x: :y] :refinement?]	[[/a] [1 2.3 word "str" #iss x: :y]]
test [split [1 2.3 /a word "str" #iss x: :y] :number?]		[[1 2.3] [/a word "str" #iss x: :y]]
test [split [1 2.3 /a word "str" #iss x: :y] :any-word?]	[[/a word #iss x: :y] [1 2.3 "str"]]

;-------------------------------------------------------------------------------

test [split/at [1 2.3 /a word "str" #iss x: :y] 4]	[[1 2.3 /a word] ["str" #iss x: :y]]
;!! Splitting /at with a non-integer excludes the delimiter from the result
test [split/at [1 2.3 /a word "str" #iss x: :y] "str"]	[[1 2.3 /a word] [#iss x: :y]]
test [split/at [1 2.3 /a word "str" #iss x: :y] 'word]	[[1 2.3 /a] ["str" #iss x: :y]]
