# saga2 branchVariant binding evidence strategy

## Summary

- `branchVariant` は current frontier で **PTR-only candidate-family lane refinement bit** としてかなり安定している
- いま未固定なのは semantic polarity ではなく、**raw `0/1` の exact numeric binding** だけである
- したがって次の探索は shape discovery ではなく、**binding lock を許す local evidence acquisition** に集中してよい

## Current stable points

- `branch` は **actor-local resolution lane pair**
- `branchVariant` は **shared/default-leaning side** と **candidate-aware/strict-leaning side** のどちらかを示す PTR-only refinement
- `pointerFlavor` は **shared/default target-provenance path** と **candidate-entry target-provenance path** の pair
- `branchVariant` raw `0|1` と `pointerFlavor` side pair のあいだには、current best reading で **strong side-level correspondence** がある
- ただし `0 == shared` / `1 == candidate` のような **numeric binding** は、まだ direct evidence が足りない

## Binding lock conditions

`branchVariant 0/1` を lock してよい条件は、current safest stance では次のどちらかである。

1. raw `0/1` と `pointerFlavor` side が、同一局所 cluster で **one-way に近い direct correspondence** を示す  
2. raw `0/1` split が、`0E/0F` special-candidate family split と **同一局所 cluster** で stronger に anchor される

このどちらにも届かない限り、raw numeric は保持しつつ semantic side naming だけを強く使うのが safest である。

## Best next evidence targets

### 1. `41E7-41E9` effective slot

- current best reading では、ここは **first effective pointerFlavor pair visibility slot**
- したがって raw `branchVariant` と `pointerFlavor` side の correspondence を最短で取りに行くなら、まずここを主観測点に置くのが自然

### 2. `41E3-41E5 -> 41E6` handoff boundary

- `41E3-41E5` は **route-core terminal band / retained refinement handoff edge**
- `41E6` は **reopening / consume halo entry**
- raw `branchVariant` の retained refinement がどの時点で second-line pair reopening に変換されるかを見るなら、この境界が最重要

### 3. `D?12..` candidate-entry family anchoring

- `branchVariant` は current best reading では **`0E/0F` family difference 主軸 + qualifier shadow** の first-line compression
- したがって raw `0/1` の numeric binding を lock する stronger evidence が来るとしたら、`D?12..` family 側の local split と同じ cluster で現れる可能性が高い

## Safe implementation policy until lock

- 型は `branchVariant?: 0 | 1` のまま保持する
- debug / UI / docs では numeric binding を言わず、side semantics を使う
- `pointerFlavor` との relation は **same-side correspondence** として記述する
- `0 == shared` のような direct wording は避ける

## Practical reading

いまの最短線は、`branchVariant` の意味を新しく作り直すことではない。  
必要なのは、すでに十分見えている side semantics を前提に、**raw `0/1` がどちら側 semantic に貼りつくかだけを lock する local evidence** を見つけることである。
