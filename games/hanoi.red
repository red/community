Red [
	Author: "Toomas Vooglaid"
	Date: 2017-10-24
	Needs: View
]
context [
	system/view/auto-sync?: dragable?: off-the-post?: no
	offset: pos-x: post: current-post: post1: post2: post3: disc: disc1: disc2: disc3: disc4: steps: thickness: none
	post1-narrow: charset [ 48 -  52]
	post2-narrow: charset [148 - 152]
	post3-narrow: charset [248 - 252]
	post1-wide:   charset [  0 - 100]
	post2-wide:   charset [101 - 200]
	post3-wide:   charset [201 - 300]
	posts: union union post1-wide post2-wide post3-wide
	target: none
	detach: func [f][remove select f/data 'data]
	attach: func [face post][
		unless empty? post/data [
			if post/data/1/size/x < face/size/x [attach face current-post return none]
		] 
		y: either empty? post/data [184][(pick select first post/data 'offset 2) - 16]
		face/offset: to-pair reduce [post/offset/x + 5 - (face/size/x / 2) y] 
		do [show face]
		insert post/data face
		face/data: post
	]
	let-go: func [face][
		case [
			find post1-wide pos-x [attach face post1]
			find post2-wide pos-x [attach face post2]
			find post3-wide pos-x [attach face post3]
		]
	]
	constrain: func [face post][
		face/offset/x: post/offset/x + 5 - (face/size/x / 2)
		unless empty? post/data [face/offset/y: min face/offset/y post/data/1/offset/y - 16] 
		off-the-post?: no
	]
	view [
		size 300x240
		style post: box 10x100 data copy [] 
			draw [fill-pen linear 50.50.50 150.150.150 0.2 50.50.50 0.6 black 1.0 box 0x0 10x100]
			on-down [
				either target = face [
					face/draw: [fill-pen linear 50.50.50 150.150.150 0.2 50.50.50 0.6 black 1.0 box 0x0 10x100]
					target: none
				][
					if target [
						target/draw: [fill-pen linear 50.50.50 150.150.150 0.2 50.50.50 0.6 black 1.0 box 0x0 10x100]
						show target
					]
					face/draw: [fill-pen linear brick 250.100.100 0.2 brick 0.6 100.0.0 1.0 box 0x0 10x100]
					target: face
				]
				show face
			] 
		style disc: box loose
			on-drag-start [
				current-post: face/data 
				offset: face/offset
				if face = first current-post/data [
					dragable?: yes
					detach face
					pos-x: face/offset/x + (face/size/x / 2)
				]
			]
			on-drag [
				either dragable? [
					face/offset: max 0x0 min (300x200 - face/size) face/offset
					either (face/offset/y + 16) < 100 [
						pos-x: face/offset/x + (face/size/x / 2)
						off-the-post?: yes
					][
						if off-the-post? [pos-x: face/offset/x + (face/size/x / 2)]
						case [
							find post1-narrow pos-x [constrain face post1]
							find post2-narrow pos-x [constrain face post2]
							find post3-narrow pos-x [constrain face post3]
							true [face/offset/y: 84]
						]
					]
				][face/offset: offset]
			] 
			on-drop [
				if dragable? [
					let-go face
					dragable?: no
					steps/data: steps/data + 1
					show steps
				]
			] 
		button "Restore" [
			foreach disc reduce [disc1 disc2 disc3 disc4 disc5][detach disc]
			foreach disc reduce [disc1 disc2 disc3 disc4 disc5][attach disc post1]
			steps/data: 0 show steps
		]
		button "Random" [
			foreach disc reduce [disc1 disc2 disc3 disc4 disc5][detach disc]
			foreach disc reduce [disc1 disc2 disc3 disc4 disc5][attach disc get pick [post1 post2 post3] random 3]
			steps/data: 0 show steps
		]
		at 200x10 text "Steps:" 40x24 center 
		at 245x10 steps: field 25x24 data 0 disabled
		at 0x40 panel [
			at   0x0   image 300x200 
			
			at  45x100 post1: post 
			at 145x100 post2: post 
			at 245x100 post3: post 
			
			at  3x184  disc1: disc 94x16  data post1 draw [
					fill-pen linear brown 250.200.100 0.2 brown 0.6 80.10.0 1.0 
					box 0x0 94x16
			]		
			at 11x168  disc2: disc 78x16  data post1 draw [
					fill-pen linear brown 250.200.100 0.2 brown 0.6 80.10.0 1.0 
					box 0x0 78x16
			]
			at 19x152  disc3: disc 62x16  data post1 draw [
					fill-pen linear brown 250.200.100 0.2 brown 0.6 80.10.0 1.0 
					box 0x0 62x16
			]
			at 27x136  disc4: disc 46x16  data post1 draw [
					fill-pen linear brown 250.200.100 0.2 brown 0.6 80.10.0 1.0 
					box 0x0 46x16
			]
			at 35x120  disc5: disc 30x16  data post1 draw [
					fill-pen linear brown 250.200.100 0.2 brown 0.6 80.10.0 1.0 
					box 0x0 30x16
			]

			do [post1/data: reduce [disc5 disc4 disc3 disc2 disc1]]
		]
	]
]
