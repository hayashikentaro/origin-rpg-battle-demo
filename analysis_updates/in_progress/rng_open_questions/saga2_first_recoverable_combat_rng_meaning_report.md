# SaGa2 First-Recoverable Combat-RNG Meaning Report

## Summary
- ここまでの narrowing を踏まえると、battle 本線から最初に回収できる `combat RNG` の意味は、`damage amount` や `hit rate` そのものより **`local consume/accept policy`** に寄るとみるのが最も自然である。
- 具体的には、`41E7-41E9` 相当の sentinel gate の直後にあるはずの narrow slot は、first-line では **`shouldConsumeCounter`**、second line では **`shouldAdvanceLocalCandidate`** のような small decision を返すと考えるのが安全である。
- したがって次の実探索も、いきなり damage 式へ飛ぶのではなく、**actor-local consume policy を決める RNG hook** を battle 本線で探す方針でぶれなくてよい。

## 1. Why This Is More Natural Than Damage-First

現時点で battle-side の高確度整理はこうなっている。

1. slot `07/08` は candidate-selection 専用
2. slot `33` は particle/effect 専用
3. known damage/writeback 主線には `016B/043E` 未検出
4. `04/05` local phase の中でも `41E7-41E9` 相当が本命 decision slot

この状況では、
最初に見つかる `combat RNG` を

- final damage amount
- direct hit/miss bit

とみなすより、

- local candidate を消費するか
- local counter を進めるか
- local accept/reject を切るか

のような **small local policy**
とみるほうが battle state machine にきれいに乗る。

## 2. Best Current First-Line Meaning

first-line では次のように置ける。

```ts
type CombatDecision = {
  shouldConsumeCounter: boolean
}
```

second line としては:

```ts
type CombatDecision = {
  shouldConsumeCounter: boolean
  shouldAdvanceCandidate?: boolean
}
```

まで許容できる。

ただし current evidence では、
まずは **1bit 相当の local consume policy**
として持つのが最も軽くて安全である。

## 3. Where This Sits In Core

TypeScript core の順序に落とすと、
現在の safest internal shape は次になる。

```ts
const branch = decodeResolvedOutcome(playerIndex, outcomeLikeByte)
const localPath = selectLocalActionPath(kindId, arg)
const candidate = maybeBuildCandidateWithRng07_08(localPath)
const routedTarget = routeTarget(target, slotIndex, candidate)
const combatDecision = resolveCombatRngAfterLocalPath(...)

if (combatDecision.shouldConsumeCounter) {
  consumeLocalCounter(...)
}
```

この段階では、
`resolveCombatRngAfterLocalPath(...)` の返り値を
damage 数値まで膨らませる必要はない。

## 4. What This Unlocks

この整理で、step 6 に向けた first-version 実装はさらに進めやすくなる。

Godot 側は依然:

- `actorIndex`
- `BattleActionHead`

を渡せばよく、
TypeScript 側は:

- `branch`
- `target`
- optional `combatDecision`

まで返せば debug/validation を始められる。

つまり battle core の first recovered combat semantics として、
**small decision bit**
を採用してよい見通しが立つ。

## 5. What To Confirm Next

次に battle 本線で確認したいのは 2 点だけに絞れる。

1. `41E7-41E9` 相当の local decision slot に本当に raw/small-range RNG が入るか
2. その返り値が `consume/writeback` 可否へつながるか

この 2 点が取れれば、
その次に初めて

- hit/miss
- damage spread

の larger combat semantics へ広げればよい。

## Implication
- first recovered combat RNG meaning は `shouldConsumeCounter` 的な small policy とみるのが最も自然
- damage/hit 本体はその後段に置くのが安全
- 次の battle/RNG 解析は local consume policy hook の確認に集中してよい
