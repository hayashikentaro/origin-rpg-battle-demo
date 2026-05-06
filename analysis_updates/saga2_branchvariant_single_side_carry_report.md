# saga2 branchVariant single-side carry

## Summary

- `41E3-41E9` は current best reading で **minimal branchVariant binding candidate cluster**
- この cluster で numeric binding を lock するための first-line 条件は、**single-side carry** がどこまで一方向に追えるかである
- current frontier では、single-side carry は **かなり強い working bias** まで上がっているが、still direct lock には一歩足りない

## What single-side carry means here

この文脈での single-side carry とは、

1. `41E3-41E5` handoff edge で retained refinement がある side を持つ  
2. `41E6` halo entry を跨いでも、その side が別の hidden selector へ崩れない  
3. `41E7-41E9` で、その same side が `pointerFlavor` pair visibility として first effective に現れる

という **one-way carry chain** を指す。

## Current safest reading

current frontier で safest に言えるのは次の通りである。

- `41E3-41E5` は **route-core terminal band / retained refinement handoff edge**
- `41E6` は **reopening / consume halo entry**
- `41E7-41E9` は **first effective same-side visibility slot**

この 3 点をつなぐと、`branchVariant` の retained refinement は current best reading で

- handoff edge で一度 terminal band に集約され
- halo entry で second-line reopening へ渡され
- effective slot で same-side pair visibility として現れる

と読むのがもっとも自然である。

つまり current frontier では、single-side carry は **かなり強い bias** まで来ている。

## Why it still does not fully lock numeric binding

それでも `0 == shared` のように lock できないのは、いま見えているのが

- side-level carry
- pair-level correspondence

までであり、raw numeric 自体が cluster 内で **unambiguously named side** に貼りつく local evidence がまだ不足しているからである。

言い換えると、current best reading では

- `41E3-41E9` = single-side carry candidate cluster
- しかしまだ **single-side carry confirmed binding cluster** とまでは言わない

のが safest である。

## Practical consequence

今後の主戦場は、semantic polarity を作り直すことではない。  
必要なのは、この `41E3-41E9` cluster の中で

- side carry が hidden remap を挟まない
- raw `0/1` が local side name と stronger に結びつく

という stronger evidence を取ることである。

それまでは current policy どおり、

- raw numeric は保持
- side semantics を優先
- `41E7-41E9` では same-side visibility
- `41E3-41E9` では single-side carry candidate cluster

と書くのが safest である。
