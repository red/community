Red [
   Tabs: 4
]

#system [
	chr: 1
	handle: 0
	KEYDOWN: 0
	KEYUP: 2
	minus-one: -1
	pointer-to-minus-one: :minus-one
	rs-phrase: ""
	very-crude-wait: func [/local i j] [
		i: 1
		j: 100000
		until [									
			i: i + 1
			i > j
		]
	]
	#import [
		"User32.dll" stdcall [
			FindWindow: "FindWindowA" [
				class		[integer!]
				title		[c-string!]
				return:		[int-ptr!]
			]
			keybd_event: "keybd_event" [
				key-code 	[byte!]
				ignored-1	[byte!]
				event		[integer!]
				ignored-2	[integer!]		
			]
			SetForegroundWindow: "SetForegroundWindow" [
				win-handle	[integer!]
				return: 	[logic!]
			]
		]	
	]
]

find-window: routine [title [string!] return: [integer!]] [
	return as integer! FindWindow 0 unicode/to-utf8 title pointer-to-minus-one
]
set-foreground-window: routine [handle [integer!]] [
	SetForegroundWindow handle
]
type-phrase: routine [phrase [string!]] [
	rs-phrase: unicode/to-utf8 phrase pointer-to-minus-one
	until [
		keybd_event rs-phrase/chr #"^(00)" KEYDOWN 0
		very-crude-wait
		keybd_event rs-phrase/chr #"^(00)" KEYUP 0
		very-crude-wait
		chr: chr + 1
		chr > length? rs-phrase
	]
]

notepad: find-window "Untitled - Notepad"     
set-foreground-window notepad
type-phrase "RED IS TYPING"
