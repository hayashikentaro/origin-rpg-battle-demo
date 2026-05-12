# SaGa2 Remaining Decisive Frontiers Report

## Goal

current canonical wording がかなり固まったあとで、
なお **decisive** に残っている frontier だけを整理する。

## What is no longer the main frontier

もはや主戦場ではないもの:

- 5-layer shape 自体
- layer order 自体
- `accepted` の role
- `pointerFlavor` を second-line core とみる読み
- `target` を downstream terminal とみる読み

これらは current frontier ではかなり安定している。

## Remaining decisive frontiers

### 1. `branchVariant 0/1` numeric binding

最大の未確定点は依然これである。

今わかっていること:

- side semantics はかなり強い
- `pointerFlavor="shared"/"candidate"` と strong side-level correspondence がある
- raw numeric `0|1` を exact side に binding する direct evidence はまだ弱い

したがって次の decisive point は、
**`0` と `1` のどちらが shared/default side でどちらが candidate-aware side か**
を直接近く anchor する追加 evidence である。

### 2. `41E3-41E5 -> 41E6 -> 41E7-41E9` の finer timing wording

大枠の chain はかなり安定しているが、

- `41E6` をどこまで独立 stage と呼ぶか
- `41E7-41E9` の中で visibility と gate の timing をどこまで分けるか

は still-provisional である。

これは shape の問題ではなく、
**battle-side wording の精度**
の問題として残っている。

### 3. `postBranchRoute` exact micro-boundary

current best reading は

- `41E3-41E5` = retained refinement handoff edge

でかなり安定しているが、
その中でどこを exact route-core edge と呼ぶべきかはなお少し揺らぎがある。

ただしこれは field role を壊すほどではなく、
**micro-boundary の精密化**
として残っているにすぎない。

## Secondary frontiers

次点の未確定点:

- `branch` side names をさらに battle-native に寄せるか
- `pointerFlavor` の wording を “pointer/materialization” と “target-provenance” のどちらへ寄せるか
- `postBranchTargetSource` の weak marker wording をこれ以上強める必要があるか

これらは重要だが、上の 3 つほど decisive ではない。

## Current safest summary

現時点の decisive frontier は、

1. `branchVariant 0/1` numeric binding
2. temporal chain の finer timing wording
3. `postBranchRoute` micro-boundary

の 3 本にかなり絞れている。

## Practical implication

今後の解析は、

- shape を増やす
- API を組み替える
- field を追加する

方向ではなく、
**この 3 frontier を少しずつ sharpen する**
方向へ集中するのが safest である。
