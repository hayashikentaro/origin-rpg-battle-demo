# SaGa2 Effective Slot Overlap Report

## Question

`41E7-41E9` を

- `pointerFlavor` pair の first effective visibility slot
- local decision / gate の effective slot

と読んできた current best reading の上で、
この 2 つはどのように重なっているとみるのが safest か。

## Current best reading

現時点では、`41E7-41E9` は
**1つの slot に 2 つの独立した出来事がある** のではなく、
`pointerFlavor` pair visibility が first-line で立ち上がり、
その immediate consequence として local decision / gate が読める
**overlapped slot**
とみるのが safest である。

つまり current best reading では、

- primary emphasis = `pointerFlavor` pair visibility
- secondary emphasis = local decision / gate consequence

という主従関係を持つ。

## Why primary emphasis stays on `pointerFlavor`

既報どおり、

- `postBranchTargetSource` = weak/shared marker
- `pointerFlavor` = strongest reopening core
- `target` = downstream terminal

という second-line split が current best reading である。

また `branchVariant` retained refinement の strongest landing point も
`pointerFlavor` に置くのが safest である。

そのため `41E7-41E9` で first effective に visible になる主語も、
generic gate より **`pointerFlavor` pair side**
に置くほうが current code shape と整合する。

## Why gate is still present

いっぽう `41E7-41E9` は consume halo の内部であり、
後段の `41EB-41EC` deterministic consume/writeback へつながっている以上、
local decision / gate の意味を全く持たないとは読みづらい。

そのため safest wording は、

- `pointerFlavor` pair side が見える
- その side visibility を受けて local decision / gate が事実上決まる

という **visibility-first, gate-second** の overlap として持つことである。

## Implication for the 5-layer API

この読みを provisional API に戻すと、

- `pointerFlavor` を second-line core field として優先
- `target` をその downstream terminal として維持
- gate / consume meaning は `pointerFlavor` visibility の immediate consequence として読む

という current implementation stance をそのまま強める方向になる。

つまり field を増やさず、
`pointerFlavor` の exact semantics を sharpen するだけで十分である。

## Current safest wording

現時点の safest wording は次のとおり。

- `41E7-41E9` = first effective `pointerFlavor` pair visibility slot
- local decision / gate = immediate consequence inside the same slot

## Remaining uncertainty

未確定なのは、

- `41E7` / `41E8-41E9` の finer internal timing
- “visibility” と “gate” を battle-side wording でどこまで分けるか

の finer detail である。

ただし current frontier では、
**visibility-first, gate-second overlap**
と読むのが最も安全である。
