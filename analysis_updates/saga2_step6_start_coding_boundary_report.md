# SaGa2 Step6 Start-Coding Boundary Report

## Summary
- 現時点では、battle/RNG 解析はまだ完全終了していないが、**step 6 の first coding を始める境界** はかなり明確になっている。
- その境界は「damage/hit の完全意味論が解けること」ではなく、**actor-local bridge の入出力が provisional でも安定していること** にある。
- したがって、今の safest 判断は **TypeScript core の skeleton 実装を開始してよい** であり、ROM 側の次の解析は `combatDecision` hook の一点へ絞って並走させるのが最も効率的である。

## 1. Stable Enough To Code Now

今の evidence で、先にコードへ落としてよいものは次の通り。

1. `BattleActionHead`
```ts
type BattleActionHead = {
  kindId: number
  arg: number
  target: number
  slotIndex: number
}
```

2. actor-local entrypoint
```ts
type BattleCommandInput = {
  actorIndex: number
  action: BattleActionHead
}
```

3. actor-local result
```ts
type ActorResolveResult = {
  actorIndex: number
  branch: number
  target: number
  didConsumeCandidateRng: boolean
  combatDecision?: {
    shouldConsumeCounter: boolean
    debugSource?: "unresolved_local_policy"
  }
}
```

4. internal 3-stage skeleton
- `branch/path`
- `candidate RNG`
- `combatDecision`

これらは battle-side の既報と十分整合している。

## 2. What Must Stay Provisional

逆に、今コードへ落とすときも provisional 扱いのままにすべきものは次の 3 点。

1. `combatDecision` の exact battle meaning  
2. hit/miss の final semantics  
3. damage spread / final amount の semantics  

つまり「未確定だから実装禁止」なのではなく、
**型と hook は先に置くが meaning は後で強化する**
という扱いが正しい。

## 3. Best Current Coding Boundary

今の safest coding boundary はこの 1 本で表せる。

```ts
function resolveActorCommand(
  input: BattleCommandInput
): ActorResolveResult
```

内部は:

```ts
const branch = decodeResolvedOutcome(...)
const localPath = selectLocalActionPath(...)
const candidate = maybeBuildPointerCandidateWithRng07_08(...)
const target = routeTarget(...)
const combatDecision = resolveCombatRngAfterLocalPath(...)
```

ここで `resolveCombatRngAfterLocalPath(...)` だけを
unresolved hook に残せばよい。

## 4. Why Waiting Longer Is Lower Leverage

もしここで

- full hit formula
- full damage formula
- all RNG slots

の確定を待つと、
Godot 側も TypeScript 側も止まってしまう。

しかし現在の解析はすでに:

- input head
- actor-local phase
- candidate-selection RNG
- local decision hook

まで切れている。

つまり、今止まる理由より
**今 skeleton を書く理由のほうが強い**。

## 5. Recommended Immediate Move

したがって、次の具体的な着手は次の順になる。

1. TypeScript で `BattleActionHead`, `BattleCommandInput`, `ActorResolveResult` を定義  
2. `resolveActorCommand(...)` の skeleton を作る  
3. `decodeResolvedOutcome`, `selectLocalActionPath`, `routeTarget` を空実装または stub でつなぐ  
4. `resolveCombatRngAfterLocalPath(...)` は provisional hook として残す  
5. 並行して ROM 側では `41E7-41E9 -> 41EB-41EC` の 2 点確認を続ける  

## Implication
- step 6 はもう「解析待ち」ではなく「skeleton 実装開始」の段階
- unresolved は `combatDecision` 1 点へかなり集約されている
- 次は実装を始めつつ、ROM 側確認をその hook に集中させるのが最短である
