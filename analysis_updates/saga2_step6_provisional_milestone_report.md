# SaGa2 Step6 Provisional-Milestone Report

## Summary
- step 6 に向けた current best cut は、**先に実装してよい actor-local bridge** と **最後まで provisional に残す `combatDecision` hook** を明確に分けることにある。
- これにより、Godot front は battle command UI と target UI から `resolveActorCommand(...)` を呼び始められ、TypeScript core は `branch/path/candidate RNG/routing` までを先行実装できる。
- したがって現時点の milestone は、`damage` まで待つことではなく、**`combatDecision` だけ unresolved のまま first working skeleton を成立させること** になる。

## 1. Safe-To-Implement Now

いまの evidence だけで先に実装してよいものは次の 4 層。

1. `BattleActionHead`
```ts
type BattleActionHead = {
  kindId: number
  arg: number
  target: number
  slotIndex: number
}
```

2. branch decode
```ts
function decodeResolvedOutcome(
  playerIndex: number,
  outcomeLikeByte: number
): number
```

3. local path open
```ts
function selectLocalActionPath(
  kindId: number,
  arg: number
): number
```

4. path-dependent candidate RNG
```ts
function buildPointerCandidateWithRng07_08(...): unknown
```

この 4 層は、battle-side の既報とかなりきれいに整合している。

## 2. Intentionally Provisional

逆に、意図的に provisional のまま残すべきものは次の 2 本だけでよい。

1. `combatDecision`
```ts
type CombatDecision = {
  shouldConsumeCounter: boolean
  debugSource?: "unresolved_local_policy"
}
```

2. larger combat semantics
- `hit`
- `damage`
- `reroute`
- `order`

これらは今の段階では
`07/08` candidate-selection や `33` particle と混同しやすいので、
明示的に unresolved として隔離しておくのが安全。

## 3. Best Current Skeleton

step 6 の first working skeleton は次の形に置ける。

```ts
type BattleCommandInput = {
  actorIndex: number
  action: BattleActionHead
}

type ActorResolveResult = {
  actorIndex: number
  branch: number
  target: number
  didConsumeCandidateRng: boolean
  combatDecision?: CombatDecision
}

function resolveActorCommand(
  input: BattleCommandInput
): ActorResolveResult {
  const branch = decodeResolvedOutcome(input.actorIndex, 0)
  const localPath = selectLocalActionPath(
    input.action.kindId,
    input.action.arg
  )

  const candidate =
    pathNeedsCandidateSelection(localPath)
      ? buildPointerCandidateWithRng07_08(...)
      : null

  const target = routeTarget(
    input.action.target,
    input.action.slotIndex,
    candidate
  )

  const combatDecision = resolveCombatRngAfterLocalPath(...)

  return {
    actorIndex: input.actorIndex,
    branch,
    target,
    didConsumeCandidateRng: candidate !== null,
    combatDecision,
  }
}
```

重要なのは、
この skeleton が **`combatDecision` だけ未確定でも成立する** こと。

## 4. Godot-Side Milestone

Godot 側はこの cut なら、
先に次の作業へ入れる。

1. actor command UI から `BattleActionHead` を組む
2. actor index と一緒に core へ送る
3. 返ってきた `branch` / `target` / `didConsumeCandidateRng` を debug 表示に使う
4. `combatDecision` は存在すれば追加表示する

つまり front 側は、
damage 数値や完全命中処理を待たずに接続を始められる。

## 5. What Must Still Be Confirmed In ROM

milestone を進めるうえで ROM 側に残る critical confirmation は、
かなり狭い 2 点に保てている。

1. `41E7-41E9` 相当の local decision slot に raw/small-range RNG が入るか
2. その返り値が `41EB-41EC` の consume/writeback 可否へつながるか

この 2 点が通れば、
`combatDecision.shouldConsumeCounter`
を first recovered semantics として一段強く固定できる。

## 6. Recommended Next Milestone

したがって、次の milestone は次の一文で表せる。

**`resolveActorCommand(...)` を provisional 実装し、`combatDecision` だけ unresolved hook に残した状態で Godot bridge の接続を始める。**

この進め方なら、
ROM 解析と実装の両方が前進する。

## Implication
- step 6 は「全部確定してから着手」ではなく「`combatDecision` だけ保留で skeleton を成立させる」段階に入っている
- TypeScript core は actor-local bridge を先に組んでよい
- Godot front も `branch/target/debug` ベースで接続を始められる
