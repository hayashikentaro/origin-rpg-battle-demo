# SaGa2 Effective Slot Timing Bias Report

## Question

`41E7-41E9` を

- `pointerFlavor` pair visibility first
- local gate / decision second

という overlap で読んでいる current best reading を、
時間順としてもう一段だけ細かく言うならどう表すのが safest か。

## Current best reading

現時点では、`41E7-41E9` の internal timing は
**simultaneous split** と呼ぶより、
**visibility-led micro-sequence**
とみるのが safest である。

つまり current best wording では、

1. first effective `pointerFlavor` pair visibility
2. immediate local gate consequence

が very short micro-sequence として同じ slot 内で起きる、と読むのが最も自然である。

## Why not call it fully simultaneous

simultaneous と呼ぶと、

- `pointerFlavor` が second-line core であること
- gate がその immediate consequence であること

の主従が薄くなりやすい。

current best reading では、
`41E7-41E9` の主語はあくまで `pointerFlavor` pair visibility に置くほうが
5-layer semantics に整合する。

そのため safest wording は、
完全同時ではなく
**visibility-led micro-sequence**
である。

## Why not separate it into long stages

逆にこの帯を大きく二段へ分けるほどの evidence もまだ弱い。

つまり current frontier では、

- visibility first
- gate second

という順序は言えても、
その間に独立 stage を挟むほどではない。

したがって
**micro-sequence**
という wording がちょうどよい。

## Current safest wording

現時点の safest wording は次のとおり。

- `41E7-41E9` = visibility-led micro-sequence
  - first effective `pointerFlavor` pair visibility
  - immediate local gate consequence

## Implication for the temporal chain

この wording を current temporal chain に戻すと、

- `41E3-41E5` = handoff edge
- `41E6` = halo entry
- `41E7-41E9` = visibility-led micro-sequence
- `41EB-41EC` = deterministic consume/writeback

という 4 段の粒度が最も自然である。

## Remaining uncertainty

未確定なのは、

- `41E7` 単独を visibility edge とまで呼ぶか
- `41E8-41E9` を gate emphasis 側へさらに寄せるか

の finer bias である。

ただし current frontier では、
**visibility-led micro-sequence**
という wording が最も安全である。
