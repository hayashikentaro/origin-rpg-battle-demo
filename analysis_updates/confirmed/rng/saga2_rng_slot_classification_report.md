# SaGa2 RNG slot classification report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_043e_callsite_report.md`
- 既存 action / damage reports

## 目的

- `00:043E` の seed slot 番号ごとの用途差を caller 文脈から分類する
- `rng` モジュール分離時に、slot を単一用途とみなせるかを確認する

## 結論

現時点では、`043E` の slot は少なくとも **用途別に複数クラスタへ分かれている** とみるのが自然。

特に:

- `00 / 01 / 09 / 0A / 20` は bank0 action / field / script 寄り caller で見える
- `07 / 08` は bank `0D:4440` の battle/item 系 caller で見える
- `0C / 0D` は bank0 `3DB9 / 3DCB` で 0..1 二値を 2 本引く pair として見える

したがって、TypeScript 側でも最初から `next(slot, lower, upper)` のように
**slot を明示入力として残す設計** が安全。

## 1. 既知 caller の整理

### bank 00 action / field / script 寄り

- `289C`: `A=$09`, `DE=$FF00`
- `2AFF`: `A=$0A`, `DE=$FF00`
- `324D`: `A=$01`, `DE=$0300`
- `3256`: `A=$00`, `DE=$0F00`
- `326F`: `A=$20`, `DE=$0300`

これらは既報どおり:

- raw 8bit
- 0..3
- 0..15

のような小範囲乱数を作っており、action word consumer / tile action / field logic 側の
軽量分岐に使われている可能性が高い。

### bank 0D battle / item 系

- `4467`: `A=$07`
- `4472`: `A=$08`

この 2 本は `battle_ram_routine` / `data_items` クラスタ内にあり、
事前に `DE` をレコード由来値から組み立てたうえで `CALL $016B` している。

### bank 00 action consumer pair

- `3DB9`: `A=$0C`, `DE=$0100`
- `3DCB`: `A=$0D`, `DE=$0100`

ここは同一ルーチン内で slot `0C` と `0D` を連続使用している。

## 2. `3DB9 / 3DCB`

bytes:

```text
3DB3: PUSH HL
3DB4: PUSH AF
3DB5: LD A,$0C
3DB7: LD DE,$0100
3DBA: CALL $016B
3DBD: LD E,A
3DBE: POP AF
3DBF: DEC A
3DC0: JR Z,$3DC4
3DC2: CPL
3DC3: INC A
3DC4: LD C,A
3DC5: LD A,(HL)
3DC6: PUSH AF
3DC7: LD A,$0D
3DC9: LD DE,$0100
3DCC: CALL $016B
3DCF: LD E,A
3DD0: POP AF
3DD1: DEC A
3DD2: JR Z,$3DD6
3DD4: CPL
3DD5: INC A
3DD6: LD B,A
```

ここで `DE=$0100` は

- lower = `00`
- upper = `01`

なので、各 call は **0 か 1** を返すと読むのが自然。

call 後に元の `A` を `DEC / CPL / INC` しているので、
「既存値の符号または向きに応じて、0/1 を加減算側へ振る」構造に見える。

少なくともこの 2 本は

- 大きな raw RNG
- battle damage 本体

よりも、**座標 / 揺れ / 位置ずらし系の二値乱数** として読むほうが自然。

## 3. `4467 / 4472`

`battle_ram_routine` / `data_items` cluster より:

```text
4445: LD D,H
4446: LD E,L
...
4450: SRL D / RR E  (3回)
...
4463: LD E,$00
4465: LD A,$07
4467: CALL $016B
446A: LD C,A
...
446D: LD D,E
446E: LD E,$00
4470: LD A,$08
4472: CALL $016B
4475: LD E,A
```

ここでは `DE` を item/record 読み出し値から作り、
その上限に対して slot `07` と `08` で 2 本の範囲乱数を引いているように見える。

少なくとも

- slot `07/08` は raw 0..255 専用ではない
- battle / item effect 側の magnitude 生成に使われている可能性が高い

と整理できる。

## 4. slot ごとの暫定分類

### field / action / script 側で強いもの

- slot `00`: 0..15 nibble 値
- slot `01`: 0..3 の 1/4 分岐
- slot `09`: raw 0..255
- slot `0A`: raw 0..255
- slot `20`: 0..3 小範囲分岐

### battle / item 側で強いもの

- slot `07`: record 由来上限での範囲乱数
- slot `08`: record 由来上限での範囲乱数

### pair で使われる二値乱数

- slot `0C`: 0..1
- slot `0D`: 0..1

## 5. 現時点の整理

### 確度が高いこと

- `043E` の slot は単一用途ではなさそう
- `0C/0D` は同一 caller で binary pair として使われる
- `07/08` は battle/item 側 caller で range RNG として使われる
- `00/01/09/0A/20` は bank0 action / field / script 寄り文脈で見える

### まだ未確定なこと

- 各 slot が globally 固定用途か、単に caller ごとに慣例があるだけか
- battle damage 本体がどの slot を使うか
- `07/08` と `0C/0D` が演出用か、命中/散布にも使われるか

## 次の一手

1. `5741: CALL $016B` を追加確認して battle 本体の slot を拾う
2. `4467/4472` 後段の計算を追って、乱数が何の値に混ざるかを見る
3. slot 番号ごとの消費順を battle / field / script で別表化する
