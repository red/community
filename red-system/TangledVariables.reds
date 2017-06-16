Red/System [
   Tabs: 4
]

vector3!: alias struct! [
    x [float!]
    y [float!]
    z [float!]
]

vec3-Mfloat: func [
    vec [vector3!]
    f [float!]
    return: [vector3!]
    /local a
    ][  
        print["Vec x:" vec/x " y " vec/y " z " vec/z lf]    
        a: declare vector3!
        a/x: vec/x * f
        a/y: vec/y * f
        a/z: vec/z * f
        print["A x:" a/x " y " a/y " z " a/z lf lf]   
        a
]

direction: declare vector3!
origin: declare vector3!
testv: declare vector3!
testu: declare vector3!

testf: 0.5

direction/x: -2.0 direction/y: -1.0 direction/z: -1.0
origin/x: 5.0 origin/y: 10.0 origin/z: 20.0

probe testu
probe testv

testu: vec3-Mfloat direction testf
testv: vec3-Mfloat origin testf

print ["testV x " testv/x " y " testv/y " z " testv/z  lf]
print ["testU x " testu/x " y " testu/y " z " testu/z  lf lf]

probe testu
probe testv
