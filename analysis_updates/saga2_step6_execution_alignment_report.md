# SaGa2 Step6 Execution-Alignment Report

## Summary
- ここまでの narrowing を踏まえると、step 6 に向けた実作業は **ROM 側の確認順** と **TypeScript 側の provisional 実装順** をほぼ同じ 3 段で進められる。
- その 3 段は、**`branch/path` の確定 -> `candidate RNG` の限定実装 -> `combatDecision` の検証** である。
- したがって次は「解析が終わるまで実装を待つ」ではなく、**先に actor-local bridge を組み、その内側の `combatDecision` だけを未確定 hook として残す** 進め方が最も効率的になる。

## 1. Shared Execution Order

ROM 側の確認順と TypeScript 側の実装順は、
現時点では次の 3 段でそろえられる。

1. `branch/path` 層  
   `decodeResolvedOutcome(...)` と `selectLocalActionPath(kindId, arg)`
2. `candidate RNG` 層  
   slot `07/08` による path-dependent candidate selection
3. `combatDecision` 層  
   `41E7-41E9` 相当の local consume policy

この順にすると、
未確定が battle core 全体へ広がらず、
最後の 1 箇所へ集約される。

## 2. What Can Be Implemented Now

現時点で TypeScript 側に先に置いてよいもの:

```ts
type BattleActionHead = {
  kindId: number
  arg: number
  target: number
  slotIndex: number
}

type CombatDecision = {
  shouldConsumeCounter: boolean
  debugSource?: "unresolved_local_policy"
}

type ActorResolveResult = {
  actorIndex: number
  branch: number
  target: number
  didConsumeCandidateRng: boolean
  combatDecision?: CombatDecision
}
```

このうち battle 本線の evidence が十分強いのは:

- `BattleActionHead`
- `branch`
- `target`
- `didConsumeCandidateRng`

で、`combatDecision` だけを provisional 扱いにすればよい。

## 3. Best Current Provisional Stub

step 6 の first working skeleton は次の程度で十分である。

```ts
function resolveActorCommand(
  input: BattleCommandInput
): ActorResolveResult {
  const branch = decodeResolvedOutcome(input.actorIndex, input.outcomeLikeByte)

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

ここで `resolveCombatRngAfterLocalPath(...)` だけを
未確定 hook に残すのが現在の safest shape である。

## 4. What ROM Work Still Needs To Validate The Stub

この skeleton を battle 本線で裏づけるのに必要なのは、
もうかなり少ない。

1. `41E7-41E9` 相当の local decision slot に
   raw/small-range RNG が入るか
2. その返り値が
   `41EB-41EC` の consume/writeback 可否へつながるか
3. その小判定が
   後段で larger semantics (`hit`, `damage`) にどう接続するか

つまり step 6 に必要な残りは、
full damage formula より
**`combatDecision` の battle-side 実在確認**
である。

## 5. Why This Is The Right Cut

この切り方だと:

- Godot 側は `actorIndex + BattleActionHead` を渡せる
- TypeScript 側は provisional result を返せる
- 解析側は `combatDecision` 1 箇所だけを深掘りすればよい

ので、front/core/ROM 解析が別方向へ散らばらない。

つまり step 6 への最短線は、
`damage` を急いで完成させることではなく、
**`combatDecision` を最後の未確定 hook として隔離すること**
である。

## Implication
- step 6 の実作業は `branch/path -> candidate RNG -> combatDecision` の 3 段で進めるのが最も効率的
- TypeScript 側は actor-local bridge を先に組み、`combatDecision` だけを provisional に残せばよい
- 次の ROM 側本命は引き続き `41E7-41E9 -> 41EB-41EC` の確認である
