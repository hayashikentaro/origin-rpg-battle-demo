# SaGa2 01E3 wrapper report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_actors_loop_report.md`
- 既存 `saga2_battle_state_helpers_report.md`
- 既存 `saga2_opcode_pass5_report.md`

## 目的

- `CALL $01E3` の実体を確定する
- `actors` queue から見える battle action resolve の境界を一段切る

## 結論

`01E3` は独自ロジックを持つ helper ではなく、
**`JP $18CE` -> `CALL $04BF` の thin wrapper**
だった。

実体は:

```text
01E3: JP $18CE

18CE: CALL $04BF
18D1: 03 5D 0F   ; inline operand
18D4: RET
```

したがって `01E3` は、
`actors` loop の中で何かを計算しているのではなく、
**固定 descriptor / script-like object `0F:5D03` を起動する wrapper**
とみるのが自然。

これは `435A` や `4361` と同じく、
少なくとも現時点では RNG 本体ではない。

## 1. `01D4-01E3` の並び

bank0 の jump table 断片:

```text
01D4: JP $18C0
01D7: JP $18AB
01DA: JP $18B2
01DD: JP $18B9
01E0: JP $18C7
01E3: JP $18CE
```

各 target の実体:

```text
18AB: CALL $04BF ; 15 50 01 ; RET
18B2: CALL $04BF ; 18 50 01 ; RET
18B9: CALL $04BF ; 1B 50 01 ; RET
18C0: CALL $04BF ; 00 5D 0F ; RET
18C7: CALL $04BF ; 00 50 0D ; RET
18CE: CALL $04BF ; 03 5D 0F ; RET
```

つまり `01D4-01E3` は揃って、
**固定 inline operand を持つ `04BF` wrapper 群**
として読める。

## 2. `01E3` の局所契約

実バイト:

```text
18CE: CD BF 04    CALL $04BF
18D1: 03 5D 0F    inline operand
18D4: C9          RET
```

ここから読み取れること:

- `01E3` 自体はレジスタ加工をしない
- 引数は callsite からではなく code stream 側の inline 3 byte
- `04BF` の返り値や副作用だけを利用する

既報 `saga2_opcode_pass5_report.md` の整理に従えば、
`04BF` は script stream ではなく
**handler code 側の inline 3 byte を読む helper**
として扱うのが安全。

なので `01E3` は
「battle queue から特定の battle descriptor を起動する固定 wrapper」
くらいに置くのが現時点では自然。

## 3. `actors` loop での意味

`saga2_actors_loop_report.md` で見えていた箇所:

```text
41F1: CALL $01E3
41F4: LD HL,$D001
41F7: LD B,$05
41F9: CALL $435A
...
422C: CALL $4361
422F: CALL $01E3
4232: LD HL,$D001
4235: LD B,$05
4237: CALL $435A
```

この並びから言える大事な点は、
`01E3` が queue entry ごとの通常攻撃本体ではなく、
**phase transition 前後で呼ばれる固定 dispatch hook**
だということ。

特に:

- `01E3` の前後で `435A` 集計が走る
- 直前に `A=$06 ; CALL $4361` がある箇所もある

ので、
`01E3` は action damage/hit 計算より
**battle state `06` 近辺の演出 / setup / descriptor 起動**
に近い可能性が高い。

## 4. RNG 探索への意味

これでさらに明確になったのは、
`actors` loop 近傍で見える

- `4361`
- `435A`
- `01E3`

はいずれも
**battle controller / phase / dispatch 側**
であって、
`043E` 系の core RNG helper とは別責務だということ。

したがって次の探索は、
`01E3` 自体を深掘りするより
**`437E` と `4579` の先にある実 action branch**
へ寄せるほうが効率がよい。

## 現時点の整理

### 確度が高いこと

- `01E3` は `JP $18CE` の thin wrapper
- `18CE` は `CALL $04BF ; 03 5D 0F ; RET`
- `01D4-01E3` は固定 inline operand つき `04BF` wrapper 群
- `01E3` は battle queue 中の固定 dispatch hook 候補

### まだ未確定なこと

- `0F:5D03` が指す descriptor/script の具体的意味
- `04BF` の battle 文脈での戻り値 / 副作用
- `01E3` の後段でどの RAM/state が変化するか

## 次の一手

1. `437E` の入出力契約を queue 文脈で切る
2. `4579` を action resolve branch selector として読み直す
3. `437E/4579` 以降で `016B -> 043E` が現れるかを優先探索する
