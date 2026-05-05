# Saga2 Post-Branch Routing No-Offset-Reuse Report

## 要点

- current best reading では、`PTR` false 側の post-branch routing は **`candidateOffset` を再び直接読む** より、まず **`branch` と `branchVariant` の結果だけを受けて進む** とみるのが最も自然である
- 理由は、ここまでの narrowing で `candidateOffset` の first semantic use を `branchVariant` 生成まで押し上げており、その後段 routing が再び raw offset に戻ると、`branchVariant` を置く意味がかなり弱くなるからである
- したがって current best bias は、`PTR` false 側の順序は  
  - `candidateOffset bucket`  
  - `branchVariant 0/1`  
  - `branch/branchVariant` を入力とする post-branch routing  
 であり、routing 側は raw `candidateOffset` の再読を first-line では必要としない

## 1. Why Re-reading Raw Offset Would Be Too Strong

もし post-branch routing が `candidateOffset` を再び直接読むなら、
それは `branchVariant` を経由せずに raw path-specific payload を後段へ持ち込み続けることになる。

しかし current best reading では、
`candidateOffset` の false-side role はすでに

- offset-aware candidate entry
- branch choice shaping
- direct mapping to `branchVariant 0/1`

まで narrowed されている。

このため、もっとも軽い仮説は
**raw offset の役割は branchVariant 生成でいったん終わる**
という読みである。

## 2. Why This Makes The Consumer Boundary Cleaner

この整理を採ると、consumer boundary はかなり明快になる。

- `combatDecision` 側が受け持つのは  
  `accepted / branch / branchVariant`
- routing 側が受け持つのは  
  その決定済み branch 情報を使った後段分岐

となる。

つまり `PTR` の path-specific 情報は
raw offset のまま後段に漏れるのではなく、
**branchVariant へ要約された形でだけ**
後段へ伝わる。

これは `ATK` 側との共通化にもかなり有利である。

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
post-branch routing の入力は

```ts
routeAfterDecision(branch, branchVariant)
```

で十分であり、

```ts
routeAfterDecision(branch, branchVariant, candidateOffset)
```

のような raw offset 再注入は first-line では不要とみるのが自然である。

## implication for step 6

この整理を採ると、step 6 の TypeScript provisional shape では
`combatDecision` が返すべきものを

- `accepted`
- `branch`
- optional `branchVariant`

にかなりきれいに閉じられる。

つまり routing hook は
`combatDecision` の結果を受ける後段として分離でき、
`candidateOffset` は `combatDecision` 内部の unresolved material に閉じ込めてよい。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. post-branch routing が `branch/branchVariant` だけで十分説明できるか
2. `candidateOffset` の raw 値は false 側では branchVariant 生成後に不要になるか
3. `ATK` と `PTR` の routing 共通化もこの境界で成立するか

ここが取れれば、`combatDecision` は
**accepted + shared branch + optional PTR-only branchVariant**
としてかなり直接実装へ落とせる。
