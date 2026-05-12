# SaGa2 Remaining Elements Execution-Order Report

## Summary
- 残り要素は多く見えても、現在の解析線に沿って並べると **`019E -> 6157 -> battle action resolve`** の 1 本へかなり収束する。
- したがって次に調査すべきものは「未解明項目の一覧」ではなく、**どの順で埋めると移植 API が最短で固まるか** である。
- 現時点の実行順は、`019E` local state、`6157` handoff、action resolve consumer、RNG slot 消費順、action descriptor struct の順に置くのが最も効率的である。

## 1. Immediate Layer: `019E`

最優先:

1. `019E` immediate target の形  
   `outcome byte` / `marker + outcome byte` / short tuple
2. その state が player-scoped local success state として十分か  
3. `611C` 成功境界との整合

ここが取れると、
`rng` 側は単なる乱数供給でなく
**battle local outcome を確定する commit point**
として contract を持てる。

## 2. Bridge Layer: `6157` Entry

次点:

1. `6157` entry が受け取る最小入力
2. `C709` current player との束縛
3. local success state -> battle apply handoff の入口条件

ここで必要なのは `D400/D500` 全体ではなく、
**1 player 分の local state を battle 側へ渡す narrow bridge**
である。

## 3. Consumer Layer: Action Resolve

その次:

1. handoff された local success state をどの battle routine が最初に読むか
2. それが命中/対象/ダメージ/行動順のどの判定へ入るか
3. battle 本線のどこで RNG slot 消費と結びつくか

ここが見えると、
`battle.resolveAction(input)` の中間 state がかなり固まる。

## 4. RNG Layer

consumer が見えたあとで必要になるもの:

1. battle 本線で使う RNG slot の最終確定
2. slot ごとの消費順
3. 命中・ダメージ・対象選択・行動順への対応付け

これは `019E` local state と battle consumer の線が見えてからのほうが、
false positive を減らしやすい。

## 5. Descriptor Layer

最後に、Godot/TypeScript API を完全に固めるために必要なのが:

- `C1A5-C1AC`
- `D?43-46`

周辺の action descriptor 最終 struct。

ただしこれは `019E -> consumer` が見えたあとでも遅くない。

## Implication
- 残り要素の実行順は `019E` -> `6157 entry` -> battle consumer -> RNG slot order -> descriptor struct
- いま最も効く次の一手は、`6157` entry が local success state をどう前提にしているかをさらに詰めること
