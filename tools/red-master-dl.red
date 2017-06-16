Red [ 
	Title:		"Download new Red master zip program"
	filename:	%red-master-dl.red
	author:		"Arnold van Hofwegen"
	date:		"11-May-2016"
	Needs:		'View
  Tabs:     4
]

github-page: copy ""

read-github: func [
	"Read the github page"
][
	github-page: read http://www.github.com/red/red
]

get-commit-number: func [
	"Get commit number"
	return: [string!]
	/local
		number-of-commits [string!]
][
	get-commits-rule: [ thru {<li class="commits">} thru {<span class="num text-emphasized">} copy commits to "</span>" ]
	parse github-page get-commits-rule

	; Extract the number now
	digit: charset "0123456789"
	extract-rule: [collect [ any [ keep digit | skip to digit ]]]

	extracted-digits: parse commits extract-rule

	number-of-commits: make string! length? extracted-digits
	foreach ch extracted-digits [append number-of-commits ch]

	number-of-commits
]

get-commit-date: func [
	"Get the date"
	return: [string!]
	/local
		commit-date [string!]
][
	get-date-rule: [ thru {<span itemprop="dateModified"><relative-time datetime="} copy commit-date to "T"]
	parse github-page get-date-rule

	trim/with commit-date #"-"
]

zip-file-name: %red-master.zip

construct-file-name: func [
	"Make filename"
][
	zip-file-name: copy %red-master-
	append zip-file-name get-commit-number
	append zip-file-name "-"
	append zip-file-name get-commit-date
	append zip-file-name ".zip"
	zip-file-name
]

read-write-zip: func [
	"Read the zip and write it to the destination"
][
	write/binary zip-file-name read/binary http://github.com/red/red/archive/master.zip
]

view [
	filename: text 200 "red-master.zip" 
	return
	button "Set commit and date mark" [
		read-github
		filename/text: copy "" 
		append filename/text construct-file-name
	]
	return
	button "Download and Save zip" [ 
		read-write-zip
	]
	return
	button "Quit" [unview]
]
