# saga2 branchVariant direct local anchor gap

## Summary

- current safest ranking では、raw `0/1` binding を strongest に運ぶ本命帯は **`41E3-41E5`**
- ただし current frontier でも、ここを **direct local anchor confirmed band** とまではまだ言わない
- 残っている gap は、`41E3-41E5` の中で raw `0/1` が named side へ **局所的に貼りつく direct anchor** が未観測な点である

## What is already strong

`41E3-41E5` については current frontier で次がかなり強い。

- route-core terminal band
- retained refinement handoff edge
- `41E3-41E9` chain 全体の中で最も binding evidence に近い帯
- `41E6` / `41E7-41E9` より upstream で、raw value と side semantics の距離が短い

つまり **binding evidence の本命帯** であること自体はかなり安定している。

## What is still missing

それでも numeric binding を lock できないのは、`41E3-41E5` の中でまだ次のどちらも direct には見えていないからである。

1. raw `0/1` が `shared/default-leaning side` か `candidate-aware/strict-leaning side` のどちらかへ **局所的に貼りつく evidence**  
2. raw `0/1` split が `0E/0F` family split と **同一帯内で stronger に対応づく evidence**

言い換えると、今の `41E3-41E5` は

- **best binding candidate band**
ではあるが、
- **binding-confirming anchor band**
と呼ぶにはまだ一歩足りない。

## Safest wording

したがって current safest wording は次の通りである。

- `41E3-41E5` = strongest binding-candidate band
- `41E6` = boundary witness
- `41E7-41E9` = first effective same-side visibility slot

そして `41E3-41E5` 自体については、

- direct local anchor **gap remains**

と明記するのがもっとも安全である。

## Practical consequence

今後 `branchVariant` の numeric binding を本当に lock するには、探索線を広げる必要はない。  
必要なのは `41E3-41E5` の中で、

- raw `0/1`
- side semantics
- `0E/0F` family split

のどれか 2 つ以上を **同一局所帯で stronger に結びつける evidence** を見つけることである。

それまでは、

- raw numeric は保持
- side semantics は強く使う
- `41E3-41E5` は strongest binding-candidate band
- ただし direct local anchor gap は残る

という stance を維持するのが safest である。
