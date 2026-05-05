# SaGa2 TypeScript/Godot Bridge Frontier Report

## Summary
- 現時点の解析だけでも、TypeScript core と Godot front の間に置く **最小 bridge 契約** はかなり具体的に書ける。
- その契約の中心は、`player-local seed/selection` や RAM page 配置の完全再現ではなく、**`BattleActionHead` と `player-scoped branch/outcome` を受けて actor-local action resolve を進める narrow API** にある。
- したがって step 6 に向けて今先に固定すべきなのは、battle RAM 全体の mirror ではなく、**Godot -> TypeScript の command/target input** と **TypeScript -> Godot の per-actor resolve result** の境界である。

## 1. Stable Enough Core Boundary

既報をまとめると、battle core の最小境界は次の 3 本で持つのが自然。

```ts
type BattleActionHead = {
  kindId: number
  arg: number
  target: number
  slotIndex: number
}

type OutcomeLikeByte = number
type ActionPhaseBranch = number

function decodeResolvedOutcome(
  playerIndex: number,
  outcomeLikeByte: OutcomeLikeByte
): ActionPhaseBranch

function openLocalActionResolve(
  playerIndex: number,
  branch: ActionPhaseBranch,
  action: BattleActionHead
): void

function nextRng(
  slot: number,
  lower: number,
  upper: number
): number
```

ここで:

- `decodeResolvedOutcome` は `019E -> 6157` 線の narrow bridge
- `openLocalActionResolve` は actor-local opener frontier
- `nextRng` は `043E` 契約

をそれぞれ受け持つ。

## 2. What Godot Actually Needs First

Godot 側から最初に必要なのは、
ROM の page layout を丸ごと送ることではなく、
**command UI で確定した 1 actor 分の action input** を core に渡すこと。

first-line では次で十分持てる。

```ts
type BattleCommandInput = {
  actorIndex: number
  action: BattleActionHead
}
```

さらに target UI が確定しているなら:

```ts
type BattleCommandInput = {
  actorIndex: number
  action: BattleActionHead
  manualTarget?: number
}
```

としてもよい。

この境界なら、
`D?43-46` の RAM 配置を Godot に露出しなくて済む。

## 3. What TypeScript Should Return First

逆方向も、最初は page-wide staging 結果ではなく
per-actor の局所結果だけで十分である。

```ts
type ActorResolveResult = {
  actorIndex: number
  branch: ActionPhaseBranch
  target: number
  didConsumeCandidateRng: boolean
}
```

ここで `didConsumeCandidateRng` は、
現時点で first high-confidence RNG use が
slot `07/08` による candidate-selection 系だと整理できているため、
debug / validation 用に残しやすい。

最終的には damage/hit などを足していくが、
bridge の first version はこの程度でよい。

## 4. Why This Is Enough For Step 6

step 6 の目的は、
Godot front を TypeScript core へ接続できる形まで
仕様を圧縮することである。

そのために本当に必要なのは:

1. Godot が 1 actor 分の command を渡せること  
2. TypeScript がその actor の local resolve を進められること  
3. 返り値を UI/animation/debug に使えること  

であって、
`D400/D500` の全 field や
`C200/C7EE` scratch の完全 mirror ではない。

つまり step 6 で先に固定すべき bridge は:

```ts
resolveActorCommand(input: BattleCommandInput): ActorResolveResult
```

のような **actor-local entrypoint** だと考えるのが自然。

## 5. Best Current First-Version API

現時点の safest first-version は次の程度。

```ts
type BattleCommandInput = {
  actorIndex: number
  action: BattleActionHead
}

type ActorResolveResult = {
  actorIndex: number
  branch: ActionPhaseBranch
  target: number
}

function resolveActorCommand(
  input: BattleCommandInput
): ActorResolveResult
```

内部では:

1. current player / actor を確定
2. local outcome / branch を decode
3. `kindId/arg` で local path を開く
4. candidate-selection RNG (`slot 07/08`) を必要なら消費
5. `target/slotIndex` routing を進める

という順に実装していくのが自然。

## 6. What Still Remains Outside The Bridge

この first-version bridge の外に残る未確定は次の通り。

- `019E` local outcome の最終意味
- hit / damage / order で使う残り RNG slot
- `arg` の正式 rename
- `target` と `slotIndex` の battle-side routing 詳細

ただし、これらは bridge を立てる前提条件ではなく、
**bridge の内側実装を精密化する課題**
として持てる。

## Implication
- step 6 に向けて今固定すべきなのは `resolveActorCommand(input)` 型の actor-local bridge
- Godot は `actorIndex + BattleActionHead` を渡せれば first version を始められる
- TypeScript は `branch` と `target` を first-line result として返す構造から実装を始められる
