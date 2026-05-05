# Saga2 Field Readiness Snapshot Report

## 要点

- current frontier では、actor-local provisional API の field は **code-ready に近いもの** と **still-provisional なもの** にかなりはっきり分かれてきている
- shape 自体はすでにかなり安定しており、いまの主課題は field を増やすことではなく、各 field の semantics を battle-side evidence で強くすることに移っている
- したがって current safest strategy は、5 段 API を固定したまま field ごとの readiness を明示し、実装と解析の境界を見えるようにすることである

## 1. Current 5-Layer Shape

current best reading / current code frontier の共通 shape は次の通りである。

1. `combatDecision`
2. `postBranchRoute`
3. `postBranchTargetSource`
4. `pointerFlavor`
5. `target`

これは first-line / second-line を分けた provisional API boundary としてかなり安定している。

## 2. Code-Ready Shape Fields

shape と役割がかなり安定しており、
current code にそのまま置いてよい field:

- `accepted`
- `branch`
- `branchVariant?`
- `postBranchRoute`
- `postBranchTargetSource`
- `pointerFlavor`
- `target`

ここで「code-ready」とは、
field 自体の存在と層分けを大きく再設計する必要が薄い、
という意味である。

## 3. Semantics That Are Already Fairly Strong

current best reading でかなり強く持てる semantics:

- `accepted`  
  = local consume-path admission bit
- `branch`  
  = shared strict-fallback branch family  
  （true 側では admitted-path activation として読める）
- `branchVariant`  
  = PTR-only optional refinement  
  = shared `0 | 1` value with contextual meaning
- `postBranchTargetSource`  
  = weak post-branch entry marker
- `pointerFlavor`  
  = PTR-specific second-line reopening core
- `target`  
  = pointer reopening の downstream result

つまり exact recovered semantics ではなくても、
field-level の current safest reading はかなり揃っている。

## 4. Fields Still Markedly Provisional

まだ exact meaning が薄い、または battle-side confirmation が足りないもの:

- `accepted=true` の exact downstream effect
- `branch` の exact branch-name / phase-name 対応
- `branchVariant 0/1` の exact meaning  
  （true/false で shared value はかなり強いが、named meaning は未確定）
- `postBranchRoute` の exact battle-side location
- `pointerFlavor="candidate"` がどこまで持続するか
- final `target` の exact route

つまり shape は stable だが、
value meaning は narrowed hypothesis のものがまだ残っている。

## 5. Safest Current Reading In Table Form

| field | current best reading | readiness |
|---|---|---|
| `accepted` | local consume-path admission bit | medium-high |
| `branch` | shared branch family | medium |
| `branchVariant` | PTR-only optional refinement | medium |
| `postBranchRoute` | shared routing core output | medium |
| `postBranchTargetSource` | weak entry marker | medium-high |
| `pointerFlavor` | PTR-specific reopening core | medium-high |
| `target` | downstream result | medium |

## implication for step 6

この snapshot を採ると、step 6 の current strategy はかなり明確になる。

- field を増やさない
- shape を固定する
- readiness の高い field から semantics を強める

つまり next analysis の優先順は、
`pointerFlavor`, `accepted`, `branch`, `branchVariant`
の exact meaning を battle-side evidence で押し上げることになる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `pointerFlavor` の exact battle-side meaning
2. `branchVariant 0/1` の exact named semantics
3. `branch` の exact branch-family mapping

ここが取れれば、current provisional API はかなり recovered interface に近づく。
