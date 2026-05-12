# SaGa2 Readiness After Exact Naming Report

## Snapshot

exact naming を更新したあとの current readiness を整理する。

## Code-ready or close

現時点でかなり code-ready とみてよいのは次の部分。

- 5-layer shape
  - `combatDecision`
  - `postBranchRoute`
  - `postBranchTargetSource`
  - `pointerFlavor`
  - `target`
- layer order
- `accepted` の role
- `pointerFlavor` の pair semantics
- `postBranchRoute` の transfer role
- `target` を downstream terminal とみる読み

## Still provisional

still-provisional なのは shape ではなく exact named semantics の sharpen 部分である。

- `branch` の side names をどこまで battle-side recovered wording に寄せるか
- `branchVariant 0/1` の numeric polarity naming
- `postBranchTargetSource` をどこまで explicit semantics に持ち上げるか
- `target` の exact numeric battle meaning

## Current safest implementation stance

実装上は、

- field shape は固定
- docs / debug wording は exact naming を採用
- numeric polarity naming は保留

という stance が最も安全である。
