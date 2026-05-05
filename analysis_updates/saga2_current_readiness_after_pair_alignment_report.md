# Saga2 Current Readiness After Pair-Alignment Report

## 要点

- current frontier では、5-layer provisional API の **shape / flow / field split** はかなり stable で、実装に使ってよい部分がさらに増えている
- いっぽう still-provisional な論点は、もはや field を増やすことではなく、**field values の exact named semantics** と **route core の exact battle-side anchoring** にかなり集中している
- したがって current safest strategy は、pair-alignment まで反映した shape を fixed interface として使い、残る解析は `branch / branchVariant / pointerFlavor / postBranchRoute` の meaning sharpening に寄せることである

## 1. What Is Now Strongly Code-Ready

### a. 5-layer shape

```ts
combatDecision
postBranchRoute
postBranchTargetSource
pointerFlavor
target
```

この層分解は current frontier ではかなり stable である。

### b. First-line shape

```ts
type CombatDecision = {
  accepted: boolean
  branch: number
  branchVariant?: 0 | 1
}
```

ここで

- `accepted`
  = role-switching admission bit
- `branch`
  = shared branch-family alignment
- `branchVariant`
  = PTR-only optional refinement

という provisional semantics までかなり安全に使える。

### c. Second-line split

- `postBranchTargetSource`
  = weak/shared entry marker
- `pointerFlavor`
  = second-line reopening core
- `target`
  = pair-alignment downstream terminal

この役割分担も current best reading と current code の両方にかなり整合している。

## 2. Pair-Alignment Reading Now Safe Enough To Use

current frontier で特に前進したのは、
first-line / second-line の両方を
**same alignment, different role**
でかなり綺麗に読めるようになった点である。

### first-line

- `branch`
  = fast/default side と strict sideを持つ shared pair
- `branchVariant`
  = PTR-only refinement

### second-line

- `pointerFlavor="shared"`
  = fast/default aligned provenance reopening
- `pointerFlavor="candidate"`
  = strict-side aligned provenance reopening

### cross-acceptance

- `accepted=false`
  = fallback-side reading
- `accepted=true`
  = admitted-path reading

つまり `accepted`
は pair の向きを変えるのではなく、
same alignment をどの role で読むかを決める field としてかなり安定している。

## 3. What Is Still-Provisional

shape が stable になったぶん、
残っている未確定はかなり狭い。

### a. Exact named semantics

- `branch` の exact branch-family naming
- `branchVariant 0/1` の exact numeric naming
- `pointerFlavor` の exact ROM-side provenance wording

### b. Route-core exactness

- `postBranchRoute` の exact battle-side anchoring
- route core が `branchVariant` をどこまで保持するかの direct evidence
- `postBranchTargetSource` がどこまで truly weak marker か

### c. Final downstream exactness

- final `target` の exact route
- pair alignment だけで説明し切れない residual の有無

つまり still-provisional は、
field existence や layer order ではなく、
**exact meaning と exact anchoring**
へかなり集中している。

## 4. Updated Safest Working Rule

現時点の safest working rule は次の通りである。

- field は増やさない
- 5-layer order は固定する
- pair-alignment reading を provisional semantics として採用する
- exact named meaning は ROM evidence が増えたら sharpen する

言い換えると、
今は interface design の段階をほぼ抜けて、
**semantic sharpening stage**
に入っている。

## implication for step 6

この整理により、step 6 の implementation boundary も更新できる。

### strongly code-ready

- `combatDecision`
- `postBranchRoute`
- `postBranchTargetSource`
- `pointerFlavor`
- `target`
- debug matrix / selfcheck / Godot bridge

### still-provisional but acceptable

- `branch` / `branchVariant` / `pointerFlavor` の exact names
- `postBranchRoute` の exact battle-side location
- final `target` の exact route

つまり interface 自体はもう使ってよく、
解析は **meaning sharpening** にかなり集中してよい段階である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `postBranchRoute` の exact battle-side anchoring
2. `branchVariant 0/1` の exact named semantics
3. `pointerFlavor` の exact ROM-side provenance wording

ここが取れれば、current provisional API はかなり recovered interface に近づく。
