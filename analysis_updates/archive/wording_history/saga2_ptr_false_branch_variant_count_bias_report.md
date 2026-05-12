# Saga2 PTR False-Branch Variant Count Bias Report

## 要点

- current best reading では、`PTR` false 側の `candidateOffset` は **単一の strict fallback branch** を選ぶだけでなく、**`ATK` false 側より branch variant 数を増やす bias** を持つとみるのが最も自然である
- 理由は、`ATK` false 側では path-specific payload が乏しい一方、`PTR` false 側は `candidateOffset` という追加 selector material を保持しており、これを branch code shaping に使うなら first-line の差分は分岐先の細分化として現れるのが自然だからである
- したがって current best bias は、`PTR` false 側は  
  - shared strict fallback policy を保ちながら  
  - `ATK` false 側より細かい branch code variant を持つ  
 という形になる

## 1. Why Variant Count Matters More Than Target Recompute

既報では `PTR` false 側の unresolved 部分を

- `targetSource` recompute
- final target routing

より、

- branch choice shaping

に重みを置いてきた。

この前提では、`candidateOffset` が first-line で生む差分は
最終 target より先に
**どの branch code へ落ちるか**
に出るはずである。

もし `PTR` false 側が `ATK` false 側と同じ branch code を常に使うなら、
`candidateOffset` を false 側で保持する意味はかなり弱くなる。

このため safest reading は、
`candidateOffset` の存在は
まず **branch variant 数の増加**
として現れるとみることである。

## 2. Why This Still Preserves Shared Policy

ここで variant 数が増えるというのは、
policy 自体が `ATK` と別物になるという意味ではない。

current best reading では shared な部分はそのまま残る:

- `accepted=false`
- `bypassesCurrentConsumeBelt=true`
- `fallbackKind="strict-path"`

そのうえで `PTR` だけが

- `fallbackEntryFlavor="candidate"`
- `preservesCandidateOffsetInitially=true`
- `candidateOffsetShapesFalseBranchCode=true`

を持つため、
同じ strict fallback policy の内側で
**細かい branch variant**
が増える、と読むのが自然になる。

## 3. Provisional Meaning

現時点の safest provisional reading は次のように書ける。

```ts
type CombatDecisionConsumerResult = {
  accepted: boolean
  branch: number
  fallbackKind?: "strict-path"
  bypassesCurrentConsumeBelt?: boolean
  fallbackEntryFlavor?: "candidate"
  preservesCandidateOffsetInitially?: true
  usesCandidateOffsetForFallbackBranch?: true
  candidateOffsetShapesFalseBranchCode?: true
  hasMoreFalseBranchVariantsThanAttack?: true
}
```

この意味では `PTR` false 側の specialness は、
policy を変えることではなく
**strict fallback branch space を細分化すること**
にある。

## implication for step 6

この整理を採ると、step 6 の battle/core bridge では
`PTR` false 側を

- special reject policy

として別扱いする必要はなく、

- shared reject policy
- expanded branch-space bias

として持つのが自然になる。

つまり `combatDecision` の unresolved 部分は、
`ATK` と `PTR` で boolean policy が違うのかではなく、
**false-side branch-space がどの程度広いか**
を見る方向へさらに絞れる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `PTR` false 側の branch code が `ATK` false 側より多くの variant を持つか
2. その variant 差が `candidateOffset` の値域差に対応するか
3. variant 決定後に初めて target routing / targetSource recompute が走るか

ここが取れれば、`PTR` false 側は
**shared strict fallback policy with expanded branch-space**
としてかなり実装寄りに固められる。
