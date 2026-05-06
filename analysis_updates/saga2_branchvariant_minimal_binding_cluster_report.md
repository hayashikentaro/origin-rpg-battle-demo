# saga2 branchVariant minimal binding cluster

## Summary

- `41E7-41E9` 単独では、current frontier で strongest に言えるのは **same-side correspondence** までである
- raw `0/1` の numeric binding を lock するには、visibility slot 単体ではなく **handoff-to-visibility chain の最小 cluster** を見る必要がある
- current best reading では、その最小 cluster は **`41E3-41E9`** とみるのが safest である

## Why `41E7-41E9` alone is not enough

`41E7-41E9` は current best reading で

- first effective `pointerFlavor` pair visibility
- immediate local gate consequence

を含む visibility-led micro-sequence である。

しかしここで見えるのは **visible pair alignment** であって、raw `branchVariant 0|1` がどちら側 semantic に貼りついてきたかという **upstream retained refinement の origin** までは単独では閉じない。

したがって `41E7-41E9` 単独は

- side-level correspondence の主観測点  
ではあるが、
- numeric binding lock の単独主観測点  
ではない。

## Why `41E3-41E9` is the minimal useful cluster

current safest chain は次の通りである。

1. `41E3-41E5` = route-core terminal band / retained refinement handoff edge  
2. `41E6` = reopening / consume halo entry  
3. `41E7-41E9` = first effective same-side visibility slot

numeric binding を本当に言うには、

- retained refinement が **どの side を持ったまま handoff されるか**
- その side が **halo entry を跨いでも保持されるか**
- その結果として **どちらの visible pair side に landing するか**

の 3 段をまとめて見る必要がある。

この 3 段を最小で含むのが **`41E3-41E9`** である。

## Practical wording

current frontier で safest に書くなら、

- `41E7-41E9` = first effective same-side visibility slot
- `41E3-41E9` = minimal branchVariant binding candidate cluster

という使い分けになる。

つまり visibility の主戦場は `41E7-41E9`、binding lock の主戦場は **`41E3-41E9`** と呼ぶのがもっとも自然である。

## What would lock the binding inside this cluster

`41E3-41E9` を主 cluster としたうえで、numeric binding を lock できるのは次のどちらかである。

1. retained refinement side が handoff edge から visibility slot まで **single-side carry** としてほぼ一方向に追える  
2. 同 cluster 内で raw `0/1` split が `0E/0F` family split と **stronger に局所対応** する

このどちらにも届かない間は、current best policy どおり

- raw numeric は保持  
- side semantics を使用  
- same-side correspondence を強く言う  

のままにしておくのが safest である。
