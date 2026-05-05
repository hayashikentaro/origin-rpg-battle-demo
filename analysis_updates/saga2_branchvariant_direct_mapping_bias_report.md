# Saga2 BranchVariant Direct-Mapping Bias Report

## 要点

- current best reading では、`PTR` false 側の `candidateOffset` 2-way bucket は **別の中間 state を経由する** より、まず **`branchVariant 0/1` へほぼ直接写る** とみるのが最も自然である
- 理由は、ここまでの narrowing で `candidateOffset` の false-side role を  
  - offset-aware candidate entry  
  - branch choice shaping  
  - small-cardinality refinement  
  - 2-way bucket  
まで縮めており、これ以上あいだに別の hidden selector 層を入れる根拠が current evidence では弱いからである
- したがって current best bias は、`PTR` false 側の unresolved refinement は  
  - `candidateOffset` を 2-way bucket に畳み  
  - その bucket をそのまま `branchVariant 0/1` に写す  
 という direct mapping にかなり寄っている

## 1. Why Direct Mapping Fits The Current Narrowing

既報では `PTR` false 側の特殊性を順に

- shared strict fallback policy
- PTR-only `branchVariant`
- small-cardinality refinement
- `candidateOffset` 2-way bucket

へ狭めてきた。

この流れを素直に延長すると、
最も軽い仮説は
**2-way bucket = branchVariant 0/1**
である。

もしこの間に別の hidden translation layer を置くなら、
それは再び evidence より一歩先に出る仮説になる。

## 2. Why This Still Leaves Room For Later Structure

この整理は、
後から branchVariant の意味論が richer になる可能性を否定しない。

ただし current safest reading では、
first-line の実装や解析メモでは

- `candidateOffset bucket 0 -> branchVariant 0`
- `candidateOffset bucket 1 -> branchVariant 1`

という direct mapping で持つのがいちばん自然である。

より複雑な解釈は、
後で battle 本線の追加 evidence が取れた時点で
二段階目に載せればよい。

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

そして `PTR` false 側の first-line bias は:

```ts
branchVariant = candidateOffsetBucket
```

である。

## implication for step 6

この整理を採ると、step 6 では `combatDecision` を

- shared `branch`
- optional PTR-only `branchVariant?: 0 | 1`

として置くだけでなく、
その `branchVariant` を
**candidateOffset の 2-way bucket の direct image**
として扱える。

これは TypeScript 実装にかなり落としやすく、
debug matrix にも自然に反映しやすい。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `candidateOffset bucket 0/1` がそのまま `branchVariant 0/1` と読めるか
2. `branchVariant` 決定後に初めて strict fallback branch の後段 routing が走るか
3. `ATK` false 側はこの direct mapping を持たず、`branchVariant` 自体が不要か

ここが取れれば、`combatDecision` は
**shared branch + optional PTR-only `branchVariant?: 0 | 1`**
としてかなり直接実装へ落とせる。
