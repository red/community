Red [
   Tabs: 4
]

system/view/auto-sync?: no

grid: collect [repeat i 50 [keep/only collect [repeat j 50 [keep random true]]]]
scratchgrid: collect [repeat i 50 [keep/only collect [repeat j 50 [keep false]]]]

a: copy grid/1
b: copy grid/50
c: collect [keep/only b keep grid keep/only a]

count-neighbors: function [gridd x y][
	count: 0
	foreach [h v][
		(x - 1) (y - 1)
		(x - 1)  y
		(x - 1) (y + 1)
		 x      (y - 1)
		 x      (y + 1)
		(x + 1)  y
		(x + 1) (y - 1)
		(x + 1) (y + 1)
	][
		if gridd/(do h)/(do v) [count: count + 1]
	]
	;?? count
	count
]

iterate: function [] [
	repeat i 50 [
		ii: i + 1
		repeat j 50 [
			ncount: count-neighbors c ii j
			scratchgrid/:i/:j: make logic! any [
				all [c/:ii/:j ncount > 1 ncount < 4]
				all [not c/:ii/:j ncount = 3]
			]
		]
	]
]

refresh: function [cmds][
	clear cmds
	repeat i 50 [
		repeat j 50 [
			insert cell: tail cmds [fill-pen <color> circle <coord> 5]
			cell/2: pick [red white] scratchgrid/:i/:j
			cell/4: 10 * as-pair i j
		]
	]
]

sync-grids: [
    grid: copy scratchgrid
    
    clear scratchgrid
    scratchgrid: collect [repeat i 50 [keep/only collect [repeat j 50 [keep false]]]]
    a: copy grid/1
    b: copy grid/50
    c: collect [keep/only b keep grid keep/only a]
]

update-all: does [
	do iterate
	refresh canvas/draw 
	do sync-grids
	show canvas
]

cmds: make block! 500

view [
    title "Conway's Game of Life"
	size 530x530
	canvas: base 510x510 draw cmds rate 30
	on-time [update-all]
	do [update-all]
]

system/view/auto-sync?: yes
