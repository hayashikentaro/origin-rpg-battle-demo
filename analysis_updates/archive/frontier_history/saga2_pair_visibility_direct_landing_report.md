# SaGa2 Pair Visibility Direct Landing Report

## Question

`41E7-41E9` で first effective に visible になる
`pointerFlavor` pair alignment (`shared` / `candidate`) は、

- `postBranchTargetSource` を明確な中間 landing point として経由するのか
- ほぼ直接 `pointerFlavor` に landing すると読むべきか

## Current best reading

現時点では、`41E7-41E9` の pair visibility は
**`postBranchTargetSource` を素通り気味にして、実質 `pointerFlavor` に直接 landing する**
とみるのが safest である。

つまり `postBranchTargetSource` は second-line reopening の entry marker としては useful だが、
PTR-specific / pair-specific な実効差分の main landing point ではない。

## Why direct-to-pointer is safer

既報の role split はかなり一貫していて、

- `postBranchTargetSource` = weak/shared entry marker
- `pointerFlavor` = strongest reopening core
- `target` = downstream terminal

となっている。

この前提で `41E7-41E9` を first effective pair visibility slot と読むなら、
そこに現れる main distinction も
`postBranchTargetSource` より **`pointerFlavor`** に置くほうが整合する。

## Why not strengthen `postBranchTargetSource`

`postBranchTargetSource` を強い landing point にすると、

- `pointerFlavor` との責務差
- `target` との downstream 差

が薄くなりやすい。

current best reading では、`postBranchTargetSource` は

- route core から second-line へ移ったことを示す entry marker
- shared / candidate の reopening が始まる前提条件

としては useful だが、
**pair alignment が first effective に差分化する主戦場**
としてまでは持ち上げないほうが安全である。

## Implication for the 5-layer flow

この読みを 5-layer flow に戻すと、

1. `combatDecision`
2. `postBranchRoute`
3. `postBranchTargetSource` (weak marker)
4. `pointerFlavor` (first effective pair landing)
5. `target`

という current code shape がさらに強くなる。

つまり `41E7-41E9` で visible になる second-line 差分の主語は、
`postBranchTargetSource` ではなく **`pointerFlavor`** に置くのが safest である。

## Current safest wording

現時点の safest wording は次のとおり。

- `postBranchTargetSource` = weak/shared reopening entry marker
- `pointerFlavor` = first effective pair-alignment landing point

## Remaining uncertainty

未確定なのは、

- `postBranchTargetSource` に pair visibility の弱い shadow をどこまで認めるか
- `41E7-41E9` の中で marker と landing がどこまで時間差を持つか

の finer nuance である。

ただし current frontier では、
**pair visibility の主 landing point は `pointerFlavor`**
とみるのが最も安全である。
