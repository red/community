Red [
        Title:   "Basic demo ide editor"
        Purpose: "demo for basic Red ide editor"
        File:    %basicide.red
        Tabs:    4
        Author: "NoDrygo"
        License: {
            Distributed under the Boost Software License, Version 1.0.
            See https://github.com/red/red/blob/master/BSL-License.txt
        }
        Needs:   'view
]

comment {
**WARNING**Red is far to be finished and still lack a lot of things so this code is a lot prematured and only for fun
 NEED TO BE COMPILED TO WORK (add CALL RED)
 !!!! this is a BIG HACK you are warned !!!!!!
  Adapt include below to your path
}

#include %../../red/system/library/call/call.red 


alertPOPUP: function [
    "Displays an alert message"
    msg [string!]  "Message to display"
][
    view [
        t: text msg center return
        b: button "ok" [ unview]
        do [b/offset/x: t/offset/x + (t/size/x - b/size/x / 2)]
    ][modal popup]
]

;-- in prevision for future extension 
current: context [
    bgcolor: black
    fgcolor: white
    red: system/options/boot
    curdirfiles: []
    modified: false
]

mainmenu: [
            "File" [
                    "New file"     fnew
                    "Load file"     fopen
                    "Save file"     fsave
                    "-------"
                    "Exit"        exit
                   ]
            "Font" [
                    "Size"     
                         [
                         "8" setfont8
                         "10" setfont10
                         "12" setfont12
                         "14" setfont14
                         ]
                    "FgColor"     
                         [
                         "Black" setfg-black
                         "White" setfg-white
                         "Blue" setfg-blue
                         "Red" setfg-red
                         ]                         
                    "BgColor"     
                         [
                         "Black" setbg-black
                         "White" setbg-white
                         "Water" setbg-water
                         "Cyan" setbg-cyan
                         "Forest" setbg-forest
                         "Olive" setbg-olive
                         ]
                   ]
            "Tool" [ 
                     "Run"  runsrc
                     "Run external"  runextsrc
                     "Compile" compilesrc
                   ]
            "Help" [ "About"  about]
]

dirfiles: function [
    "select files and return list (poor copy from original file)"
    'dir [any-type!] "Folder to list"
][
    res: copy ""
    unless value? 'dir [dir: %.]
    unless find [file! word! path!] type?/word :dir [
        cause-error 'script 'expect-arg ['list-dir type? :dir 'dir]
    ]
    list: read normalize-dir dir
    reslist: copy []
    foreach  d list[
        unless parse d [thru "exe"][
                                 append reslist form d
                                   ]
    ]
    reslist
]

loadfile: function [][ clear codesrc/text 
                       fn: to file! curfilename/text
                       if  exists? fn [codesrc/text: load mold (read fn)]]

setcurdirfiles: does [current/curdirfiles: dirfiles ]

execall: function[cmd][
    "call red as external program red.exe must be in path"
    either current/modified [
                              alertPOPUP "Please save file before" 
                            ][
                              print "START CALL red"
                              attempt [call/wait/console append (copy cmd) (copy current/filename)]
                            ]
]

execint: does [ 
      lcode: copy "" 
      append lcode  codesrc/text
      attempt [do lcode ]
] 

mainwin: layout [
    style: txtinfo:  text bold font-size 12 font-color blue
    txtinfo "Current Dir.:"  curdir: txtinfo "" 300  return 
    curfilename: field "defaulteditest.red" 200  return
    panel [flist: text-list on-change [curfilename/text: current/curdirfiles/(face/selected) loadfile]]
    panel [
          codesrc: area 600x400 bold italic white font-color black font-size 14  on-change[ current/modified: true]
          ]
    do [curdir/text: copy form get-current-dir setcurdirfiles  flist/data: current/curdirfiles ]
]

mainwin/menu: mainmenu

mainwin/actors: context [
                on-menu: func [face [object!] event [event!]][
                print event/picked 
                        switch event/picked [
                           'fnew   [clear codesrc/text ] 
                           'fopen  [loadfile] 
                           'fsave  [save %xx.rr codesrc/text] 
                           'setfont8  [codesrc/font/size: 8 ]
                           'setfont10 [codesrc/font/size: 10 ]
                           'setfont12 [codesrc/font/size: 12 ]
                           'setfont14 [codesrc/font/size: 14 ]
                           'setfg-black [codesrc/font/color: black ]
                           'setfg-white [codesrc/font/color: white ]
                           'setfg-red [codesrc/font/color: red ]
                           'setfg-blue [codesrc/font/color: blue ]
                           'setbg-black [codesrc/color: black ]
                           'setbg-white [codesrc/color: white ]
                           'setbg-cyan [codesrc/color: cyan ]
                           'setbg-forest [codesrc/color: forest ]
                           'setbg-olive [codesrc/color: olive ]
                           'setbg-water [codesrc/color: water ]
                           'runsrc [execint]
                           'runextsrc  [execall "red " ]
                           'compilesrc [execall "red -c -t windows " alertPOPUP "finished"]
                           'about [alertPOPUP "RED DEMO: SIMPLE EDITOR "]
                           'exit [quit]
                         ]
                ]
                on-resize:   func  [face [object!] event [event!]] [ codesrc/size: mainwin/size - 20x10 ]
                ;--on-close:    func  [face [object!] event [event!]] [quit]
                on-key-down: func [face [object!] event [event!]]['done]
           ]

view/no-wait/flags mainwin [resize]