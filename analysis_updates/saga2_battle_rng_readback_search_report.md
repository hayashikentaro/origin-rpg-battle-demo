# SaGa2 battle RNG readback search report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_battle_rng_byte49_gap_report.md`
- 既存 `saga2_battle_rng_45a8_report.md`

## 目的

- `4361` dispatch 先と `449A-44F3` を当たって `D849` family の readback を探す
- 現時点で除外できる線を整理する

## 結論

今回の探索では、
**`4361` dispatch 先と `449A-44F3` 側からも `D849/D949/DA49` の direct readback は取れなかった。**

少なくとも今言えるのは次の 3 点。

1. `45A8` は generic scatter writer で、byte49 consumer ではなさそう
2. `4361` は `0C:4680 + index*2` の dispatch table を引く helper だが、この table dumpからは `D849` 直読みに繋がらない
3. `449A-44F3` は別 helper ではあるものの、今回の static 追跡では `DE00` / `D849` 直結証拠は出ていない

したがって byte49 は依然として
**writeback 済みだが readback 先未発見**
のまま。

## 1. `45A8`

`45A8` は:

```text
INC L
INC L
LD A,(DE)
LD (HL+),A
INC DE
LD A,(DE)
LD (HL),A
INC H
DEC C
JR NZ,$45A8
RET
```

なので、`DE -> HL` の 2 byte pair scatter writer とみるのが自然。
固定の `D849` / `D84D` を読む形ではない。

## 2. `4361`

既報どおり `4361` は:

- `0C:4680 + index*2` から 2 byte を引く
- `017D -> 04BF` へ渡す

helper に見える。

今回 `0C:4680` 実データも確認したが、
dispatch target table であって
`D849` 直参照を示す材料にはならなかった。

なので `4361` は battle state/descriptor dispatch helper のまま据え置くのが安全。

## 3. `449A-44F3`

`449A-44F3` は別 helper であり、
record expansion 風には見える。

ただし今回の static 追跡では:

- `DE00`
- `DE10`
- `D849/D949/DA49`

のいずれにも direct に届く証拠は取れていない。

このため byte49 consumer 候補としては
まだ弱い。

## 4. 今の最小整理

現時点の `D849` family は:

- source: `44F4 -> DE10 -> 4053 -> D849/D949/DA49`
- sink: 未確定

一方 `D84D` family は:

- `actors` loop 内で active read が見えている

ので、両者は引き続き分けて扱うのが安全。

## 次の一手

1. `4053` の後で `D849` family を比較・分岐に使う箇所を広域検索する
2. `44F4` caller が回している `D` page (`D0xx` か `D5xx` か) を確定する
3. `DE0B` / `DE12..` 側から逆に後続 consumer を探す
