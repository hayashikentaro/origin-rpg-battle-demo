# Saga2 Implementation Readiness Split Report

## 要点

- current frontier では、battle/RNG 解析から得られた actor-local API の field は **いま実装に使ってよい部分** と **still-provisional で追加 evidence が必要な部分** にかなり明確に分かれてきている
- shape と layer 分解はかなり安定しており、いまの主課題は field を増やすことではなく、各 field の exact semantics を battle-side evidence で強めることにある
- したがって current safest strategy は、code-ready な部分を固定しつつ、still-provisional な部分だけを明示的に保留することである

## 1. Safe To Use In Implementation

current best reading の範囲で、実装に使ってよい部分は次の通りである。

### a. 5-layer shape

```ts
combatDecision
postBranchRoute
postBranchTargetSource
pointerFlavor
target
```

この層分解自体はかなり安定している。

### b. CombatDecision shape

```ts
type CombatDecision = {
  accepted: boolean
  branch: number
  branchVariant?: 0 | 1
}
```

ここで `branchVariant` は PTR-only optional field として持つのが安全である。

### c. Second-line field split

- `postBranchTargetSource` = weak entry marker
- `pointerFlavor` = second-line reopening core
- `target` = downstream result

この役割分担も current best reading と current code の両方にかなり整合している。

## 2. Semantics Strong Enough For Provisional Code

exact recovered semantics ではないが、
current provisional code に十分載せてよい reading:

- `accepted` = local consume-path admission bit
- `branch` = shared branch family
- `branchVariant` = PTR-only refinement
- `pointerFlavor="shared"` = ATK 側を含む default pointer/materialization class
- `pointerFlavor="candidate"` = PTR-specific candidate pointer/materialization class
- `target` = pointerFlavor の downstream result

つまり「shape だけ」ではなく、
かなりの部分は already-usable semantics に入っている。

## 3. Still-Provisional / Needs More Evidence

まだ追加 evidence が必要なもの:

- `accepted=true` の exact downstream effect
- `branch` の exact branch-family mapping
- `branchVariant 0/1` の exact named meaning
- `postBranchRoute` の exact battle-side location
- `postBranchTargetSource` がどこまで branchVariant 非依存か
- `pointerFlavor` の exact ROM-side provenance
- final `target` の exact route

つまり field 自体は使えるが、
値の「名前付き意味」はまだ narrowed hypothesis のものが残っている。

## 4. Safest Working Rule

現時点の safest working rule は次の通りである。

- field は増やさない
- shape は固定する
- semantics は provisional だと明示したうえで使う
- exact meaning は battle-side evidence が増えたら上書きする

言い換えると、
今は interface の epoch を固定し、
field meaning を強くしていく段階である。

## implication for step 6

この整理により、step 6 の current implementation boundary はかなり明快になる。

### code-ready

- `resolveActorCommand(...)` bridge
- `combatDecision`
- `postBranchRoute`
- second-line reopening fields
- Godot debug matrix / selfcheck

### still-provisional

- field values の exact named meaning
- battle-side recovered semantics

つまり実装はもう進めてよく、
解析は「field meaning の sharpening」へ集中すればよい。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `pointerFlavor` の exact battle-side meaning
2. `branchVariant 0/1` の exact named semantics
3. `branch` の exact family mapping

ここが取れれば、provisional code はかなり recovered interface に近づく。
