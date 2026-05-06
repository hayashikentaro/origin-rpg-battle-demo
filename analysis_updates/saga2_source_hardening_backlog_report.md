# saga2 source hardening backlog

## Summary

- current frontier では semantic core / frontend preview / debug policy / selfcheck policy が implementation-ready である
- したがって source 側の next work は semantic discovery ではなく、**contract hardening** にかなり集中できる
- ここでの hardening は raw numeric binding を決めることではなく、**deferred-binding policy のまま壊れにくくすること** が主眼になる

## A-rank backlog

### 1. Contract surface consistency

- `branch`
- `branchVariant`
- `postBranchRoute`
- `pointerFlavor`
- `target`

の 5 field が、core response / UI debug / selfcheck / docs で同じ順序と同じ wording を保つことを継続的に確認する。

**Why now**  
shape は stable なので、今もっとも価値が高いのは “意味のズレ” を防ぐことである。

### 2. Deferred-binding guardrails

- `branchVariantBindingStatus = deferred_numeric_binding`
- `branchVariantCarryMeaning = same_side_pointer_correspondence`

を current source contract の guardrail として扱い、raw `0|1` へ exact side name を再注入する変更を避ける。

**Why now**  
current biggest risk は semantic widening ではなく、未固定 binding を accidental に固定してしまうことにある。

### 3. Selfcheck semantic contract expansion

既存 selfcheck が担っている

- ordering
- pointer wording
- branchVariant wording
- deferred-binding wording

を基準に、contract が崩れたときすぐ検知できるよう補強する。

**Why now**  
semantic debug policy はすでに code-ready なので、型検査より contract test としての価値が高い。

## B-rank backlog

### 4. Frontend debug clarity

UI 側では

- `branch`
- `branchVariant`
- `postBranchRoute`
- `pointerFlavor`
- `target`

の見え方を current canonical wording と揃え続ける。特に

- `marker`
- `pointer`
- `target terminal`

の主従関係を壊さないことが重要。

### 5. Matrix / preview coverage growth

`ATK / DEF / PTR / ABL...` の preview matrix を足場に、actor-local bridge の shape が他 command class でも崩れないかを確認する。

**Why now**  
semantic core の generality を壊さずに coverage を広げられる。

## C-rank backlog

### 6. Numeric binding prep only

raw `0|1` binding を lock しないままでも、

- stronger local correspondence が来たらどこに反映するか
- source でどの field がその受け皿になるか

を整理しておく。

**Why now**  
future lock の差分を小さくできるが、今すぐ semantic value を変える必要はない。

## Explicit NO-GO

current source hardening の範囲外として、次はまだ避けるのが safest である。

- `branchVariant == 0` を exact side branch key として使う
- `branchVariant == 1` を exact side branch key として使う
- `41E3-41E5` の exact opcode semantics を source logic へ焼き込む
- `pointerFlavor` を raw `branchVariant` から direct decode する実装

## Practical reading

したがって current safest source backlog は、

**semantic discovery backlog** ではなく  
**contract-consistency backlog**

として読むのがもっとも自然である。
