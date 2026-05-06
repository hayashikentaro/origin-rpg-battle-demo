# SaGa2 Implementation Go/No-Go Report

## Goal

current semantic closure snapshot を前提に、

- 今すぐ実装を進めてよい部分
- 追加 ROM evidence 待ちにすべき部分

を最終整理する。

## GO: safe to implement now

現時点で implementation go とみてよいもの:

### 1. 5-layer API shape

- `combatDecision`
- `postBranchRoute`
- `postBranchTargetSource`
- `pointerFlavor`
- `target`

shape 自体はかなり安定している。

### 2. layer order and roles

- decision layer
- transfer layer
- reopening layer
- terminal layer

この順序は current frontier では十分 strong である。

### 3. first-line semantics (non-numeric)

- `accepted` = local consume-path admission bit
- `branch` = actor-local resolution lane pair
- `branchVariant` = PTR-only candidate-family lane refinement bit

numeric binding を除けば、役割はかなり安定している。

### 4. transfer / second-line semantics

- `postBranchRoute` = lane-transfer core
- `postBranchTargetSource` = weak/shared marker
- `pointerFlavor` = target-provenance path pair
- `target` = downstream terminal result

この level の semantics は code-ready とみてよい。

### 5. debug / trace policy

- field order
- marker wording
- target terminal wording
- same-side carry wording

は current best reading と整合しているので、そのまま実装基準にしてよい。

## NO-GO: wait for more evidence

現時点で still-provisional として保留すべきもの:

### 1. `branchVariant 0/1` numeric binding

`0 == shared` / `1 == candidate` などの direct binding はまだ lock しない。

### 2. exact battle-native naming of fine polarity

- strict/non-fast-path side の最終語彙
- blocked-ordinal shadow の exact phrasing

などは docs wording を維持しつつ、実装では hardcode しない。

### 3. `41E3-41E5 -> 41E6 -> 41E7-41E9` fine timing

現在の chain wording は十分 useful だが、
instruction-level timing を production logic に焼き付けるにはまだ早い。

### 4. instruction-level anchor assumptions

single exact opcode や exact split point を
core implementation の contract にまで押し上げるのはまだ避ける。

## Safe implementation rule

現時点の safest rule は次のとおり。

1. layer shape と role は実装してよい  
2. side semantics は debug/docs に反映してよい  
3. numeric binding と instruction-level anchoring は保留する  
4. future evidence が増えても field shape を壊さない方向で拡張する  

## Current safest summary

**いま進めてよいのは API shape / layer role / semantic debug policy であり、待つべきなのは numeric binding と instruction-level anchoring である。**
