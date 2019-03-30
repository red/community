Red [
	Author: "Toomas Vooglaid"
	Started: 2-10-2017
	Uses: {%matrix.red (https://github.com/toomasv/matrix)}
	Last-update: 6-10-2017
]
do https://tinyurl.com/ybvyqxcu
cx: context [
	m: size: cell: _Img: _Cyc: cyc: steps: real-size: data: i: sz: go: _Size: _Cell: d: o: offset: none
	history: copy []
	next-cycle: func [/local d s commands][
		d: m/data
		;probe reduce [cyc steps]
		if (cyc > steps) [steps: steps + 1 append history d]
		commands: copy []
		forall d [
			append commands compose/deep [
				fill-pen (either 1 = d/1 [black][white]) 
				box (s: cell * to-pair reduce [(m/get-col-idx index? d) - 1 (m/get-row-idx index? d) - 1]) (s + cell)
			]
		]
		commands
	]
	draw-next: func [][
		_Img/draw: do [
			matrix [game-of-life m] 
			_Cyc/data: cyc: cyc + 1 
			next-cycle
		]
	]
	initialize: func [siz cel][
		size: siz
		cell: cel
		go: no
		data: make block! sz: size/x * size/y
		loop sz [insert data 0]
		matrix compose/deep [m: (reverse size)[(data)]]
		real-size: size * cell + 1x1
		cyc: steps: 0
	]
	re-draw: func [win /local elem dim][
		initialize size cell 
		_Img/size: real-size 
		_Img/draw: next-cycle
		_Nav/offset: 10x10 + to-pair reduce [0 _Img/offset/y + _Img/size/y] 
		dim: 0x0
		foreach elem win/pane [
			dim/x: max dim/x elem/size/x
			dim/y: dim/y + elem/size/y + 10
		]
		win/size: dim + 20x10
	]
	;set 'gol func [siz cel /local d o offset][
		initialize 20x20 15x15 ;siz cel
		view compose/deep [
			style btn: button 22x22
			panel [
				text "Initial:" 35
				drop-down data [
					"Blank" "Random"; "Glider" "Space-ship"
				] select 1 on-change [
					switch face/selected [
						1 [
							cyc: steps: 0 
							remove/part history length? history 
							repeat i sz [poke data i 0] m/data: data
						]
						2 [cyc: 1 repeat i sz [poke data i random/only [0 1]] m/data: data]
						3 []
						4 []
					]
					_Img/draw: next-cycle
				]
				button "Reset" [
					_Cyc/data: cyc: 1 steps: 0 
					remove/part at history add length? m/data 1 subtract length? history length? m/data
				] return
				text "Grid:" 25 _Size: field 40 data (size) 
				on-change [size: _Size/data] 
				on-enter [size: _Size/data re-draw face/parent/parent]
				text "Cell:" 25 _Cell: field 40 data (cell) 
				on-change [cell: _Cell/data] 
				on-enter [cell: _Cell/data re-draw face/parent/parent]
				text "Rate:" 25 _Rate: field 40 data 5 [_Img/rate: face/data]
			] return 
			_Img: image (real-size) loose draw [(next-cycle)] on-time [
				if go [draw-next]
			] rate 5 all-over on-down [
				offset: event/offset / cell + 1x1 
				d: pick m/data o: offset/y - 1 * m/cols + offset/x
				poke m/data o pick [1 0] d + 1 
				_Img/draw: next-cycle
			]
			return
			_Nav: panel [
				btn "|<" [
					unless empty? history [
						m/data: copy/part head history m/rows * m/cols 
						_Cyc/data: cyc: 1 
						_Img/draw: next-cycle
					]
				]
				btn "-"  [
					unless cyc = 0 [_Cyc/data: cyc: cyc - 1] 
					m/data: copy/part at history add cyc * length? m/data 1 length? m/data
					_Img/draw: next-cycle
				]
				btn "||" [probe reduce ["stop" cyc steps] go: no]
				_Cyc: field 35 data (cyc) 
				btn ">"  [go: yes]
				btn "+"  [draw-next]
				btn ">|" [
					if or~ greater? steps cyc + 1 equal? steps cyc + 1 [
						_Cyc/data: cyc: steps
						m/data: copy/part at history add cyc - 1 * length? m/data 1 length? m/data
						_Img/draw: next-cycle
					]
				]
			]
		]
	;]
]
