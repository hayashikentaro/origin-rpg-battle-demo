# SaGa2 BranchVariant Trace Wording Report

## Goal

`branchVariant` raw `0|1` と `pointerFlavor="shared"/"candidate"` の strong side-level correspondence を、
numeric binding を固定しないまま trace/debug wording にどう反映するのが safest かを整理する。

## Current safest wording

現時点の safest trace wording は、

- raw value はそのまま出す
- side semantics は別に出す
- `pointerFlavor` との correspondence は “same-side” として書く

という 3 段である。

つまり trace では、

- `branchVariant=0|1`
- `branchVariantMeaning=shared_default_leaning | candidate_aware_strict_leaning`
- `pointerFlavor=shared | candidate`

を並べ、**numeric value と second-line side を直接同一視する wording はまだ避ける**
のが safest である。

## Why this wording helps

この形なら、

- numeric field はそのまま残る
- semantic polarity は明示できる
- future の exact binding が変わっても debug contract を壊しにくい

という利点がある。

## Recommended phrase

current best phrase は次のようなものになる。

**`branchVariant` carries a same-side refinement correspondence into `pointerFlavor`, but raw `0/1` is still left unnamed.**

## Current implementation bias

現時点では、これを docs/debug wording で先に強め、
production logic ではまだ raw numeric value を named side に焼き付けない
方針が safest である。
