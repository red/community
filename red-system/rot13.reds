Red/System [
	Title:   "ROT-13 in Red/System : executable with only 872 bytes"
	Author:  "Guaracy"
	File: 	 %rot13.reds
	Copyright:  "2021 Guaracy Monteiro"
	License: "BSD-3 - https://github.com/red/red/blob/master/BSD-3-License.txt"
    Pourpouse: "Apply rot-13 cypher on a text entry (Linux only)."
    Compile: "red-toolchain -c --no-runtime rot13.reds"
    Usage: {
        echo "some text" | rot13
        rot13 < file.txt
        rot13 < filein.txt > fileout.txt
        rot13 [[text Enter] ...] Ctrl+C
    }
]

#define STDIN      0
#define STDOUT     1

; https://linuxhint.com/list_of_linux_syscalls/
#define SYS-write  4
#define SYS-read   3
#define SYS-exit   1

#define null-byte  #"^@"
#define rot 13

#syscall [
   write: SYS-write [
       fd      [integer!]
       buffer  [c-string!]
       count   [integer!]
       return: [integer!]
   ]
   read: SYS-read [
       fd      [integer!]
       buffer  [c-string!]
       count   [integer!]
       return: [integer!]
   ]
   quit: SYS-exit [
       status  [integer!]
   ]
]

c: #" "
ix: 0  ; upper = 65, lower = 97, 0 otherwise
s: " " ; for sys_read

case?: func [c [byte!] return: [integer!]][
    if all[c >= #"A" c <= #"Z"][return 65]
    if all[c >= #"a" c <= #"z"][return 97]
    return 0
]

print: func [msg [c-string!] return: [integer!]][
    write STDOUT msg 1
]

getch: func[return: [byte!] /local l][
    l: read STDIN s 1
    if l < 1 [return null-byte]
    return s/1
]

while [true] [
    c: getch
    if c = null-byte [break]
    ix: case? c
    if ix > 0 [
        c: c - ix + rot
        if c >= as byte! 26 [
            c: c - 26
        ]
        c: c + ix
    ]
    s/1: c
    print s
]
quit 0
