# SaGa2 Pointer Visibility Pair Alignment Report

## Question

`41E7-41E9` を first effective `pointerFlavor` visibility slot と読んだとき、
そこで見えてくるものは単なる reopening 開始なのか、それとも
**`shared/candidate` pair alignment** まで含んでいるのか。

## Current best reading

現時点では、`41E7-41E9` は単なる reopening 開始より一段強く、
**`pointerFlavor` の pair alignment (`shared` / `candidate`) が first-line で visible になる slot**
とみるのが safest である。

つまり current best reading では、

- `41E6+` = reopening / consume halo の structural onset
- `41E7-41E9` = first effective `pointerFlavor` pair visibility slot
- `41EB-41EC` = deterministic consume/writeback

という wording が最も自然である。

## Why pair alignment, not just generic reopening

既報の second-line semantics では `pointerFlavor` 自体が

- `"shared"` = fast/default aligned provenance reopening
- `"candidate"` = strict-side aligned provenance reopening

という **2 値 pair** としてかなり安定している。

この前提を `41E7-41E9` へ戻すと、ここで first effective に visible になるのは
generic “reopening happened” より、
**どちらの provenance side が active になったか**
だと読むほうが current code shape に整合する。

## Relation to `branchVariant`

`branchVariant` retained refinement の strongest landing point は
`pointerFlavor` と読むのが current best reading である。

したがって `41E7-41E9` の effective visibility も、
PTR path では単なる field emergence ではなく
**`branchVariant` が second-line の pair side を concretize する点**
とみるのが自然である。

つまり `41E7-41E9` は

- shared/default side reopening
- candidate/strict side reopening

のどちらへ downstream が傾くかを first-line で visible にする slot と読める。

## Why this is still not final target selection

この pair visibility は `target` そのものではない。

既報どおり `target` は second-line の terminal result であり、
`pointerFlavor` pair の downstream effect と読むのが safest である。

したがって `41E7-41E9` に置くべき主語は、

- final target
- final consume result

ではなく、
**`pointerFlavor` pair side が visible になること**
である。

## Implication for the provisional API

この読みを API に戻すと、

- `postBranchTargetSource` = weak entry marker
- `pointerFlavor` = first effective pair-visible reopening core
- `target` = downstream terminal

という current 3-field split をそのまま強める方向になる。

## Current safest wording

現時点の safest wording は次のとおり。

- `41E6+` = reopening / consume halo onset
- `41E7-41E9` = first effective `pointerFlavor` pair visibility slot
- `41EB-41EC` = deterministic consume/writeback

## Remaining uncertainty

未確定なのは、

- `41E7-41E9` の中で pair visibility がどこまで explicit か
- `shared/candidate` の distinction が battle-side wording でどこまで直接言えるか

の finer strength である。

ただし current frontier では、
**effective slot の主語を `pointerFlavor` pair alignment に置く**
のが最も安全である。
