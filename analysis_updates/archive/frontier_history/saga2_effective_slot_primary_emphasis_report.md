# SaGa2 Effective Slot Primary Emphasis Report

## Question

`41E7-41E9` を

- `pointerFlavor` の first effective visibility
- consume gate の first effective visibility

のどちらへ強く寄せて読むのが safest か。

## Current best reading

現時点では、`41E7-41E9` は **consume gate より `pointerFlavor` visibility に一段強く寄せて読む** のが safest である。

つまり current best reading では、

- `41E6+` = reopening/consume halo の structural onset
- `41E7-41E9` = first effective `pointerFlavor` visibility slot
- `41EB-41EC` = deterministic consume/writeback

という emphasis が最も自然である。

## Why `pointerFlavor` first

既報の 5-layer decomposition では、second-line の strongest field は
`postBranchTargetSource` ではなく `pointerFlavor` にある。

また `branchVariant` retained refinement の strongest landing point も
`pointerFlavor` に置くのが current best reading である。

この前提を `41E7-41E9` へ戻すと、そこを first effective slot と呼ぶなら、
まず visible になるのは

- PTR-specific reopening core
- strict/default provenance split

といった **`pointerFlavor` 側の差分** とみるのがいちばん整合する。

## Why not make it primarily a consume gate slot

`41E7-41E9` は consume halo の内部にあるので、consume gate と全く無関係とは言えない。

ただし current best reading では

- `41E6+` が halo entry
- `41E7-41E9` が effective slot
- `41EB-41EC` が deterministic consume/writeback

と読めるため、`41E7-41E9` を first-line で consume gate そのものと呼ぶと、
`41EB-41EC` の deterministic writeback との役割差がやや潰れやすい。

したがって safest wording は、

- `41E7-41E9` = pointer-flavored reopening が first visible になる slot
- consume gate meaning はその immediate consequence

と置くことである。

## Implication for the provisional API

この読みを API へ戻すと、

- `pointerFlavor` は second-line reopening の core field
- `target` はその downstream result
- consume/writeback はさらに後段の effect

という current code shape をそのまま強める方向になる。

つまり `41E7-41E9` を first effective slot と呼ぶときも、
主語は **`pointerFlavor` reopening** に置くのが safest である。

## Current safest wording

現時点の safest wording は次のとおり。

- `41E6+` = reopening / consume halo onset
- `41E7-41E9` = first effective `pointerFlavor` visibility slot
- `41EB-41EC` = deterministic consume/writeback

## Remaining uncertainty

未確定なのは、

- `41E7-41E9` の中で `pointerFlavor` visibility と local consume gate がどの程度同時に立つか
- battle-side wording で「visibility」と「gate」をどこまで分けるべきか

の finer emphasis である。

ただし current frontier では、
**primary emphasis を `pointerFlavor` に置く** のが最も安全である。
