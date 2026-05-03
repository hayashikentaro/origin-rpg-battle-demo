# SaGa2 battle RNG DE00 consumers report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_battle_rng_44f4_report.md`
- 既存 `saga2_battle_rng_bc_page_report.md`

## 目的

- `44F4` が組む `DE00` scratch の消費先を追う
- scratch から battle controller work へ戻る経路を確定する

## 結論

`DE00` scratch の全消費先はまだ未確定だが、
少なくとも 1 本かなり強い線が取れた。

`4044: CALL $44F4` の直後、

```text
4053: LD A,($DE10)
4056: LD (BC),A
```

があり、しかも `BC` は `D849 -> D949 -> DA49` を順に指す。

したがって
**`44F4` が作る `DE10` は scratch 内の一時値ではなく、
battle controller work (`D8xx/D9xx/DAxx`) へ書き戻される正式な抽出値**
とみてよい。

## 1. caller 断片

`0D:4040-4059`:

```text
4040: LD A,(DE)
4041: OR A
4042: JR Z,$4047
4044: CALL $44F4
4047: POP DE
4048: INC D
4049: POP BC
404A: PUSH BC
404B: LD A,$03
404D: SUB B
404E: ADD A,$49
4050: LD C,A
4051: LD B,$D8
4053: LD A,($DE10)
4056: LD (BC),A
4057: POP BC
4058: DEC B
4059: JR NZ,$403C
```

ここから読めること:

- `44F4` を呼ぶ前に caller は `D` page 群を回している
- `44F4` return 後に `DE10` を読む
- 読んだ値を `D849/D949/DA49` family に保存する

なので、`DE10` は scratch record の中でも
**controller work へ昇格する byte**
とみなせる。

## 2. `DE10` の作り方

`44F4` 内では:

```text
4526: LD A,(HL+)
4527: PUSH AF
4528: AND $F0
452A: SWAP A
452C: LD E,$0B
452E: LD (DE),A
...
4544: LD A,H? ; restore/popped source byte
4546: AND $0F
4548: LD ($DE10),A
```

このため `DE10` は、
ある source byte の
**low nibble 抽出値**
として作られている可能性が高い。

同じ byte の high nibble は `DE0B` に入っているので、

- `DE0B` = high nibble 側 category/id
- `DE10` = low nibble 側 sub-id/count/index

のような paired decomposition を疑うのが自然。

## 3. `DE00` scratch の性質

今回の結果で、
`DE00` は単なる局所テンポラリより一段強く、

- 複数 source table から正規化され
- 少なくとも一部 (`DE10`) は caller に利用され
- battle controller work へ再書き戻しされる

という
**staging record**
だと整理できる。

つまり `44F4` は
「ただ表を引く helper」ではなく、
後段ロジックが読むための scratch struct を作る段である。

## 4. まだ取れていない部分

まだ未確定なのは次の点。

- `DE0B`, `DE0C`, `DE12..`, `DE2D` の個別消費先
- `4053` 以外に `DE00` を読む battle caller
- `DE10` の low nibble が何の意味を持つか
- `D849/D949/DA49` family における byte49 の正式意味

## 5. 現時点の battle/RNG 整理

- `44F4` は `D?xx` page と ROM table から `DE00` scratch を組む
- `DE10` はその scratch の実利用 byte
- `DE10` は `D849/D949/DA49` family へ反映される
- `443B-4499` は別系統で `D8xx-D Axx` control page の pointer record を組む

したがって battle control helper 群は、

1. source page -> `DE00` scratch
2. scratch -> `D8xx-D Axx` controller work
3. controller work -> RNG pointer build

という多段 staging をしている可能性が高い。

## 次の一手

1. `D849/D949/DA49` を読む後続 caller を追って byte49 の意味を確定する
2. `DE0B` / `DE12..` を読む battle code を逆引きする
3. `449A-44F3` が `DE00` family を触るかどうかを確認する
