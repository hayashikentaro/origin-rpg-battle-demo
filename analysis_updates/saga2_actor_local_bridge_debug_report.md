# Saga2 Actor-Local Bridge Debug Report

## 要点

- current `step 6` 実装では、TypeScript core 側に `resolveActorCommand(input)` を置き、Godot front から `actorIndex + BattleActionHead(kindId, arg, target, slotIndex)` を渡す skeleton bridge が成立している
- この bridge は battle 本線を完全再現するものではなく、現時点では
  - `decodeResolvedOutcome(...)`
  - `selectLocalActionPath(...)`
  - optional slot `07/08` candidate-selection RNG
  - target routing
  - unresolved `combatDecision` hook
  の 5 段を provisional に切り出している
- `combatDecision` は依然 unresolved だが、first-line 仮説は `shouldConsumeCounter` 的な local consume policy である

## 現在の返り値

`ActorResolveResult` は現時点で次の debug-oriented fields を返す。

- `actorIndex`
- `branch`
- `localPath`
- `target`
- `targetSource`
- `didConsumeCandidateRng`
- `candidateOffset`
- `action`
- `combatDecision`
- `debugTrace`

特に `targetSource` と `candidateOffset` により、target が

- explicit target
- slot `07/08` candidate
- slotIndex fallback

のどれから来たかを front 側で観測できる。

## Godot 側の観測点

Godot front では battle scene からこの bridge を直接 preview できる。

- `ATK`
- `DEF`
- `ABL{index}:{name}`

の command matrix を provisional に組み、`localPath / targetSource / candidateOffset / combatDecision / debugTrace` を表示している。

つまり現在の front/core bridge は、battle command の actor-local opener 仮説を UI 上でそのまま追うための **debug matrix** として機能している。

## 今の意味

この bridge が確定させているのは battle semantics そのものではなく、**実装可能な境界** である。

- `BattleActionHead`
- `branch`
- `localPath`
- optional candidate RNG (`07/08`)
- provisional `combatDecision`

この 5 つは、battle RAM work の完全 mirror がなくても先に TypeScript / Godot 間で接続できる。

## 次の確認点

bridge 自体の next frontier は依然として `combatDecision` であり、ROM 側で確認すべき点は次の 2 つに絞られる。

1. `41E7-41E9` 相当の local decision slot に raw/small-range RNG が入るか
2. その返り値が `41EB-41EC` の consume/writeback 可否につながるか

ここが取れれば、現状 stub の `combatDecision` を first recovered combat semantics に押し上げられる。
