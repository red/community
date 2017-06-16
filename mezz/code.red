Red [
   Tabs: 4
]


join: func [	;thx Gregg
	"Concatenate values"
	a "Coerced to string if not a series, map, or object"
	b "Single value or block of values; reduced if a is not an object or map"
][
	if all [block? :b  not object? :a  not map? :a] [b: reduce b]
	case [
		series? :a [append copy a :b]
		map?    :a [extend copy a :b]
		object? :a [make a :b]
		'else      [append form :a :b]
	]
]

object [
	replace*: :system/words/replace
	set 'replace func [
		"Improved replace with support for /case and /tail. Use native replace for binary!"
		series [series!]
		pattern
		value
		/all "Replace all occurrences"
		/case "Case-sensitive replacement"
		/tail "Return target after the last replacement position"
		return: [series!]
		/local rule pos
	][
		either binary? series [
			if any [case tail] [do make error! {/case and /tail not supported for type binary!}]
			do append copy either all [[replace*/all]][[replace*]] [series pattern value]
		][
			rule: [to pattern change pattern value pos:]
			if all [rule: append/only copy [any] rule]
			either case [
				parse/case series rule
			][
				parse series rule
			]
			either tail [pos][series]
		]
	]
]

patch: func [
	"Replace all occurrences of patches, return an error if no match"
	file [file!] "File to operate on"
	patches [block!] "Block of patches blocks containing either from/to strings or a parse rule"
	/quiet "Don't bother if no match"
	/local source patch
][
	source: read file
	foreach patch patches [
		unless empty? patch [
			either block? patch/1 [
				all [
					not parse/case source patch/1
					not quiet
					do make error! rejoin [{rule } mold patch/1 { did not match in %} file]
				]
			][
				all [
					not quiet
					not find/case source patch/1
					do make error! rejoin [{string "} patch/1 {" not found in file %} file]
				]
				replace/all/case source patch/1 patch/2
			]
		]
	]
	write file source
]

undirize: func [
	"Return dir or a copy of dir with last slash removed"
	dir [file!]
][
	either #"/" = last dir [
		head remove back tail copy dir
	][dir]
]

