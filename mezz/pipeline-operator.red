Red [
   Tabs: 4
]

; パイプ演算子の実体となる関数
pipe: func[ x f [function! action! native!] ] [ f x ]

; 「|>」にpipe関数を演算子としてセット
|>: make op! :pipe

; 使い方はこんな感じになる。残念ながら呼び出される側の関数には「:」を付けないと呼べない・・・
[1 2 3] |> :rejoin
; returns "123"
"ABC" |> :lowercase
; returns "abc"
