# SaGa2 Reopening Onset Wording Split Report

## Question

`41E3-41E5` を handoff edge、`41E6+` を reopening/consume halo と置いたあと、
second-line reopening の onset を

- `41E6` 単独
- `41E7-41E9`

のどちら寄りで呼ぶのが safest か。

## Current best reading

現時点の safest wording は、**layer onset は `41E6+`、first effective local decision slot は `41E7-41E9`** と二段に分けて持つ形である。

つまり current best reading では、

- `41E6` = reopening/consume halo の入口
- `41E7-41E9` = first effective local decision slot
- `41EB-41EC` = deterministic consume/writeback

という finer split が最も自然である。

## Why not collapse everything to `41E7-41E9`

`41E7-41E9` は local decision として非常に重要だが、
それだけを onset と呼ぶと

- `41E3-41E5` handoff edge
- `41E6` halo entry
- `41E7-41E9` first effective decision

の三段差が潰れてしまう。

current best reading では、`pointerFlavor` reopening が fully meaningful になるのは
`41E7-41E9` 以降に寄るとしても、**layer の立ち上がりそのもの** は `41E6+`
に置いたほうが route-core と second-line の境界をきれいに保てる。

## Why not call only `41E6` the onset and stop there

逆に `41E6` 単独だけを onset と呼ぶと、
PTR-specific reopening の実効差がどこで visible になるかが弱くなる。

current best reading では `41E6` は

- handoff を受けた halo entry
- reopening/consume zone への進入点

として重要だが、**first effective local decision** が visible になるのは
なお `41E7-41E9` に寄る。

したがって safest wording は、

- structural onset = `41E6+`
- effective decision slot = `41E7-41E9`

の二段で持つことである。

## Implication for the 5-layer API

この読みを provisional API に戻すと、

1. `combatDecision`
2. `postBranchRoute`
3. second-line reopening (`41E6+`)
4. effective local decision visibility (`41E7-41E9`)
5. consume/writeback (`41EB-41EC`)

という時間順を想定してよい。

ただし field shape としては、

- `postBranchTargetSource`
- `pointerFlavor`
- `target`

を増やさず保持したまま、
`pointerFlavor` の exact visible effect が `41E7-41E9` に一段寄る、
という wording だけを sharpen するのが safest である。

## Current safest wording

現時点の safest wording は次のとおり。

- `41E3-41E5` = retained refinement handoff edge
- `41E6+` = reopening / consume halo onset
- `41E7-41E9` = first effective local decision slot inside that halo

## Remaining uncertainty

未確定なのは、

- `41E6` にどれだけ explicit reopening evidence を置くか
- `41E7-41E9` を pointer-flavored visibility と consume gate のどちらへ強く寄せるか

の finer emphasis である。

ただし current frontier では、
**layer onset と effective decision slot を分けて持つ wording**
が最も安全である。