; maybe: func[value [any-type!] default /type types [block!] pos [block!] /local b t s][
maybe: func[
	{Convenience function to allow no value, provide default, optionally provide allowed types
	and perform transformations on those. Most useful in console for functions like cd, ls, ecc..}
	value [any-type!]
	default "Default value"
	/type
		types [block!] "Block of allowed types, each type can be followed by a transformation block"
		error [block!] {Block containing calling function name as word! and calling function arg name as word!
		Values are used to return a proper error string}
	/local b t s
][
	either unset? :value [default][
		either type [
			either find types t: type?/word value [
				either block? b: select types t [
					do bind b 'value
				][
					value
				]
			][
				; s: find stack 'maybe
				; cause-error 'script 'expect-arg [s/(pos/1) t s/(pos/2)]
				cause-error 'script 'expect-arg [error/1 t error/2]
			]
		][value]
	]
]

maybe-dir: func [
	"Convenience function, allow no value for dir, default to current dir, allow specific types"
	dir [any-type!]
	error [block!] {Block containing calling function name as word! and calling function arg name as word!
		Values are used to return a proper error string}
][
	maybe/type :dir %./ either system/state/interpreted? [
		[file! string! integer! word! path!]
	][
		[file! word! [get value] path! [get value]]	;if compiled, word! and path! types gets evaluated, Good or not Good?
	] error
]

object [

	rules: [
		dot [[[dot] "dot files"]]
		dot-folder [[[[dot if (dir? item)]] "dot folders"]]
		dot-file [[[[dot if (not dir? item)]] "dot files"]]
		folder [[[if (dir? item)] "folders"]]
		file [[[if (not dir? item)] "files"]]
	]

	list-rules: func [/local name description][
		print "Available rules:"
		foreach [name description] rules [
			print [pad insert form name space 12 "->" description/1/2]
		]
	]

	set 'ls func [
		"Improved directory listing"
		'dir [any-type!] "Directory to operate on. If no value use current one"
		/deep "Descend all subfolders"
		/strict
		/level "Descend only x levels"
			level* [integer! none!] "Number of levels to descend"
		/do  "Apply a function to matched items"
			fun	[function!] "Function to apply, spec block can call item and depth"		;see examples..
		/filter
			'rule [word! block! none!]
		/skip "Skip value matching parse rule"
			'not-rule [word! block! none!] "parse rule (with optional [to end]) or dot (convenience to skip dot files)"
		/help "Show available rules and exit"
		/pass "Internal arg to pass data for recursion. Don't use!"
			depth? [logic!]
			depth [block!]
			path [file!]
			strict* [logic!]
		/local item list last match?
	][
		either pass [
			append depth off
			if strict* [strict: on]
		][
			if help [list-rules exit]
			dir: to-file maybe-dir :dir [ls dir]
			unless dir? dir [dir: join dir #"/"]
			all [rule not-rule do make error! "Only use /filter or /skip not both"]		;should allow both??????
			if not-rule [rule: not-rule]
			unless block? rule [
				rule: append clear [] either word? rule [first switch rule rules][[]]
				if not-rule [insert rule 'not]
				append rule [to end]
			]
			unless :fun [fun: func [item][print item]]
			path: dir
			depth?: parse spec-of :fun [2 word! to end]			;check if depth is used in passed function
			depth: append clear [] off
			strict: to-logic strict
		]
		list: sort read dir										;macOS sorts, Linux doesn't, Windows?
		if empty? list [exit]
		if depth? [												;look ahead for last match only if depth is used
			list: tail list
			until [
				list: back list
				item: first list
				any [parse item rule 1 = index? list]
			]
			last: index? list
			list: head list
		]
		forall list [
			item: first list
			match?: parse item bind rule 'item
			if any [match? not strict] [
				all [
					depth?
					last = index? list
					change back tail depth on
				]
				item: join dir item
				if match? [system/words/do [fun find/tail item path depth]]			;move index of item past path
				all [
					dir? item
					either level* [level* > length? depth][deep]
					ls/deep/level/do/filter/pass :item level* :fun :rule depth? depth path strict
					remove back tail depth
				]
			]
		]
		exit
	]

	set 'tree func [
		'dir [any-type!]
		/level
			level* [integer! none!]
		/filter
			'rule [word! block! none!]
		/skip
			'not-rule [word! block! none!]
		/help "Show available rules and exit"
	][
		dir: to-file maybe-dir :dir [tree dir]
		print undirize to-file dir
		ls/deep/strict/level/do/filter/skip :dir level* func[item depth][
			forall depth [
				prin pick either tail? next depth [
					[{└─ } {├─ }]
				][
					[{   } {│  }]
				] first depth
			]
			; print [undirize last split-path item]
			print [last split-path item]
		] :rule :not-rule
	]

] ;end object


;### tests helper functions
object [
	system/state/trace?: off

	n: newline
	sep: pad/with ";" 80 #"#"
	fill: func [value][pad/with rejoin [";## " value space] 80 #"#"]

	set 'section func [title][
		print [n sep n sep n fill uppercase title n sep n sep n]
	]

	set 'exec func [block /def /local result][
		if string? block/1 [
			print [n sep n fill block/1 n sep n]
			block: next block
		]
		print join ">> " trim/head/tail next head clear back tail mold block
		set/any 'result try block
		if value? 'result [
			all [
				not error? :result
				not empty? result: form :result
				result: head insert result "== "
			]
			unless def [prin result]
			prin n
		]
		prin n
	]

	set 'make-test-folder func [][
		if exists? %folder/.0.txt [call/wait {rm -r folder}]
		make-dir f: %folder
		write f/.0.txt ""
		write f/(%1.txt) ""
		write f/(%2.txt) "pattern to be modified"
		make-dir f: %folder/emptyfolder
		make-dir f: %folder/.subfolder0
		write f/.0.txt ""
		write f/(%1.txt) ""
		write f/(%2.txt) "pattern to be modified"
		make-dir f: %folder/subfolder1
		write f/.0.txt ""
		write f/(%1.txt) ""
		write f/(%2.txt) "pattern to be modified"
		make-dir f: %folder/subfolder2
		write f/.0.txt ""
		write f/(%1.txt) ""
		write f/(%2.txt) "pattern to be modified"
	]

] ;end object

