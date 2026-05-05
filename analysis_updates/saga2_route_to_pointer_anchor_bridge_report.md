# SaGa2 Route To Pointer Anchor Bridge Report

## Question

current naming policy のもとで、

- `postBranchRoute` = alignment-transfer core
- `pointerFlavor` = target-provenance path pair

を battle-side anchor へさらに寄せるなら、
両者の exact bridge はどこに置くのが safest か。

## Current best reading

現時点では、`postBranchRoute` と `pointerFlavor` の exact battle-side bridge は

- **`41E3-41E5` = retained refinement handoff edge**
- **`41E7-41E9` = first effective pointerFlavor pair visibility slot**

の 2 点で結ぶのが safest である。

つまり current best reading では、

- `41E3-41E5` に route-core の handoff がある
- `41E6` は reopening/consume halo への structural entry
- `41E7-41E9` で `pointerFlavor` pair (`shared` / `candidate`) が first effective に visible になる

という bridge を持つ。

## Why this bridge is stronger than a wider anchor

`41A4-41EC` や `41D9-41EC` 全体を anchor とすると、

- route-core
- consume halo
- effective pair visibility

が一塊になってしまい、field semantics の対応がぼやける。

current best reading では、

- `postBranchRoute` の strongest exact anchor は `41E3-41E5`
- `pointerFlavor` の strongest exact anchor は `41E7-41E9`

と二点で持つほうが、
現在の 5-layer provisional API と最もよく噛み合う。

## Role split under this bridge

この bridge を前提にすると、

- `postBranchRoute`
  - local-resolution mode / refinement を保持
  - second-line へ渡す transfer core

- `pointerFlavor`
  - handoff を受けた second-line reopening の主 landing point
  - `shared/default` vs `candidate-entry` target-provenance path を first effective に visible にする

という役割分担がさらに明確になる。

## Implication for remaining uncertainty

この読みだと、まだ未確定なのは

- `41E6` の wording を halo entry としてどこまで強く言うか
- `41E7-41E9` の中で pair visibility と local decision/gate をどう重ねるか

であり、`postBranchRoute` と `pointerFlavor` の layer order 自体はかなり安定している。

## Current safest wording

現時点の safest wording は次のとおり。

- `postBranchRoute` exact handoff anchor = `41E3-41E5`
- `pointerFlavor` first effective anchor = `41E7-41E9`
- `41E6` = reopening/consume halo entry between them

## Implementation note

実装側では、この bridge を前提に

- `postBranchRoute` を transfer core
- `pointerFlavor` を reopening core

として扱い続けてよい。

つまり次の sharpening は shape 変更ではなく、
**`41E3-41E5 -> 41E6 -> 41E7-41E9` の exact wording refinement**
に集中すればよい。
