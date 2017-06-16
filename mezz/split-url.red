Red [
	Title: 		"URL splitter"
	Purpose:	{split a url into its compoments} 
	Author:		"Rudolf W. MEIJER"
	File:		%split-url.red
	Version:	0.2.0
	Date:		"02-Apr-2017" 
	Rights:		"Copyright (c) Rudolf W. MEIJER" 
	History:	[
					[0.0.0 "25-Mar-2017" {Start of project}]
					[0.1.0 "01-Apr-2017" {First working version}]
					[0.2.0 "02-Apr-2017" {Put set-words of parse rules inside context}]
				]
	Notes:		{See https://en.wikipedia.org/wiki/Uniform_Resource_Identifier}
	Language:	'English
	Tabs:		4
]

;---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|-

context [
	res: none
	s: f: e: none
	letter: charset [#"a" - #"z"]
	digit:  charset [#"0" - #"9"]
	ascii:  charset [#" " - #"~"]
	host-chars: exclude ascii charset ":/"
	path-chars: exclude ascii charset "?#"
	query-chars: exclude ascii charset "#"
	url-rule: [
		scheme-rule #":"
		opt [
			"//" opt user-passwd-rule
			host-rule opt [#":" port-rule]
		]
		opt #"/" path-rule
		opt [#"?" query-rule]
		opt [#"#" fragment-rule]
	]
	scheme-rule: [
		s: letter some [letter | digit | #"+" | #"." | #"-"] e:
		(res/scheme: copy/part s e)
	]
	user-passwd-rule: [
		s: to #":" f: thru #"@" e:
		(
			res/user: copy/part s f
			res/password: copy/part next f back e
		)
	]
	host-rule: [
		s: some host-chars e:
		(res/host: copy/part s e)
	]
	port-rule: [
		s: some digit e:
		(res/port: to integer! copy/part s e)
	]
	path-rule: [
		s: any path-chars e:
		(
			res/path: either res/scheme = "mailto"
			[
				attempt [to email! copy/part s e]
			][
				attempt [to file! copy/part s e]
			]
		)
	]
	query-rule: [
		s: some query-chars e:
		(res/query: copy/part s e)
	]
	fragment-rule: [
		s: some ascii e:
		(res/fragment: copy/part s e)
	]

	init: does [
		res: make object! [
			scheme:			; string!
			user:			; string!
			password:		; string!
			host:			; string!
			port:			; number!
			path:			; file!
			query:			; string!
			fragment:		; string!
				none
		]
	]
	set 'split-url func [
		"split a url value into its components, returns an object or none"
		url [url!]
	][
		all [
			init
			parse to string! url url-rule
			res
		]
	]
]