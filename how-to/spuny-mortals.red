Red [
    Title:  "Example of definitional scoping"
    Date:   "20-Mar-2017"
    Author: https://github.com/9214

    File: %(s)puny-mortals.red
    Tabs: 4
]

meditate: function ['on thing] [
    print "ॐ"
    probe thing
    print [reduce thing newline]
]

contexts: reduce [
    first:  context [spoon: "there's"]
    second: context [spoon: "no"]
    third:  context [spoon: "spoon"]
]

; -- at load-time
shelf-with-spoons: [spoon spoon spoon]
probe :system/words/spoon 
comment {
    by-default all any-word! values (spoons included) are bounded to a so-called global context (system/words),
    but no value is associated with any of them, that's why our "universal" spoon is unsetted.
}

; -- at run-time
repeat i length? shelf-with-spoons [
    ; bind all words in a series to some context,
    ; note that `at <series> <index>` returns series at specified index
    bind at shelf-with-spoons i contexts/:i
    meditate on shelf-with-spoons
    comment {
        1st round: 
            spoon -> first
            spoon -> first
            spoon -> first
        2nd round:
            spoon -> first
            spoon -> second
            spoon -> second
        3rd round:
            spoon -> first
            spoon -> second
            spoon -> third
    }
]

probe :system/words/spoon
comment {
    we've rebinded every spoon to it's own context,
    hence there's still no spoon in global context!
}

spoon: "take the RED pill"
meditate on system/words/spoon
comment {
    and now we've associated our `string!` value w/ spoon entry in global context
}

meditate on shelf-with-spoons   ; seems legit! however ...

append shelf-with-spoons [comma spoon]
comment {
    let's pile up our spoons together, 
    separating "global" spoon from "local" once with a comma
}

meditate on shelf-with-spoons   ; wake up neo

; now, let us make our spoon to be just a "spoon"
set 'spoon bind 'spoon copy third contexts
meditate on spoon

meditate on shelf-with-spoons
comment {
    however, last entry changed too!
    how can we avoid that?
}

;  I show you how deep the rabbit (space-time worm-)hole goes
bind back tail shelf-with-spoons context take/part find load %spuny-mortals.red spoon 2

meditate on shelf-with-spoons
meditate on spoon   ; at last, there IS a spoon!

; then you'll see ...
repeat i length? shelf-with-spoons [
    cutie: split "woman in the RED dress" space
    set shelf-with-spoons/:i cutie/:i
]

meditate on shelf-with-spoons        ; ... that it is not the spoon that bends (binds)...
meditate on spoon                    ; ... it is only yourself
