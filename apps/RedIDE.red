Red [
   needs 'view
   tabs: 4
]

tab1: [
    below group-box "Actions" [
        origin 20x40                     ;;interpret the contents of the area
        button 75x25 "Interpret" on-click [do face/parent/parent/pane/2/text ]                                                                    ;;doesn't seem to work
        button 75x25 "Compile" on-click [
            print "Compiling"
            write to file! t/data/(t/selected) face/parent/parent/pane/2/text

            either  face/parent/pane/3/data/(face/parent/pane/3/selected) = "Dev" [ ;;use drop down to determine if dev or release
                print "Dev code path" 
                call append "red.exe -c " t/data/(t/selected) 
            ][                                           
                print "release";;here we append .red file extension the the name of the tab
                 call append "red.exe -r " t/data/(t/selected) ;;call via commandline
            ]
        ] 
        drop-down data: ["Dev" "Release"]
    ]
    area 400x400 
]

tabcount: 1

editor: layout compose/deep/only [
    below
    ;;this works but I would prefer to do it via the window
    ;;button "New File" [ append t/data "tab" append t/pane make face! [type: 'panel pane: layout/only tab1] ]
    t: tab-panel 550x550 ["tab 1" (tab1) ]

]

editor/menu: [
    "File"  [
        "New"    newfile
        "Rename" newName
        "Load"   loadfile
        "Save"   savefile
        "SaveAs" savefile2
        "Quit"   leave
    ]
] 

editor/actors: make object! [
    on-menu: func [face [object!] event [event!]][
        switch event/picked [
            ;; Copy contents of "tab 1" into every new tab that we create via new file
            newfile   [
                append t/data "tab"
                append t/pane make face! [type: 'panel pane: layout/only tab1]
            ]
            newName   [
                do view [ ;;purpose here is to rename the tab itself
                    name: field button "Done" [
                        t/data/(t/selected): name/text 
                        unview
                    ]
                ]
            ]
            ;;we are updating the value of the active tab's area to contain the contents of the file
            loadfile  [
                print "loading"
                read file: request-file
                ; 'name now has filename
                replace t/pane/(t/selected)/2/text file
            ] ; 
            savefile  [
                print "saving" ;;write the contents of the area to a file using the name of the tab as the filename
                write to file! t/data/(t/selected)  t/pane/(t/selected)/pane/2/text
            ]
            savefile2 [
                print "saving"
                write request-file/save t/pane/(t/selected)/pane/2/text
            ]

            leave [unview]
        ]
    ]
]

view editor

