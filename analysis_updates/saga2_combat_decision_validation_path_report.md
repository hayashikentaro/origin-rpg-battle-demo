# SaGa2 Combat-Decision Validation Path Report

## Summary
- `combatDecision.shouldConsumeCounter` 仮説を次に前進させるには、battle 本線での確認点を **`RNG enters local decision slot`** と **`decision controls consume/writeback`** の 2 本に固定するのが最も効率的である。
- この 2 本は、そのまま TypeScript first-version 実装の debug/validation point にも対応するため、解析と実装を並行で進めやすい。
- したがって次の作業単位は、damage/hit の完全意味論を急ぐことではなく、**`combatDecision` を provisional result として実装し、battle 本線でその正当性を確かめる道筋を作ること** になる。

## 1. Two Concrete Verification Questions

いま battle 本線で本当に確認したいことは 2 点だけでよい。

1. `41E7-41E9` 相当の local decision slot に  
   `FF00 / 0300 / 0F00 / 0100` の raw/small-range RNG が入るか
2. その返り値が  
   `41EB-41EC` の consume/writeback 実行可否へつながるか

この 2 点が通れば、
`combatDecision.shouldConsumeCounter`
という first recovered semantics はかなり強くなる。

## 2. Why This Is Enough Before Hit/Damage

今の battle-side evidence は、
まだ final hit rate や damage spread そのものまでは届いていない。

しかし:

- actor-local phase は `04/05`
- priority window は `41A4-41F1`
- inner belt は `41D9-41EC`
- micro-slot は `41E7-41E9`

まで狭まっている。

この段階で無理に larger semantics を足すより、
まず `combatDecision` の true/false が
local consume/writeback を支配することを取るほうが
false positive を減らしやすい。

## 3. Best Current Debug Shape In TypeScript

first-version 実装では、
`combatDecision` を結果に載せつつ
debug 用に source を残すのが自然。

```ts
type CombatDecision = {
  shouldConsumeCounter: boolean
  debugSource?: "unresolved_local_policy"
}

type ActorResolveResult = {
  actorIndex: number
  branch: ActionPhaseBranch
  target: number
  combatDecision?: CombatDecision
}
```

ここで `debugSource` は、
後で `hit`, `damage`, `reroute` などへ意味が分化したときに
置換しやすい。

## 4. Best Current Internal Stub

内部の provisional 実装は次の程度で十分である。

```ts
function resolveCombatRngAfterLocalPath(...): CombatDecision | undefined {
  return {
    shouldConsumeCounter: false,
    debugSource: "unresolved_local_policy",
  }
}
```

この stub は ROM 完全再現ではないが、
battle 本線の next frontier を正確に表している。

## 5. What To Search Next In ROM Terms

次の ROM 側探索では、
callsite を広く増やすより
次のような narrow checklist で見るのがよい。

1. `41E7-41E9` 近傍に入る small-range/raw RNG helper
2. その戻り値を即 compare / branch する micro-branch
3. その branch の片側だけが `41EB-41EC` に到達する構造

これが見つかれば、
`combatDecision.shouldConsumeCounter`
はかなり高い確度で採用できる。

## 6. What This Unlocks Next

この確認が取れたあとはじめて、
次の larger semantics に進む順番が自然になる。

1. `consumeCounter`
2. `advanceCandidate`
3. `hit/miss`
4. `damage spread`

つまり `combatDecision` は終点ではなく、
larger combat semantics へ入るための最初の足場である。

## Implication
- 次の battle/RNG 解析は `combatDecision` の 2 点確認に集中してよい
- TypeScript 側は `combatDecision` を provisional result として先に持たせてよい
- hit/damage の本格確定はその次段に置くのが安全
