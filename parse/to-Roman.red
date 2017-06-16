Red [
    Purpose: "Arabic to Roman numbers converter"
    Date: "06-Oct-2016"
    Tabs: 4
]

table: [1000 M 900 CM 500 D 400 CD 100 C 90 XC 50 L 40 XL 10 X 9 IX 5 V 4 IV 1 I]

to-Roman: function [n [integer!]] reduce [
    'case collect [
        foreach [a r] table [
            keep compose/deep [n >= (a) [append copy (form r) any [to-Roman n - (a) copy ""]]]
        ]	
    ]
]

print to-Roman 40
print to-Roman 33
print to-Roman 1888
print to-Roman 2016
