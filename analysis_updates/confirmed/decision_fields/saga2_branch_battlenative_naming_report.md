# SaGa2 Branch Battle-Native Naming Report

## Question

`branch` を current best reading では

- shared/default local-resolution mode
- candidate-aware local-resolution mode

という pair で読んでいるが、これをもう一段だけ battle-native wording へ寄せるなら、
どういう naming が safest か。

## Current best reading

現時点では、`branch` の 2 side は

- **default resolution lane**
- **candidate-aware resolution lane**

と読むのが safest である。

つまり “mode” より少し battle-native に寄せるなら、
`branch` は **actor-local resolution lane pair** と呼ぶのが最も自然である。

## Why `lane` works better here

`branch` は final target や final consume result ではなく、
`combatDecision` 直後に actor-local resolve の流れをどちらへ通すかを決める pair である。

この役割は

- state id
- route id
- strict branch

のような固定的 naming より、
**局所的な resolution lane**
と呼ぶほうが current best reading に合う。

特に `accepted=false` 側では fallback selection、
`accepted=true` 側では admitted-path activation として読まれるため、
“same lane, different role” の構図にも `lane` がよく噛み合う。

## Why `candidate-aware`

strict/non-fast-path side は pure generic strict lane ではなく、

- `0E/0F` special-candidate family difference
- blocked-ordinal shadow
- PTR path での refinement carry

を含んだ **candidate-entry family に aware な lane**
として読むのが current best reading である。

したがって safest wording は、

- `default resolution lane`
- `candidate-aware resolution lane`

である。

## Relation to second-line naming

この naming だと second-line の

- `"shared"` = shared/default target-provenance path
- `"candidate"` = candidate-entry target-provenance path

ともかなり対称になる。

つまり first-line は

- resolution lane

second-line は

- target-provenance path

という role split で並べられる。

## Current safest wording

現時点の safest wording は次のとおり。

- `branch(default side)` = default resolution lane
- `branch(candidate-aware side)` = candidate-aware resolution lane

## Remaining uncertainty

未確定なのは、

- “default” を “shared/default” と書くべきか
- “candidate-aware” を “candidate-family-aware” まで強めるべきか

の細部である。

ただし current frontier では、
**actor-local resolution lane pair**
という wording が最も安全である。
