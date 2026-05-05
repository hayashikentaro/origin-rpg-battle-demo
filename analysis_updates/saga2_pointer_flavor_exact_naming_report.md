# SaGa2 Pointer Flavor Exact Naming Report

## Question

`pointerFlavor` を

- `"shared"`
- `"candidate"`

の 2 値で持っている current code shape を、battle-side current best reading に沿って
もう少し exact naming へ寄せるなら、どういう語彙が safest か。

## Current best reading

現時点では、`pointerFlavor` は
**target-determination provenance path discriminator**
であり、2 値は次のように読むのが safest である。

- `"shared"` = shared/default provenance path
- `"candidate"` = candidate-entry provenance path

つまり `"candidate"` は generic PTR marker ではなく、
**`D?12..` repeated candidate-entry family に anchored した provenance class**
と読むのが current best reading である。

## Why keep `shared`

`"shared"` は単なる “not candidate” ではなく、

- fast/default aligned reopening
- shared/default pointer/materialization provenance
- shared/default target-determination path

をまとめて指す current safest label である。

battle-side wording に寄せても、first-line ではこれ以上細かく分けず、
**shared/default provenance path**
として持つのが最も扱いやすい。

## Why strengthen `candidate`

`"candidate"` は既報どおり

- strict-side aligned reopening
- code-led carry
- blocked-ordinal shadow
- `D?12..` candidate-entry family anchor

を含む class であり、単なる “PTR path” より具体的である。

したがって exact naming を少し強めるなら、
これは **candidate-entry provenance path**
と読むのが safest である。

## Proposed exact wording

current best wording を code-ready に少し寄せるなら、
field meaning は次のように書ける。

- `pointerFlavor = "shared"`  
  shared/default target-provenance path

- `pointerFlavor = "candidate"`  
  candidate-entry target-provenance path

ここで “target-provenance” は final target 値そのものではなく、
**target determination へ流れ込む provenance class**
を意味する。

## Why not rename the field itself yet

field 名を今すぐ `targetProvenance` などへ変えることも考えられるが、
現時点では `pointerFlavor`

- pointer/materialization reopening
- target-determination provenance

の両方を橋渡ししている current boundary label として十分機能している。

したがって safest step は

- field 名は `pointerFlavor` のまま
- value semantics を exact wording で強める

という順序である。

## Implication for implementation

この読みをそのまま実装境界へ戻すと、

- `pointerFlavor="shared"` = shared/default provenance route
- `pointerFlavor="candidate"` = candidate-entry provenance route
- `target` = that route's downstream terminal result

と説明してよい。

つまり `pointerFlavor` は debug label から一段進んで、
**provisional but semantically loaded route-class field**
として扱える。

## Current safest wording

現時点の safest wording は次のとおり。

- `"shared"` = shared/default target-provenance path
- `"candidate"` = candidate-entry target-provenance path

## Remaining uncertainty

未確定なのは、

- battle-side で “pointer/materialization” と “target-provenance” のどちらを主語に置くか
- future に field 名自体を rename すべきか

の 2 点である。

ただし current frontier では、
**value semantics を exact naming で強める**
のが最も安全である。
