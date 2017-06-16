Red[
    Title: "Raytracer"
    Needs: 'View
    Notes: "Simple raytracer based on 'Ray Tracing in One Weekend' by Peter Shirley"
    Tabs: 4
]

vec3_dot: function [a[vector!] b[vector!]] [
    reduce (a/1 * b/1) + (a/2 * b/2) + (a/3 * b/3)
]

vec3_cross: function [a[vector!] b[vector!]] [
    reduce [ (a/2 * b/3) - (a/3 * b/2)
    negate (a/1 * b/3) - (a/3 * b/1)
    (a/1 * b/2) - (a/2 * b/1)]
]

vec3_len: function [a [vector!]][
    square-root (a/1 * a/1) + (a/2 * a/2) + (a/3 * a/3)
]

vec3_squaredlen: function [a[vector!]][
    (a/1 * a/1) + (a/2 * a/2) + (a/3 * a/3)
]

vec3_unitvector: function [a[vector!]][
    a / vec3_len a
]

ray: make object![
    origin: vector!
    direction: vector!
    point_at_parameter: function [t[float!]][
    origin + (direction * t)
    ]
]

color: function [r [object!]][
    t: hit_sphere make vector![float! 32 [0.0 0.0 -1.0]] 0.5 r
    if t > 0.0 [
        n: vec3_unitvector((r/point_at_parameter t) - (make vector![float! 32 [0.0 0.0 -1.0]]) )
        return (n + 1) * 0.5
    ]
    unit_direction: vec3_unitvector r/direction
    t: 0.5 * unit_direction/2 + 1.0
    (make vector! [float! 32 [ 1.0 1.0 1.0]]) * (1.0 - t)  + ((make vector! [float! 32[0.5 0.7 1.0]]) * t)
]

hit_sphere: function [center[vector!] radius[float!] ray[object!]][
    oc: ray/origin - center
    a: vec3_dot r/direction r/direction
    b: 2.0 * vec3_dot oc ray/direction
    c: vec3_dot oc oc - (radius ** 2)
    discriminant: b ** 2 - (4 * a * c)
    either discriminant < 0 [return -1.0] [return (negate b - square-root discriminant) / (2.0 * a)] 
]

nx: 400
ny: 200

lower_left_corner: make vector! [float! 32 [-2.0 -1.0 -1.0]]
vertical: make vector! [float! 32 [0.0 2.0 0.0]]
origin: make vector! [float! 32 [0.0 0.0 0.0]]
horizontal: make vector! [float! 32 [4.0 0.0 0.0]]

img: []

repeat jj ny [
    j: ny - jj + 1
    repeat i nx [
        u: to float! i / to float! nx
        v: to float! j / to float! ny
        r: copy ray 
        r/origin: copy origin r/direction: copy lower_left_corner + ((copy horizontal) * u) + ((copy vertical) * v)
        col: color copy r
        ir: to integer! 255.99 * col/1
        ig: to integer! 255.99 * col/2
        ib: to integer! 255.99 * col/3
        append img make tuple! reduce [ir ig ib 0]
    ]

]

pic: make image! make pair! reduce[nx ny]
repeat i length? pic [pic/:i: img/:i]


view [size 420x220
    img: image pic
    ]


