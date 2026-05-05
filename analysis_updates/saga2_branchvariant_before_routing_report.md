# Saga2 BranchVariant-Before-Routing Report

## 要点

- current best reading では、`PTR` false 側では **`branchVariant` が先に決まり、その後で strict fallback branch の後段 routing が走る** とみるのが最も自然である
- 理由は、ここまでの narrowing で `candidateOffset` の first semantic use を target resolution ではなく branch shaping に寄せており、`branchVariant` を direct image とみる以上、その決定が routing より先に来るほうが flow に整合するからである
- したがって current best bias は、`PTR` false 側の順序は  
  - `candidateOffset bucket`  
  - `branchVariant 0/1`  
  - strict fallback post-branch routing  
 という 3 段で持つのが safest である

## 1. Why Routing-After-Variant Fits Better Than Parallel Resolution

もし routing と `branchVariant` が同時に決まるなら、
それは `candidateOffset` の役割を再び target-oriented に引き戻すことになる。

しかし current best reading では、
`candidateOffset` の false-side role はすでに

- offset-aware candidate entry
- branch choice shaping
- branch code variant
- direct mapping to `branchVariant 0/1`

まで狭まっている。

このため、もっとも軽い仮説は
**variant first, routing second**
である。

## 2. Why This Still Preserves Shared Branch Structure

この整理は、

- shared `branch`
- optional PTR-only `branchVariant`

という provisional shape ともよく噛み合う。

つまり first-line の consumer order は:

1. `branch`
2. `branchVariant?`
3. post-branch routing

であり、`ATK` 側では `2.` が空になるだけ、
とみるのが自然である。

この読みなら `ATK/PTR` の共通部分と差分がかなりきれいに分かれる。

## 3. Provisional Meaning

現時点の safest provisional reading は次のように書ける。

```ts
type CombatDecisionConsumerResult = {
  accepted: boolean
  branch: number
  branchVariant?: 0 | 1
  fallbackKind?: "strict-path"
  bypassesCurrentConsumeBelt?: boolean
}
```

そして current best bias では、
`PTR` false 側の consumer order は

```ts
branchVariant = candidateOffsetBucket
routeAfterBranchVariant(branch, branchVariant)
```

のように読むのが自然である。

## implication for step 6

この整理を採ると、step 6 の TypeScript provisional shape では
`combatDecision` 自体に routing 結果を混ぜ込まず、

- `branch`
- optional `branchVariant`

までを `combatDecision` で返し、
後段でそれを受けて routing を進める分離がかなり自然になる。

これは current `resolveActorCommand(...)` skeleton にもきれいに乗せやすい。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `PTR` false 側で `branchVariant` 決定後にだけ post-branch routing が走るか
2. `ATK` false 側は `branchVariant` なしで同じ routing step に入れるか
3. routing 側は `branchVariant` の結果を見るだけで、再び `candidateOffset` を直接読まないか

ここが取れれば、`combatDecision` は
**shared branch + optional PTR-only `branchVariant?: 0 | 1` + routing-after-variant order**
としてかなり直接実装へ落とせる。
