Red [
    Title: "Conway's Game of Life"
    Needs: 'View
    Tabs: 4
]

grid: collect [repeat i 10 [keep/only collect [repeat j 10 [keep random true]]]]
scratchgrid: collect [repeat i 10 [keep/only collect [repeat j 10 [keep false]]]]



a: copy grid/1
b: copy grid/10
c: collect [keep/only b keep grid keep/only a]

count-neighbors: function [
    gridd
    x
    y
    /local count
    ][
        count: 0
        if (gridd/(:x - 1)/(:y - 1) = true) [count: count + 1]
        if (gridd/(:x - 1)/:y = true) [count: count + 1]
        if (gridd/(:x - 1)/(:y + 1) = true) [count: count + 1]
        if (gridd/:x/(:y - 1) = true) [count: count + 1]
        if (gridd/:x/(:y + 1) = true) [count: count + 1]
        if (gridd/(:x + 1)/:y = true) [count: count + 1]
        if (gridd/(:x + 1)/(:y - 1) = true) [count: count + 1]
        if (gridd/(:x + 1)/(:y + 1) = true) [count: count + 1]
        ;print count

        count
    
]

iterate: func [] [
repeat i 10[
    ii: i + 1
    repeat j 10[
        ncount: count-neighbors c ii j
        if c/:ii/:j  = true [
            if ncount < 2 [scratchgrid/:i/:j: false]
            if (ncount > 1) and (ncount < 4) [scratchgrid/:i/:j: true]
            if ncount > 3 [scratchgrid/:i/:j: false]
           ; print ["live cell" ncount]
            
        ]
        if c/:ii/:j = false[
            ;print ["dead cell" ncount]
            if ncount = 3 [scratchgrid/:i/:j: true]
        ]
    ]
]
]

refresh:[
coord: 0x0
drawblock: collect [repeat i 10[
    coord/x: (i * 10)
    repeat j 10[
                coord/y: (j * 10)
                 either scratchgrid/:i/:j = false [keep reduce['fill-pen white 'circle coord 5 ]] [keep reduce['fill-pen red 'circle coord 5 ]]
                 ;print scratchgrid
                ]
        ]
]
 
]

sync-grids:[
    grid: copy scratchgrid
    
    clear scratchgrid
    scratchgrid: collect [repeat i 10 [keep/only collect [repeat j 10 [keep false]]]]
    a: copy grid/1
    b: copy grid/10
    c: collect [keep/only b keep grid keep/only a]
]


do iterate
do refresh
;print drawblock
do sync-grids


view [
        size 800x600
        canvas: base 780x580 draw drawblock rate 30 
        on-time [
           do iterate
           do refresh
           do sync-grids  
           show canvas   
        ]     
    ]

;system/view/auto-sync?: yes



