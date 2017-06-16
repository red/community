Red [
	title:		"A SBN Language Compiler"
	date:		{7-May-2017}
	file:		%sbn.red
	author: 	"Wayne Cui"
	version:	0.0.1
	info:		"inspired by https://github.com/kosamari/sbn"
  Tabs: 4
]

lexer: function [code][    
	tokens: split code charset [" ^/"]
	token-blk: copy []
	foreach token tokens [
		either error? result: try [ to integer! token ] [
			repend/only token-blk ['type 'word 'value to lit-word! token]
		][
			repend/only token-blk ['type 'number 'value to integer! token]
		]
	]
	token-blk
]

parser: function [tokens][
	AST: [type "Drawing" body []]

	while [(length? tokens) > 0] [
		current-token: take tokens
		if current-token/type = 'word [
			switch current-token/value [
				'Paper [
					expression: [
						'type 'CallExpression
						'name 'Paper
						'arguments []
					]
					argument: take tokens
					;probe argument/type
					either argument/type = 'number [
						repend/only expression/arguments ['type 'NumberLiteral 'value argument/value]
						repend/only AST/body expression
					][
						throw "Paper command must be followed by a number."
					]
					
				]
				'Pen [
					expression: [
						'type 'CallExpression
						'name 'Pen
						'arguments []
					]
					argument: take tokens
					either argument/type = 'number [
						repend/only expression/arguments ['type 'NumberLiteral 'value argument/value]
						repend/only AST/body expression
					][
						throw "Pen command must be followed by a number."
					]
				]
				'Line [
					expression: [
						'type 'CallExpression
						'name 'Line
						'arguments (copy [])
					]

					arguments: copy []
					loop 4 [
						argument: take tokens
						either argument/type = 'number [
							repend/only arguments ['type 'NumberLiteral 'value argument/value]
							expression/arguments: arguments
						][
							throw "Line command must be followed by a number."
						]
					]
					;probe expression
					repend/only AST/body expression
				]
			]
		]
	]

	AST
]

transformer: function[ ast ][
	svg-ast: [
		'tag 'svg
		'attr [
			'width 100
			'height 100
			'viewBox [0 0 100 100]
			'xmlns http://www.w3.org/2000/svg
			'version "1.1"
		]
		'body []
	]

	pen-color: 100 
	
	while [(length? ast/body) > 0][
		node: take ast/body
		switch node/name [
			Paper [
				paper-color: 100 - node/arguments/1/value
				repend/only svg-ast/body [
					'tag 'rect
					'attr reduce [
						'x 0
						'y 0
						'width 100
						'height 100
						'fill rejoin ["rgb(" paper-color "%," paper-color "%," paper-color "%)"]
					]
				]
			]
			Pen [
				pen-color: 100 - node/arguments/1/value
			]
			Line [
				repend/only svg-ast/body [
					'tag 'line
					'attr reduce[
						'x1 node/arguments/1/value
						'y1 node/arguments/2/value
						'x2 node/arguments/3/value
						'y2 node/arguments/4/value
						'stroke-linecap 'round
						'stroke (rejoin ["rgb(" pen-color "%," pen-color "%," pen-color "%)"])
					]
				]
			]
		]
	]

	svg-ast
]

generator: function[svg-ast][
	svg-attr: create-attr-string svg-ast/attr
	;probe svg-attr
	elements: copy []
	foreach node svg-ast/body [
		append elements rejoin ["<" node/tag space create-attr-string node/attr {></} node/tag {>} lf]
	]
	return rejoin [{<svg } svg-attr {>^/} elements {^/</svg>}]
]

create-attr-string: function[attr][
	result: copy []
	foreach [key value] attr [
		append result rejoin [key {="} value {"} space ]
	]
	return result
]

compile: function[code][
	write %simple.svg generator transformer parser lexer code
]

code: {Paper 100 Pen 0
Line 50 15 85 80
Line 85 80 15 80
Line 15 80 50 15} 

;probe generator transformer parser lexer code
compile code
