# SaGa2 BranchVariant Numeric Polarity Report

## Question

`branchVariant?: 0 | 1` を

- PTR-only candidate-family refinement bit
- `0E/0F` family difference を主軸
- blocked-ordinal shadow を副次要因

として読んできた current best reading の上で、
`0` と `1` の numeric polarity をどこまで battle-side wording で固定できるか。

## Current best reading

現時点では、numeric polarity は

- **片側 = shared/default leaning**
- **もう片側 = candidate-aware / strict leaning**

までならかなり自然に読めるが、
`0` と `1` のどちらがどちらかは **まだ保留が safest** である。

つまり current best wording では、

- `branchVariant(side A)` = shared/default-leaning candidate-family refinement
- `branchVariant(side B)` = candidate-aware/strict-leaning candidate-family refinement

までは固定してよいが、
`A=0 or 1` の numeric binding は current frontier ではまだ premature である。

## Why the side semantics are stable

既報の current best reading では、

- `0E/0F` family difference が主軸
- blocked ordinal shadow は strict/non-fast-path side へ寄る
- `pointerFlavor="shared"` / `"candidate"` の pair alignment も stable

となっている。

このため `branchVariant` の 2 side に

- shared/default leaning
- candidate-aware/strict leaning

という semantic polarity があること自体はかなり自然である。

## Why numeric binding should still wait

numeric `0/1` の exact binding を急いで固定すると、

- source-side compressed split
- second-line reopening side
- debug/UI wording

の 3 つを同時に lock してしまう。

current frontier では semantics そのものはかなり強いが、
**0 と 1 の数字を battle-side recovered naming へ直結させるだけの direct evidence**
はまだ弱い。

したがって safest stance は、

- side semantics は固定
- numeric binding は保留

である。

## Relation to `pointerFlavor`

`pointerFlavor` 側はすでに

- `"shared"` = shared/default target-provenance path
- `"candidate"` = candidate-entry target-provenance path

と value naming を固定できている。

したがって `branchVariant` も reader-side では

- shared/default leaning side
- candidate-aware/strict leaning side

として扱い、`0` / `1` の binding は second-line evidence がさらに増えるまで遅延するのが safest である。

## Current safest wording

現時点の safest wording は次のとおり。

- `branchVariant` = PTR-only candidate-family refinement bit
- side semantics:
  - shared/default-leaning side
  - candidate-aware/strict-leaning side
- numeric `0/1` binding: still provisional

## Implementation implication

実装上は、

- field shape は `0 | 1` のまま
- debug/docs では side semantics を強める
- `0 == shared` / `1 == candidate` のような固定はまだしない

という stance が最も安全である。
