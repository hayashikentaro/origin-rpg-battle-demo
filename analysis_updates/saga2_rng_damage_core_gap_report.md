# SaGa2 RNG damage core gap report

## 対象

- `reports/saga2_damage_formula_pass21_report.md`
- `reports/saga2_damage_upstream_pass22_report.md`
- `reports/saga2_damage_upstream_pass23_report.md`
- `reports/saga2_damage_upstream_block_call_targets_pass23.csv`
- 既存 `saga2_rng_slot07_08_offset_report.md`
- 既存 `saga2_particle_state_machine_report.md`

## 目的

- 最初の移植目的に対して、battle core RNG の未確定点をはっきり切り出す
- 既存 damage pass 群のどこまでに `016B -> 043E` が見えていないかを確認する

## 結論

現時点の既存 damage 主線候補では、
**`CALL $016B` / `JP $043E` は未検出**。

具体的には:

- pass21 の final damage writeback 候補
- pass22 の direct caller 逆引き
- pass23 の expanded block call target

のいずれにも `016B/043E` は出ていない。

したがって今わかっている slot 群のうち

- slot `33` は particle/effect 側
- slot `07/08` は 16bit offset 生成側

と整理できる一方で、
**battle core damage / hit 本体が使う RNG slot はまだ別系統にある**
とみるのが最も安全。

## 1. pass21 の意味

`saga2_damage_formula_pass21_report.md` の現状整理:

```text
- unique subtract candidate funcs: 20
- subtract -> writeback -> 下限/死亡判定 の出口候補は強い
- ただし upstream amount 生成は未確定
```

つまり pass21 は
**最終 HP 書き戻し側の出口を押さえた段階** であり、
この時点では RNG helper 到達性まではまだ見えていない。

## 2. pass22 の意味

`saga2_damage_upstream_pass22_report.md`:

```text
exit funcs: 20
direct caller contexts: 0
upstream clusters: 0
```

ここでは direct caller 逆引き自体が不成立だった。

よって `016B` が出ないのは
「RNG を使っていない」と言い切る根拠ではなく、
**関数入口の取り方が damage 主線に合っていなかった**
ことを意味する。

## 3. pass23 の意味

pass23 では store 起点の block expansion に切り替えた。

`saga2_damage_upstream_pass23_report.md`:

```text
expanded blocks: 20
call targets in blocks: 35
role counts:
- helper+arith: 23
- helper+arith+banked_data: 12
```

この方法で広げた call target 一覧
`saga2_damage_upstream_block_call_targets_pass23.csv`
を見ても、
**target `016B` / `043E` は 1 件も出ていない**。

## 4. 何が言えるか

ここから安全に言えるのは次の 3 点。

1. 現在の static damage candidate chain だけでは core RNG slot に届いていない
2. 先に見つかった slot `07/08/33` をそのまま damage core とみなすのは危険
3. battle core RNG は、現 pass21-23 がまだ拾えていない別 block / 別 bank / 別入口にある可能性が高い

## 5. 既知 slot との関係

### slot `33`

既報どおり:

- `0D:5741`
- `A=$33`
- `DE=$1300`
- `0..19`

で、`C850/C8A0/C940/C994` を使う particle system に接続する。

したがって core damage ではない。

### slot `07/08`

既報どおり:

- `0D:4440`
- 上位 byte / 下位 byte を別々に生成
- 合成後 2 の補数化して `HL` から差し引く

ので、pointer / position / scatter offset 側として読むほうが自然。

したがって、これも final damage amount 直結とは見なしにくい。

## 6. 最初の目的に対する意味

最初の目的は

- `battle`
- `growth`
- `transform`
- `rng`

を TypeScript で分離し、
Godot 側を front に寄せることだった。

この目的に対して今いちばん詰まっているのは、
**battle core が RNG をどう消費するかの接続点** である。

逆に言えば、
ここを解ければ `battle` と `rng` の境界がかなり固まる。

## 7. 現時点の整理

### 確度が高いこと

- pass21-23 の既存 damage 主線候補には `016B/043E` が出ていない
- slot `33` は particle/effect 側
- slot `07/08` は 16bit offset 生成側
- core damage / hit 用 RNG slot はまだ別にある可能性が高い

### まだ未確定なこと

- 命中判定がどの block / bank で行われるか
- final damage amount に乱数が混ざる位置
- action order / hit / damage / drop の slot 分離

## 次の一手

1. pass21-23 の store 起点ではなく、通常攻撃 command の entry 側から block をたどる
2. `016B` callsite の全体一覧を bank 別に出して、battle command 近傍だけ再分類する
3. 命中・対象選択・ダメージ分散を別々に探す前提へ切り替える
