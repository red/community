; We have other reflective functions (words-of, body-of, etc.), but
; this is a little higher level, sounded fun to do, and may prove
; useful as we write more Red tools. It also shows how to make your
; own typesets and use them when parsing.

arity-of: function [
	"Returns the fixed-part arity of a function spec"
	spec [any-function! block!]
	/with refs [refinement! block!] "Count one or more refinements, and add their arity"
][
	if any-function? :spec [spec: spec-of :spec]		; extract func specs to block
	t-w: make typeset! [word! get-word! lit-word!]		; typeset for words to count
	t-x: make typeset! [refinement! set-word!]			; typeset for breakpoint, set-word is for return:
	n: 0
	; Match our word typeset until we hit a breakpoint that indicates
	; the end of the fixed arity part of the spec. 'Skip ignores the
	; type and doc string parts of the spec.
	parse spec rule: [any [t-w (n: n + 1) | t-x break | skip]]
	; Do the same thing for each refinement they want to count the
	; args for. First match thru the refinement, then start counting.
	if with [foreach ref to block! refs [parse spec [thru ref rule]]]
	n
]

print arity-of :append
print arity-of/with :append /only
print arity-of/with :append /dup
print arity-of :load
print arity-of/with :load /as

test-fn: func [a b /c d /e f g /h i j k /local x y z return: [integer!]][]

print arity-of :test-fn
print arity-of/with :test-fn /c
print arity-of/with :test-fn /e
print arity-of/with :test-fn /h
print arity-of/with :test-fn [/c /e /h]

print arity-of :arity-of
print arity-of/with :arity-of /with
