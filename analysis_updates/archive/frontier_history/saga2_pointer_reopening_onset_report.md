# SaGa2 Pointer Reopening Onset Report

## Question

`postBranchRoute` の exact micro-boundary を `41E3-41E5` に寄せたあと、second-line reopening の **最初の実効点** はどこに置くのが自然か。

## Current best reading

現時点では、second-line reopening の最初の実効点は **`41E6+`** に置くのが safest である。

つまり current best reading では、

- `41D9-41E2` = route material gathering
- `41E3-41E5` = retained refinement handoff edge
- `41E6-41EC` = reopening / consume halo

という 3 分割が最も自然である。

## Why not `41E3-41E5` itself?

`41E3-41E5` は narrow には非常に重要だが、役割は **reopening そのもの** より
**route-core から downstream へ retained refinement を渡す局所境界** とみるほうが整合する。

ここではまだ

- `branch`
- `branchVariant`
- alignment polarity

の handoff が主であり、PTR-specific な second-line field の reopening が fully visible になったとは読みづらい。

したがって `41E3-41E5` は

- exact handoff edge
- route-core の終端

として扱い、second-line 実効開始点そのものとは切り分けるのが安全である。

## Why `41E6+` works better

`41E6-41EC` は既報どおり consume halo として読めるが、時間順には
**route-core の handoff を受けて first effective reopening / consume が立ち上がる帯**
として持つと一番きれいにつながる。

この置き方だと、

1. `combatDecision`
2. `postBranchRoute`
3. second-line reopening

の境界がかなり明確になる。

特に second-line の中心 field を

- `postBranchTargetSource` = weak/shared entry marker
- `pointerFlavor` = strongest reopening core
- `target` = downstream terminal

と置いた current code shape とも噛み合う。

## Implication for the provisional API

この読みを API 側へ戻すと、

- `postBranchRoute` は `41E3-41E5` 近辺で閉じる
- `postBranchTargetSource / pointerFlavor / target` の second-line reopening は `41E6+` 側で開く

という順序で持つのが safest である。

つまり `pointerFlavor` は route-core の内部 field ではなく、
**handoff を受けたあとに初めて意味を持つ reopening field** と読むべきである。

## Current safest wording

現時点の safest wording は次のとおり。

- `41E3-41E5` = retained refinement handoff edge
- `41E6+` = first effective reopening / consume onset

## What remains unresolved

未確定なのは reopening の存在そのものではなく、

- `41E6` 単独を onset と呼ぶべきか
- `41E7-41E9` 以降を first effective local decision slot と呼ぶべきか

という finer wording の差である。

ただし first-line の decomposition と provisional API を支えるには、
**`41E6+` を reopening onset と置く current best reading で十分に実用的**
である。
