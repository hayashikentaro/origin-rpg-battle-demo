# SaGa2 PostBranchRoute Exact Wording Report

## Question

`postBranchRoute` を current best reading に沿って code-ready な一文へ寄せるなら、
どういう wording が safest か。

## Current best reading

現時点では、`postBranchRoute` は
**decision-layer の local-resolution mode pair と retained refinement を、
second-line の target-provenance reopening へ受け渡す alignment-transfer core**
と読むのが safest である。

## Why this wording works

この wording には current best reading の主要点がすべて入る。

- `combatDecision` のあとに来る narrow route core である
- `branch` pair を downstream へ transfer する
- PTR path では `branchVariant` refinement を保持する
- strongest landing point は `pointerFlavor` にある

したがって continuation id のような弱い表現より、
**alignment-transfer core**
と呼ぶのが最も自然である。

## Current safest wording

- `postBranchRoute` = alignment-transfer core from local-resolution mode to target-provenance reopening
