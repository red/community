Red [
   Tabs: 4
]

; A number of languages have `take-while/drop-while` funcs. This is just to show how you
; can build them in Red.

; This model can be applied to any function that has a `/part` refinement, or extended in
; any number of ways. We don't yet have a standard `apply` or `refine` function in Red.
; Once we do, a more general HOF version could take the action as an arg, as well as the
; test to apply.

; Should this return the position, like FIND, rather than an integer?
; No match would then mean a NONE result. REMOVE/TAKE/COPY with /PART
; then means using INDEX?.
find-while: function [
	"Find leading items that match test; return last found index; zero if no matches."
	series	[series!] "(modified)"
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
][
	n: 0
	repeat i length? series [
		either test pick series i [n: n + 1][break]
	]
	n
]


copy-while: function [
	"Copies and returns items from series head that match test, until one fails"
	series	[series!]
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
][
	copy/part series find-while series :test
]
e.g. [
	b: [1 2 3 4 5 6]
	copy-while b func [v][v <= 3]
]

keep-while: function [
	"Keeps items from series head that match test, until one fails; returns series"
	series	[series!] "(modified)"
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
][
	head clear at series 1 + find-while series :test
]
e.g. [
	b: [1 2 3 4 5 6]
	keep-while b func [v][v <= 3]
	?? b
	b: [1 2 3 4 5 6]
	keep-while b func [v][v <= 1]
	?? b
	b: [1 2 3 4 5 6]
	keep-while b func [v][v <= 0]
	?? b
	b: []
	keep-while b func [v][v <= 3]
	?? b
	b: [1 2 3 4 5 6]
	keep-while b func [v][v <= 5]
	?? b
	b: [1 2 3 4 5 6]
	keep-while b func [v][v <= 9]
	?? b
]

remove-while: function [
	"Removes items from series head that match test, until one fails; returns series"
	series	[series!] "(modified)"
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
][
	remove/part series find-while series :test
]

e.g. [
	b: [1 2 3 4 5 6]
	remove-while b func [v][v <= 3]
	?? b
	b: [1 2 3 4 5 6]
	remove-while b func [v][v <= 1]
	?? b
	b: [1 2 3 4 5 6]
	remove-while b func [v][v <= 0]
	?? b
	b: []
	remove-while b func [v][v <= 3]
	?? b
	b: [1 2 3 4 5 6]
	remove-while b func [v][v <= 5]
	?? b
	b: [1 2 3 4 5 6]
	remove-while b func [v][v <= 9]
	?? b
]

take-while: function [
	"Takes and returns items from series head that match test, until one fails"
	series	[series!] "(modified)"
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
][
	take/part series find-while series :test
]
e.g. [
	b: [1 2 3 4 5 6]
	take-while b func [v][v <= 3]
	?? b
	b: [1 2 3 4 5 6]
	take-while b func [v][v <= 1]
	?? b
	b: [1 2 3 4 5 6]
	take-while b func [v][v <= 0]
	?? b
	b: []
	take-while b func [v][v <= 3]
	?? b
	b: [1 2 3 4 5 6]
	take-while b func [v][v <= 5]
	?? b
	b: [1 2 3 4 5 6]
	take-while b func [v][v <= 9]
	?? b
]
