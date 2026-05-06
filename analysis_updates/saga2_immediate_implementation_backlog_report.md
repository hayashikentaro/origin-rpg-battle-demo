# SaGa2 Immediate Implementation Backlog Report

## Goal

current GO / NO-GO split を、そのまま

- 今すぐ着手してよい implementation backlog
- evidence 待ち backlog

へ落とす。

## Immediate GO backlog

### 1. Core result contract stabilization

今すぐ進めてよい。

- `combatDecision`
- `postBranchRoute`
- `postBranchTargetSource`
- `pointerFlavor`
- `target`

の 5-layer shape を、current wording のまま core contract として固定する。

### 2. Debug and trace consistency

今すぐ進めてよい。

- `branch -> branchVariant -> postBranchRoute -> pointerFlavor -> target`
  の表示順
- `marker`
- `target terminal`
- same-side carry wording

を維持し、future checks でも壊さないようにする。

### 3. Frontend bridge usage

今すぐ進めてよい。

Godot 側では

- `branch`
- `branchVariant`
- `postBranchRoute`
- `pointerFlavor`
- `target`

を provisional actor-local bridge の canonical fields として扱う。

### 4. Test coverage around layer roles

今すぐ進めてよい。

追加するなら、

- `pointerFlavor="shared"` / `"candidate"`
- `branchVariant` present / absent
- `postBranchRoute` ordering

の shape/ordering checks が first-line になる。

## Wait-for-evidence backlog

### 1. Numeric binding implementation

まだ待つ。

- `branchVariant=0` を named side に固定
- `branchVariant=1` を named side に固定

は direct evidence が増えるまで入れない。

### 2. Opcode-level assumptions

まだ待つ。

- `41E3`
- `41E4`
- `41E5`

の exact split を production contract に焼き付けない。

### 3. Fine timing dependent behavior

まだ待つ。

`41E7-41E9` の visibility-first/gate-second micro-sequence を
behavioral branching へ過度に反映しない。

## Suggested next implementation order

1. core contract comments / docs sync  
2. selfcheck strengthening  
3. frontend debug consumers cleanup  
4. only after new evidence: numeric binding refinement  

## Current safest summary

**今すぐ進めるべきは contract / debug / bridge / shape-check であり、待つべきは numeric binding と opcode-level anchoring である。**
