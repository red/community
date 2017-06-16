Red [
    Purpose: "Arabic <-> Roman numbers converter"
    Author: "Didier Cadieu"
    Date: "07-Oct-2016"
    Tabs: 4
]

; Lookup tables for conversion
table-r2a: reverse copy table-a2r: [1000 "M" 900 "CM" 500 "D" 400 "CD" 100 "C" 90 "XC" 50 "L" 40 "XL" 10 "X" 9 "IX" 5 "V" 4 "IV" 1 "I"]

roman-to-arabic: func [r [string!] /local a b e] [
	a: 0
	parse r [any [b: ["I" ["V" | "X" | none] | "X" ["L" | "C" | none] | "C" ["D" | "M" | none] | "V" | "L" | "D" | "M"] e: (a: a + select table-r2a copy/part b e)]]
	a
]

arabic-to-roman: func [a [integer!] /local r n l t] [
	r: copy ""
	t: table-a2r
	while [a > 0] [
		while [a >= t/1] [a: a - t/1  append r t/2]
		t: at t 3
        ]
        r
]

; tests
print arabic-to-roman 1
print arabic-to-roman 2
print arabic-to-roman 4
print arabic-to-roman 5
print arabic-to-roman 9
print arabic-to-roman 40
print arabic-to-roman 33
print arabic-to-roman 1888
print arabic-to-roman 2016

print roman-to-arabic "I"
print roman-to-arabic "II"
print roman-to-arabic "IV"
print roman-to-arabic "V"
print roman-to-arabic "IX"
print roman-to-arabic "XL"
print roman-to-arabic "XXXIII"
print roman-to-arabic "MDCCCLXXXVIII"
print roman-to-arabic "MMXVI"

; check for difference in conversion (does not prove they are correct, but almost, symetric ;-)
repeat n 4000 [t: arabic-to-roman n if n <> roman-to-arabic t [print [n " a2r=" t "<> r2a=" roman-to-arabic t]]]

