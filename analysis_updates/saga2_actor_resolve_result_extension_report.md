# SaGa2 `ActorResolveResult` Extension Report

## Summary
- ここまでの narrowing を TypeScript 側へ戻すと、`resolveActorCommand(input)` の返り値には `branch` と `target` だけでなく、**first recovered combat semantics としての small decision bit** を暫定で持たせるのが自然である。
- その bit は現時点では first-line で **`shouldConsumeCounter`**、second line で **`shouldAdvanceLocalCandidate`** に読めるため、battle 本線の実探索と core 実装をずらさずに進められる。
- したがって step 6 に向けた first-version bridge は、`damage` 数値を返さなくても、**`branch + target + optional combatDecision`** まで返す形で十分前進できる。

## 1. Why Result-Side Extension Helps

既報の current shape は:

```ts
type ActorResolveResult = {
  actorIndex: number
  branch: ActionPhaseBranch
  target: number
}
```

だった。

しかし現在の battle-side 読みでは、
`resolveCombatRngAfterLocalPath(...)` から最初に回収できそうなのは
damage amount ではなく
**local consume/accept policy**
である。

このため結果側にも、
次のような軽い拡張を入れるのが自然になる。

## 2. Safe First Extension

first-line では次で十分である。

```ts
type CombatDecision = {
  shouldConsumeCounter: boolean
}

type ActorResolveResult = {
  actorIndex: number
  branch: ActionPhaseBranch
  target: number
  combatDecision?: CombatDecision
}
```

second line としては:

```ts
type CombatDecision = {
  shouldConsumeCounter: boolean
  shouldAdvanceLocalCandidate?: boolean
}
```

まで許容できるが、
現時点では 1bit 相当の small policy で始めるのが safest である。

## 3. Why This Is Better Than Returning Damage Too Early

今の証拠では:

- slot `07/08` は candidate-selection
- slot `33` は particle
- damage 主線にはまだ `016B/043E` 未検出
- `41E7-41E9` 相当が本命 decision slot

なので、
ここで無理に

- `damage`
- `hit`
- `miss`

を result 型へ固定すると overreach になりやすい。

いっぽう `combatDecision` なら、
`41E7-41E9` 相当の local policy 読みときれいに噛み合う。

## 4. Best Current First-Version API

step 6 に向けた first-version bridge は、
現時点では次の程度がもっとも実装しやすい。

```ts
type BattleCommandInput = {
  actorIndex: number
  action: BattleActionHead
}

type CombatDecision = {
  shouldConsumeCounter: boolean
}

type ActorResolveResult = {
  actorIndex: number
  branch: ActionPhaseBranch
  target: number
  combatDecision?: CombatDecision
}

function resolveActorCommand(
  input: BattleCommandInput
): ActorResolveResult
```

内部の順序は:

1. branch decode
2. local path open
3. optional candidate-selection RNG (`07/08`)
4. target/slot routing
5. optional combat decision resolve

となる。

## 5. What This Changes For The Next Search

この結果型を先に持っておくと、
次の battle/RNG 解析で本当に確認すべき点も 2 つに縮む。

1. `combatDecision.shouldConsumeCounter` に相当する bit が battle 本線で見えるか  
2. その bit が `41EB-41EC` の consume/writeback 可否へつながるか  

この 2 点が取れれば、
その次に larger semantics (`hit`, `damage`) を追加すればよい。

## Implication
- `ActorResolveResult` は first version で `combatDecision` を optional に持たせるのが自然
- 最初に回収できる combat semantics は damage 値より small decision bit である
- 次の battle/RNG 解析と TypeScript 実装を同じ仮説の上で進めやすくなる
