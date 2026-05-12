# Saga2 Integrated Boundary Snapshot Report

## 要点

- current frontier では、battle / rng / frontend の統合境界は **5 段の provisional actor-local API** としてかなり明快に整理できる
- その 5 段は  
  1. `combatDecision`  
  2. `postBranchRoute`  
  3. `postBranchTargetSource`  
  4. `pointerFlavor`  
  5. `target`  
  であり、battle-side narrowing と current code frontier の両方にかなり整合している
- したがって移植の current safest strategy は、raw battle work や full ROM semantics の完全 mirror より、この 5 段 boundary を先に安定化させることである

## 1. Decision Layer

first-line の decision layer は、
current best reading では次の shape にかなり狭まっている。

```ts
type CombatDecision = {
  accepted: boolean
  branch: number
  branchVariant?: 0 | 1
}
```

ここで:

- `accepted` は special-candidate family accept policy の first output
- `branch` は shared strict-fallback branch
- `branchVariant` は PTR false-side にだけ現れる optional refinement

と読むのが safest である。

## 2. Routing Core

decision layer の結果は

```ts
type PostBranchRoute = number
```

へ入り、

- `ATK`: `branch`
- `PTR`: `branch + branchVariant`

を shared core + optional refinement
として routing 層へ渡すのが current best reading である。

## 3. Second-Line Reopening

current frontier では、
`postBranchRoute`
のあとに second-line reopening が次の順で現れる。

```ts
type SecondLineReopening = {
  postBranchTargetSource: "explicit" | "candidate" | "slotIndex"
  pointerFlavor: "candidate" | "shared"
  target: number
}
```

この順序は:

1. `postBranchTargetSource`
2. `pointerFlavor`
3. `target`

であり、
`PTR` 側だけが second-line で candidate-flavored reopening を見せる、
という current best reading に対応する。

## 4. What Is Already Stable Enough To Code

現時点で code にかなり安全に載せられるもの:

- `BattleActionHead`
- `resolveActorCommand(...)`
- `combatDecision = { accepted, branch, branchVariant? }`
- `postBranchRoute`
- `postBranchTargetSource`
- `pointerFlavor`
- `target`

つまり actor-local bridge はもう
観測用 skeleton 以上の意味を持ち始めている。

## 5. What Remains Provisional

まだ provisional に留めるべきもの:

- `accepted` の battle-side exact semantics
- `branch` の exact branch-name semantics
- `branchVariant 0/1` の exact meaning
- `pointerFlavor="candidate"` が second-line でどこまで持続するか
- final `target` が ROM 側でどの exact route から決まるか

つまり shape はかなり固まっているが、
value semantics はまだ narrowed hypothesis の段階にある。

## implication for step 6

この snapshot を採ると、step 6 はかなり明確に

1. 5 段 provisional API を固定する
2. debug matrix / selfcheck / Godot bridge で可視化する
3. battle-side evidence で各 field の意味を強くする

という順で進めればよい。

言い換えると、今は「ROM 完全解明待ち」ではなく、
**shape を先に固定し、semantics を後から強める**
段階に入っている。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `combatDecision.accepted` / `branch` / `branchVariant` の battle-side exact semantics
2. `PTR` second-line の candidate-flavored reopening がどこまで持続するか
3. final `target` 決定の exact route が second-line thin step で足りるか

ここが取れれば、この 5 段 boundary はそのまま移植用 core interface にかなり近づく。
