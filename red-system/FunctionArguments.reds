Red/System [
   Tabs: 4
]

vector3!: alias struct! [
    x [float!]
    y [float!]
    z [float!]
]

vec3-add: func [
    a[vector3!]
    b[vector3!]
    return: [vector3!]
    /local c
    ][
        print["ADD-A x " a/x " y " a/y " z " a/z lf]
        print["ADD-B x " b/x " y " b/y " z " b/z lf]
        c: declare vector3!
        c/x: a/x + b/x 
        c/y: a/y + b/y
        c/z: a/z + b/z
        print["ADD-C x " c/x " y " c/y " z " c/z lf lf]
        c
]

vec3-Mfloat: func [
    vec [vector3!]
    f [float!]
    return: [vector3!]
    /local a
    ][      
        a: declare vector3!
        a/x: vec/x * f
        a/y: vec/y * f
        a/z: vec/z * f
        return a
]

vec3-len: func [
    a [vector3!]
    return: [float!]
    ][
        sqrt ((a/x * a/x) + (a/y * a/y) + (a/z * a/z))
]

vec3-Dfloat: func [
    vec [vector3!]
    f [float!]
    return: [vector3!]
    /local a vx vy vz
    ][
        a: declare vector3!
        vx: vec/x vy: vec/y vz: vec/z
        a/x: vx / f a/y: vy / f a/z: vz / f
        a  
]

vec3-unitvector: func [
    a[vector3!]
    return: [vector3!]
    ][
        vec3-Dfloat a (vec3-len a)
]

ray!: alias struct! [
    origin [vector3!]
    direction [vector3!]
]

color: func[
    r [ray!]
    return: [vector3!]
    /local unit-dir t v1 v2 v3 v4 
    ][
        v1: declare vector3! 
        v2: declare vector3! 
        v3: declare vector3! 
        v4: declare vector3! 
        v1/x: 1.0 v1/y: 1.0 v1/z: 1.0 
        v2/x: 0.5 v2/y: 0.7 v2/z: 1.0
        unit-dir: declare vector3!
        unit-dir: vec3-unitvector r/direction
        t: 0.5 * (unit-dir/y + 1.0)
        v3: vec3-Mfloat v2 t 
        print ["Color - v3/x: " v3/x " y " v3/y " z " v3/z lf]
        v4: vec3-Mfloat v1 (1.0 - t)
        print ["Color - v4/x: " v4/x " y " v4/y " z " v4/z lf]
        vec3-add v3 v4
]


nx: 200
ny: 100
i: 0
j: 99

r: declare ray!
col: declare vector3! 
lower_left_corner: declare vector3!
origin: declare vector3!

lower_left_corner/x: -2.0 lower_left_corner/y: -1.0 lower_left_corner/z: -1.0
origin/x: 0.0 origin/y: 0.0 origin/z: 0.0

while [j >= 0] [
    i: 0
    while [i < nx] [
        r/origin: origin 
        r/direction: lower_left_corner
        col: color r
        i: i + 1
    ]
    j: j - 1
]  
