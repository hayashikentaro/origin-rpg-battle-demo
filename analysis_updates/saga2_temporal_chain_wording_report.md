# SaGa2 Temporal Chain Wording Report

## Goal

current best reading を battle-side の時間順として、

`41E3-41E5 -> 41E6 -> 41E7-41E9 -> 41EB-41EC`

の 1 本の wording にまとめる。

## Current safest temporal chain

現時点の safest wording は次のとおり。

1. **`41E3-41E5` = retained refinement handoff edge**  
   `postBranchRoute` の exact micro-boundary。  
   local-resolution mode pair と PTR-only refinement が second-line 側へ渡される。

2. **`41E6` = reopening / consume halo entry**  
   route-core handoff の直後にある structural entry。  
   second-line reopening が始まるが、差分の主戦場はまだ fully visible ではない。

3. **`41E7-41E9` = first effective `pointerFlavor` pair visibility slot**  
   `shared` / `candidate` の provenance side が first-line で visible になる。  
   local decision / gate はその immediate consequence として同じ slot 内に重なる。

4. **`41EB-41EC` = deterministic consume/writeback**  
   visible になった side/gate の downstream effect として、
   consume/writeback が deterministic に実行される。

## Why this wording is useful

この chain にすると、current best reading の主要点が 1 本に並ぶ。

- `postBranchRoute` は `41E3-41E5`
- `pointerFlavor` の effective visibility は `41E7-41E9`
- consume/writeback は `41EB-41EC`

つまり

- transfer core
- halo entry
- effective reopening
- deterministic effect

という 4 段がかなり明瞭になる。

## Mapping to the provisional API

この temporal chain を 5-layer provisional API に戻すと、

- `combatDecision` = handoff 前に確定した decision layer
- `postBranchRoute` = `41E3-41E5`
- `postBranchTargetSource` = `41E6` に対応する weak/shared entry marker
- `pointerFlavor` = `41E7-41E9`
- `target` = `pointerFlavor` pair の downstream terminal result

と読むのが safest である。

ここで `target` は `41EB-41EC` と 1 対 1 ではないが、
少なくとも **effective reopening の後段 effect** として置くのが current best reading に合う。

## Current safest one-sentence summary

現時点の one-sentence summary は次のとおり。

**`41E3-41E5` で retained refinement が handoff され、`41E6` で reopening halo に入り、`41E7-41E9` で `pointerFlavor` pair が first effective に visible となり、その downstream effect として `41EB-41EC` の deterministic consume/writeback が走る。**

## Remaining uncertainty

未確定なのは、

- `41E6` をどこまで独立した stage と数えるか
- `41E7-41E9` の中で visibility と gate の finer timing をどこまで分けるか

の細部である。

ただし current frontier では、この 4 段 chain wording が最も安全である。
