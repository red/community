Red [
	 Needs: 'View
   Tabs: 4
]

; #include %support/call.red

print "clr - define object"

celer: object [

; --- support funcs ----------------------------------------------------------

src-to-exe: func [src] [replace copy src ".red" ".exe"]
in-home: func [file] [append copy celer-home file]

; --- paths (have to be defined on global lever or compiler would complain) --

celer-home: system/options/path
red-path: in-home %red-master/

; --- layouts ----------------------------------------------------------------

drop-source: none
drop-output: none
slider-verbosity: none
text-verbosity: none
drop-target: none
check-debug: none
check-library: none
check-no-runtime: none

intro-win: layout [
	title "Celer installation"
	text 300x60 {It seems that you don’t have Red && Rebol installed.
Celer can install required files for you (recommended),
or you can choose Red directory with Rebol 2 executable in it.}
	return
	button "Install" [install unview]
	button "Locate" [red-path: request-dir unview]
]

main-win: layout [
	title "Red Compiler"

	style path-button: button 24x24 "..."

	panel [
		text "Source:"
		path-button [
			drop-source/text: form request-file
			insert drop-source/data reduce [drop-source/text none]
			drop-source/data: unique drop-source/data
			drop-output/text: src-to-exe drop-source/text
		]
		drop-source: drop-down 300 
		;	[print mold face/data print face/selected]
			on-select [drop-output/text: src-to-exe drop-source/text]
		return
		text "Output:"
		path-button [
			drop-output/text: append form request-dir last split src-to-exe drop-source/text #"/"
		]
		drop-output: field 300
		return
		text "Verbosity:"
		slider-verbosity: slider 250 [
			level: to integer! face/data * 11
			text-verbosity/text: form reduce case [
				zero? level [["Quiet"]]
				level <= 3 	[[level "- Red only"]] 
				true 		[[level "- Red && Red/System"]]
			]
		]
		text-verbosity: text 120 "Quiet"
		return
		text "Target:"
		drop-target: drop-list data [
			"MSDOS" "Windows"
			"Linux" "Linux-ARM" "RPi"
			"Darwin"
			"Syllable"
			"FreeBSD"
			"Android" "Android-x86"
		]
	]
	panel [
		below
		check-debug: check "Debug mode"
		check-no-runtime: check "No runtime"
		check-library: check "Shared library"
	]
	return
	button "Compile" [compile]
	status: base 20x20 orange
]

; --- functions --------------------------------------------------------------

print "clr - define functions"

init: has [data] [
	print "clr - add custom actor"
	; add custom actor
	main-win/actors: object [
		on-close: func [
			face 	[object!]
			event 	[event!]
		] [
			save-prefs
		]
	]
	; view install splash, when needed
	print "clr - view install splash"
	unless exists? red-path [view intro-win]
	; load settings
	print "clr - load settings"
	either exists? %celer.data [
		print "clr - settings exist"
		data: load %celer.data
		print mold data
		red-path: select data 'red-path
		print "clr - set gui values"
		unless empty? drop-source/data: unique data/history [
			print "clr - set source"
			drop-source/text: first drop-source/data
			print "clr - set output"
			drop-output/text: src-to-exe drop-source/text
		]
		print "clr - set selected"
		drop-target/selected: data/target
	] [
		print "clr - settings don’t exist"
		red-path: in-home %red-master/
		drop-source/data: copy []
		drop-target/selected: 2
	]
	print "clr - init ends"
]

install: does [
	write/binary in-home %unzip.exe read/binary http://www.stahlworks.com/dev/unzip.exe
	write/binary in-home %red.zip read/binary https://github.com/red/red/archive/master.zip
	call {unzip red.zip}
	write/binary in-home %red-master/rebol.exe read/binary http://www.rebol.com/downloads/v278/rebol-view-278-3-1.exe
	red-path: in-home %red-master/
]

compile: does [
	if drop-source/text [
		status/color: red
	;	loop 25 [do-events/no-wait wait .05]
		system/options/path: red-path
		write %temp.r mold rebol-code
		call/wait {rebol -s "temp.r"}
		status/color: green
	]
]

save-prefs: does [
	save in-home %celer.data reduce [
		'history drop-source/data
		'target drop-target/selected
		'red-path red-path
	]
]

rebol-code: has [t] [
	probe compose [
Rebol []

do/args %red.r (
	form reduce [
		either zero? t: to integer! slider-verbosity/data * 11 [""] [append copy "-v " t]
		either check-debug/data ["-d"] [""]
		either check-library/data ["-dlib"] [""]
		either check-no-runtime/data ["-r"] [""]
		"-t" pick drop-target/data drop-target/selected 
		"-o" drop-output/text 
		drop-source/text
	]
)
	]
]

]

; --- main -------------------------------------------------------------------

print "clr - run celer"

celer/init
print "clr - view"
view/no-wait celer/main-win
print "clr - do-events"
do-events
