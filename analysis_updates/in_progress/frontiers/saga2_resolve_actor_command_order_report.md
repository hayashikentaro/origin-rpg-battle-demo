# SaGa2 `resolveActorCommand` Implementation-Order Report

## Summary
- 既報を battle-side の実装順へ並べると、`resolveActorCommand(input)` の first version は **`kindId/arg` による local path/class 選択** を先に行い、その後に **slot `07/08` の candidate-selection RNG** を必要な path でだけ消費する形で持つのが最も安全である。
- 逆に、slot `07/08` の次に来る hit/damage 系 RNG は、現時点では **未確定の別系統** として分離しておくべきであり、first version API では無理に同じ段へ混ぜないほうが安全である。
- したがって step 6 に向けた core 実装順は、`path select -> candidate RNG -> later routing -> unresolved combat RNG` の 4 段として持つのが自然になる。

## 1. `kindId/arg` Should Open The Path First

既報から高確度に言えるのは次の 2 点。

1. `D?43-46` / `C1A5-C1AC` は `BattleActionHead(kindId, arg, target, slotIndex)` として十分 API 化できる  
2. actor-local opener 帯では、`target/slotIndex` より **`kindId/arg` が先に local path/class 選択へ効く** とみるのが自然  

その理由は:

- `43FB-443A` が 8byte record の class bits を畳み込む prepass
- `443B-4499` が pointer-candidate builder

であり、どちらもまず
**action kind / class / parameter**
の解釈を必要としているからである。

first-line pseudocode は次の順になる。

```ts
const localPath = selectLocalActionPath(action.kindId, action.arg)
```

## 2. slot `07/08` Belongs To Candidate Selection

既報 `443B-4499` から、slot `07/08` は:

- 上位 byte / 下位 byte を別々に引く
- 16bit signed offset を組む
- base pointer から candidate record を選ぶ

と読むのが自然だった。

したがって first version 実装では:

```ts
if (pathNeedsCandidateSelection(localPath)) {
  const candidate = buildPointerCandidateWithRng07_08(...)
}
```

とし、
**すべての command が必ず 07/08 を消費する**
と決め打ちしないほうが安全である。

## 3. What Comes After `07/08` Is Still Split

ここで重要なのは、
`07/08` のあとに続く RNG をまだ 1 本化しないこと。

現時点で高確度に言えるのは:

- slot `33` は particle/effect 側
- slot `07/08` は candidate/pointer selection 側
- pass21-23 の damage 主線候補には `016B/043E` が未検出

という 3 点である。

したがって、
`07/08` の直後に:

- hit RNG
- damage RNG
- target reroll RNG
- order RNG

のどれが来るかは **まだ別系統** として持つのが安全。

first version 実装では、
ここを未確定 extension point にしておくのが自然である。

```ts
const unresolvedCombatRng = {
  hit: null,
  damage: null,
  reroute: null,
  order: null,
}
```

## 4. Safe First-Version Order

いまの evidence だけで安全に書ける順序は次の通り。

```ts
function resolveActorCommand(input: BattleCommandInput): ActorResolveResult {
  const branch = decodeResolvedOutcome(input.actorIndex, input.outcomeLikeByte)

  const localPath = selectLocalActionPath(
    input.action.kindId,
    input.action.arg
  )

  const candidate =
    pathNeedsCandidateSelection(localPath)
      ? buildPointerCandidateWithRng07_08(...)
      : null

  const routedTarget = routeTarget(
    input.action.target,
    input.action.slotIndex,
    candidate
  )

  return {
    actorIndex: input.actorIndex,
    branch,
    target: routedTarget,
  }
}
```

この形なら:

- `kindId/arg`
- `slot 07/08`
- `target/slotIndex`

の現在の証拠をそのまま使える。

## 5. What To Parse Next

この整理で、次の解析 target もかなり明確になる。

1. `kindId/arg` が開く `localPath` の種類  
2. どの `localPath` が `07/08` candidate-selection を必要とするか  
3. その後ろに来る hit/damage 系 RNG の別 slot  

つまり次の battle/RNG 解析は、
**`07/08` の続きを探す** というより
**`07/08` とは別の combat RNG frontier を探す**
と考えるほうが筋がよい。

## Implication
- `kindId/arg` は first version で local path/class selector として先に実装してよい
- slot `07/08` は path-dependent candidate-selection RNG として限定的に実装するのが安全
- hit/damage 系 RNG は未確定の別 frontier として切り離して持つのが自然
