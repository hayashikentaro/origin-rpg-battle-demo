# Saga2 ATK False BranchVariant Absence Bias Report

## 要点

- current best reading では、`ATK` false 側には **独立した `branchVariant` は実質不要** とみるのが最も自然である
- 理由は、`ATK` false 側には `PTR` のような `candidateOffset` 由来の path-specific payload が見えておらず、shared strict fallback policy だけで first consumer を説明しやすいからである
- したがって current best bias は、false 側の `combatDecision` shape は  
  - `ATK` = `branch` だけで十分  
  - `PTR` = `branch + branchVariant` が必要  
 という非対称構造で持つのが safest である

## 1. Why ATK Does Not Need A Separate Variant Layer

既報では `ATK` と `PTR` の false 側は、

- `accepted=false`
- `bypassesCurrentConsumeBelt=true`
- `fallbackKind="strict-path"`

という shared policy を持つと整理している。

この shared policy のうち、`PTR` だけがさらに細かく分かれる理由は

- `fallbackEntryFlavor="candidate"`
- `candidateOffset`
- offset-range-partitioned branch-space

という追加 payload があるためである。

一方 `ATK` false 側には、
そのような path-specific selector material がまだ見えていない。

このため safest reading は、
`ATK` false 側では
**shared branch だけで first consumer を説明できる**
とみることである。

## 2. Why This Supports An Optional Variant Field

この整理は、
`PTR` false 側にだけ `branchVariant` を置く形ときれいに噛み合う。

つまり current best reading は:

- `branch` = shared strict fallback branch
- `branchVariant` = PTR-only refinement

という 2 層構造であり、
全 path に variant を要求する必要はまだない。

したがって TypeScript provisional shape でも
`branchVariant` は required field ではなく
**optional field**
として持つのが自然になる。

## 3. Provisional Meaning

現時点の safest provisional reading は次のように書ける。

```ts
type CombatDecisionConsumerResult = {
  accepted: boolean
  branch: number
  branchVariant?: number
  fallbackKind?: "strict-path"
  bypassesCurrentConsumeBelt?: boolean
}
```

その上で current best bias は:

```ts
// ATK false side
accepted === false
branchVariant === undefined

// PTR false side
accepted === false
branchVariant !== undefined
```

である。

もちろん今後 `ATK` 側にも hidden refinement が見つかる可能性はある。
ただし current evidence では first-line bias をそこまで上げる根拠は薄い。

## implication for step 6

この整理を採ると、step 6 の `combatDecision` は
かなり自然に

- shared `branch`
- optional `branchVariant`

へ落とせる。

しかも `branchVariant` は generic refinement ではなく、
まずは **PTR false-side strict fallback refinement**
として読むのが安全である。

これは current debug matrix と self-check の差分観測にもかなり合う。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `ATK` false 側に hidden `branchVariant` が要る根拠が本当にないか
2. `PTR` false 側だけが `branchVariant` を必要とするなら、その variant 数は何段階か
3. `branchVariant` 決定後に target routing が二次的に再開されるか

ここが取れれば、`combatDecision` は
**shared branch + optional PTR-only branchVariant**
としてかなり実装寄りに固められる。
