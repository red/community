Red [
  Author: ["Greg Tewalt]
  File: %help-writer.red
  Tabs: 4
]

; #include %/<your-path/help.red       ;  to compile

usage: ["Usage:" crlf "./help-writer <function> <template>" crlf "./help-writer -a , --all <template>"]

args: system/script/args 
options: to block! trim/with args #"'" 
valid-funcs: [action! function! native! op! routine!]

function-name-rule: ["action!" | "function!" | "native!" | "op!" | "routine!"]
options-rule: ["-a" | "--all"]
template-rule: ["asciidoc" | "markdown" | "latex"] 

; templates
asciidoc: ["===" space n crlf "[source, red]" crlf "----" crlf help-string (to-word :n) crlf "----"]
latex:    ["\documentclass {article} \title{" n "} \begin{document}" help-string (to-word :n) "\end{document}"]
markdown: ["###" space n crlf "```red" crlf help-string (to-word :n) crlf "```"]

gather-function-names: func [txt] [
    ws: charset reduce [space tab cr lf]
    fnames: copy []
    rule: [s: collect into fnames any [ahead [any ws "=>" e:] b: keep (copy/part s b) :e | ws s: | skip]] ; rule by toomasv
    parse txt rule  ; grab all function names and put them in fnames block to loop through
]

get-help-text: func [w][help-string :w]

write-help: func [template [block!] /local ext][
    ext: case [
        template = asciidoc ['.adoc]
        template = markdown ['.md]
        template = latex    ['.tex]
    ]
    foreach n fnames [
        either system/platform = 'Windows [  ; windows doesn't like * or ? in names
            f: copy n
            parse f [some [change #"?" "_q" | change #"*" "_asx" | skip]] 
            either f = "is" [continue][write to-file rejoin [dest f ext] rejoin compose template] ; can't write 'is'
        ][
            either n = "is" [continue][write to-file rejoin [dest n ext] rejoin compose template]
        ]
    ]
]

do-all: does [
    foreach f valid-funcs [
        dest: make-dir to-file rejoin [f '- options/2] 
        gather-function-names get-help-text :f 
        write-help reduce options/2
    ]
]

do-one: does [
    dest: make-dir to-file rejoin [options/1 '- options/2] 
    gather-function-names get-help-text :options/1
    write-help reduce options/2
]

main: does [
    unless parse args [any options-rule skip some template-rule (do-all) 
                | some function-name-rule skip some template-rule (do-one)][print usage]
]

main