;### run tests
make-test-folder

section {patch tests}
	exec [
		"patch %folder/2.txt with patches, error if no match"
		patch %folder/2.txt [
			[{to be } {}]
			[{ modified} { reverted}]
			[[any [to {pattern} change {pattern} {value}] to end]]
		]
	]
	exec [
		"patch %folder/2.txt with patches, error if no match"
		patch %folder/2.txt [
			[{not-found..} {return an error}]
		]
	]
	exec [
		"patch %folder/2.txt with patches, no error if no match"
		patch/quiet %folder/2.txt [
			[{not-found..} {don't complain}]
		]
	]

section {maybe tests}
	exec/def [
		"allow any value type, default to logic! off if no value"
		test: func ['value [any-type!]][maybe :value off]
	]
	exec [test]
	exec [test off]

	exec/def [
		"allow values of types word! and none!, default to logic! off if no value"
		test: func ['value [any-type!]][maybe/type :value off [word! none!] [test value]]
	]
	exec [test #123]
	exec [test word]

	exec/def [
		"allow values of types word! logic! and none!, type word! value are evaluated, default to logic! off if no value"
		test: func ['value [any-type!]][
			maybe/type :value off [word! [get value] logic! none!
		] [test value]]
	]
	exec [test #123]
	exec [test on]
	exec [test none]
	exec [word: 123 test word]

section {ls tests}
	exec [
		"list all files and folders in current dir"
		ls
	]
	exec [
		"same, alternative call"
		ls .
	]
	exec [
		"same, alternative call"
		ls %.
	]
	exec [
		"execute provided function for every files and folders in current dir"
		ls/do %. func[][print do load {1 + 1}]]
	exec [
		"list all files and folders in current dir, skip dot files"
		ls/skip %. [not dot to end]
	]
	exec [
		"same, alternative call"
		ls/skip %. dot
	]
	exec [
		"list all files, skip folders and dot files in current dir"
		ls/do/skip %. func[item][unless dir? item [print item]] dot
	]
	exec [
		"recursive listing of files and folders in current dir, skipping dot files and printing with padded depth"
		ls/deep/do/skip %. func[item depth][
			print head insert/dup last split-path item space (length? depth) - 1 * 2
		] dot
	]

section {ls + patch test}
	exec [
		"recursively patch files content and change matched file names in one shot"
		ls/deep/do/skip %folder func [item /local f][
			item: head item
			unless dir? item [
				patch/quiet item [
					[[any [to {value} change {value} {new value} (
						print rejoin [{Found "value" in %} item { and replaced with "new value"}]
					)] to end]]
				]
			]
			if find item %2.txt [
				call/wait form reduce ['mv f: copy item replace/all item %2.txt %3.txt]
				print rejoin [{Found %2.txt in file name %} f { and replaced with %} item]
			]
		] dot
	]

section {tree tests}
	;
	exec [
		"directory tree at current path"
		tree
	]
	exec [
		"same, alternative call"
		tree %.
	]
	exec [
		"directory tree at current path, skip dot files"
		tree/skip %. dot
	]
	exec [
		"directory tree for folder %folder, skip dot files"
		tree/skip %folder dot
	]
