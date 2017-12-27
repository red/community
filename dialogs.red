Red [
    Title: "Alert, confirm, prompt dialogs with examples."
    Date: "27-Dec-2017"
    Author: "Mike Parr"
    File: %dialogs.red
    needs 'view
]

;-- alert-popup displays a message, and waits for the user to click 'OK',
;--     or close the window.  It is modal due to the use of /all, and [modal]

alert-popup: function [;-- based on work by Nodrygo
    "Displays an alert message"
    msg [string!] "Message to display"
] [
    view/flags [
        msg-text: text msg center return
        OK-btn: button "OK" [unview] ;-- or user can close window with 'X'
        do [;-- centre the button
            OK-btn/offset/x: msg-text/offset/x + (msg-text/size/x / 2) - (OK-btn/size/x / 2)]
    ] [modal popup]
]


alert-popup-demo: func [] [
    alert-popup "Hello"
    print "Alert closed."
    alert-popup "and----------------- a long goodbye -----------------!"
    print "Alert closed."
]


;-- prompt-popup displays a message, a field for single-line input, and 
;--    'OK' and 'Cancel' buttons. Normally it returns a string, though it returns
;--    false if 'VCancel' is clicked, and none if the window is closed with 'X'.

prompt-popup: function [
    "Prompts for a string.  Has OK/Cancel"
    msg [string!] "Message to display"
] [
    result: none ;-- in case user closes window with 'X'
    view/flags [
        msg-text: text msg center return
        in-field: field return
        yes-btn: button "OK" [result: in-field/text unview]
        no-btn: button "Cancel" [result: false unview]
        do [
            gap: 10 ;--between OK and Cancel
            ;-- enlarge text if small
            unless msg-text/size/x > (yes-btn/size/x + no-btn/size/x + gap) [
                msg-text/size/x: yes-btn/size/x + no-btn/size/x + gap
            ]

            win-centre: (2 * msg-text/offset/x + msg-text/size/x) / 2 ;-- centre buttons
            yes-btn/offset/x: win-centre - yes-btn/size/x - (gap / 2)
            no-btn/offset/x: win-centre + (gap / 2)
            in-field/size/x: 150
            in-field/offset/x: win-centre - (in-field/size/x / 2)
        ]
    ] [modal popup]
    result
]


prompt-popup-demo: func [] [
    print ["prompt-popup returns: " prompt-popup "Enter your name:"]
    print ["prompt-popup returns: " prompt-popup "Enter your --------long --------name:"]
]


;-- confirm-popup displays a message, and  'OK' and 'Cancel' buttons. Normally it returns a
;--    string, though it returns false if 'Cancel' is clicked, and none if the window 
;--    is closed with 'X'.

confirm-popup: function [
    "Displays message. Clicking OK: returns true, Cancel: false, window-close: none"
    msg [string!] "Message to display"
] [
    result: none ;-- in case user closes window with 'X'
    view/flags [
        msg-text: text msg center return
        yes-btn: button "OK" [result: true unview]
        no-btn: button "Cancel" [result: false unview]
        do [
            gap: 10 ;--between OK and Cancel
            ;-- enlarge text if small
            unless msg-text/size/x > (yes-btn/size/x + no-btn/size/x + gap) [
                msg-text/size/x: yes-btn/size/x + no-btn/size/x + gap
            ]

            win-centre: (2 * msg-text/offset/x + msg-text/size/x) / 2 ;-- centre buttons
            yes-btn/offset/x: win-centre - yes-btn/size/x - (gap / 2)
            no-btn/offset/x: win-centre + (gap / 2)
        ]
    ]
    [modal popup]
    result
]


confirm-popup-demo: func [] [
    print ["Confirm-popup returns: " confirm-popup "Do it?"]
    print ["Confirm-popup returns: " confirm-popup
        "A longggggg question ------------------------!"]
]


view [
    button "confirm" [confirm-popup-demo]
    button "alert" [alert-popup-demo]
    button "prompt" [prompt-popup-demo]
]
