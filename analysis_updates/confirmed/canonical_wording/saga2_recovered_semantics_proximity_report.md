# SaGa2 Recovered Semantics Proximity Report

## Goal

current safest temporal chain

- `41E3-41E5` = retained refinement handoff edge
- `41E6` = reopening / consume halo entry
- `41E7-41E9` = first effective `pointerFlavor` pair visibility slot
- `41EB-41EC` = deterministic consume/writeback

を前提に、5-layer provisional API がどこまで recovered semantics に近づいたかを整理する。

## Overall assessment

現時点では、5-layer provisional API は
**shape / order / layer-role の大半が recovered decomposition にかなり近い**
ところまで来ている。

未確定なのは主に

- exact numeric naming
- exact battle-native labels
- route-core micro-boundary の finer wording

であり、layer split 自体を大きく見直す必要はかなり薄い。

## Layer-by-layer proximity

### 1. `combatDecision`

現時点の recovered proximity はかなり高い。

- `accepted` = local consume-path admission bit
- `branch` = local-resolution mode pair
- `branchVariant` = PTR-only candidate-family refinement bit

という field split は current best reading とよく噛み合っている。

未確定なのは `branchVariant 0/1` の numeric binding だけで、
shape と role 自体はかなり安定している。

### 2. `postBranchRoute`

これもかなり recovered semantics に近い。

- alignment-transfer core
- retained refinement handoff

という wording は `41E3-41E5` anchor とよく対応している。

残る曖昧さは、`41E3-41E5` のどこを exact route-core edge と呼ぶかという
micro-boundary の finer wording である。

### 3. `postBranchTargetSource`

これは shape は安定しているが、semantics は intentionally weak に保っている。

current best reading では

- weak/shared reopening entry marker

という役割で十分であり、ここを stronger field に押し上げる必要は薄い。

つまり “回収不足” ではなく、**弱い field として回収済み** と見るのが自然である。

### 4. `pointerFlavor`

second-line の中で最も recovered semantics に近づいている field である。

current best wording:

- `"shared"` = shared/default target-provenance path
- `"candidate"` = candidate-entry target-provenance path

さらに battle-side でも

- `41E7-41E9` = first effective pair visibility slot

まで置けているので、exact meaning の回収度はかなり高い。

残る曖昧さは “pointer/materialization” と “target-provenance” のどちらを主語に置くか、
という wording の細部である。

### 5. `target`

`target` は field としては安定しているが、
semantic recovery は intentionally downstream 寄りである。

current best reading ではこれは

- `pointerFlavor` pair の downstream terminal result

であり、独立の PTR-specific semantic axis を持たせないほうが自然である。

したがってここは “まだ弱い” のではなく、
**downstream terminal として十分に narrow に回収している**
と見るのが safest である。

## Strongest recovered pieces

現時点で最も recovered semantics に近いのは次の 3 つである。

1. `accepted` = admission bit
2. `pointerFlavor` = target-provenance path pair
3. `postBranchRoute` = alignment-transfer core

## Still-most-provisional pieces

相対的にまだ provisional なのは次の 3 つである。

1. `branch` pair の exact battle-native naming
2. `branchVariant 0/1` の numeric polarity binding
3. `41E3-41E5` / `41E6` / `41E7-41E9` の finer internal timing wording

## Current safest summary

現時点の safest summary は次のとおり。

**5-layer provisional API は、shape と layer-role の面ではかなり recovered semantics に近づいており、残る課題は exact naming と finer timing wording であって、decomposition の再設計ではない。**
