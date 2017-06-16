Red [
   Tabs: 4
]

;short version utils:
join: func[a b][append copy a b]
delete: func[f][call/wait rejoin ["rm '" f "'"]]

#include %console.red

system/options/home: join to-file get-env "HOME" %/

history: object [
	f: join make-dir join system/options/home %.red/ %.red_history
	length: 500
	start: does [
		if exists? f [
			system/console/history: load f
		]
		exit
	]
	set 'quit does [
		save f reverse copy/part union
			reverse system/console/history
			reverse any [
				all[
					exists? f
					load f
				]
				[]
			]
			length
		quit-return 0
	]
	set 'q :quit
	clear: does [
		delete f
		system/words/clear system/console/history
		exit
	]
]
history/length: 1000
history/start

;put your init stuff in ~/.red/user.red
either exists? f: join system/options/home %.red/user.red [
	do f
][
	write f {Red []^/^/;put your init stuff here^/}
]

system/console/launch
