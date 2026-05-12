# SaGa2 Target Last Display Policy Report

## Goal

current safest debug order

`branch -> branchVariant -> postBranchRoute -> pointerFlavor -> target`

の中で、なぜ `target` を最後に置くのが safest かを整理する。

## Current best reading

現時点では、`target` は
**second-line の downstream terminal result**
とみるのが safest である。

したがって display 順でも、

- lane / refinement
- transfer core
- provenance reopening

のあと、**最後に置く** のが最も自然である。

## Why target should not come earlier

current best reading では、`target` 自体は

- PTR-specific reopening の主戦場ではない
- `pointerFlavor` pair difference の direct payload でもない

と読んでいる。

むしろ `target` は
`pointerFlavor` によって downstream で形づくられる terminal consequence
なので、先に見せると

- path discriminator
- terminal result

の主従が逆転しやすい。

## Relation to the 5-layer flow

5-layer flow を display 順にそのまま写すなら、

1. `branch`
2. `branchVariant`
3. `postBranchRoute`
4. `pointerFlavor`
5. `target`

となる。

この順だと、

- first-line の decision / refinement
- middle の transfer core
- second-line の reopening core
- その terminal output

がかなり自然に読める。

## Current safest wording

現時点の safest wording は次のとおり。

- `target` = downstream terminal result
- therefore it belongs at the end of debug display order

## Implementation implication

current debug / trace policy では、
`target` を強く説明するより

- `pointerFlavor`
- `pointerFlavorMeaning`

を主語にして、その結果として `target` を最後に置くのが safest である。
