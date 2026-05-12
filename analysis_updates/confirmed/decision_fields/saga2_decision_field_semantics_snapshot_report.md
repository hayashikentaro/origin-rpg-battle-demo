# Saga2 Decision-Field Semantics Snapshot Report

## 要点

- current best reading では、5 段 provisional API の中でも `accepted / branch / branchVariant` はすでに **shape だけでなく first-line semantics** までかなり絞れている
- ただしこれは exact recovered semantics ではなく、battle-side evidence から得られた **current safest bias** として持つのが適切である
- したがって現時点では  
  - `accepted` = local candidate accept/reject  
  - `branch` = shared strict-fallback branch family  
  - `branchVariant` = PTR-only strict-fallback refinement  
 という 3 本で読むのが最も自然である

## 1. `accepted`

`accepted` の current best reading は、
damage amount や final hit/miss ではなく
**special-candidate family candidate をこの local opener で通すかどうか**
にある。

既報では false 側について

- current consume belt を開かない
- strict-path 側へ残る
- local fallback を起こす

という bias が強いため、
`accepted=false` は
**this candidate is not admitted into the current consume path**
と読むのが safest である。

したがって `accepted` は first-line では
hit/damage 結果ではなく
**local accept-policy bit**
として持つのが自然になる。

## 2. `branch`

`branch` の current best reading は、
battle round 全体の phase ではなく
**actor-local strict-fallback branch family**
である。

これは:

- `accepted` の直後に読むのが自然
- `ATK` と `PTR` で shared に保ちやすい
- `branchVariant` を下位 refinement として足しやすい

という 3 点からも整合する。

したがって `branch` は first-line では
**shared local fallback branch selector**
とみるのが safest である。

## 3. `branchVariant`

`branchVariant` は current best reading では
`PTR` false-side にだけ現れる optional refinement であり、
その source は

- `candidateOffset`
- 2-way bucket
- direct mapping

にかなり寄っている。

したがって exact semantics より前の first-line では、
これは
**PTR-only strict-fallback sub-branch selector**
とみるのが自然になる。

つまり `branchVariant` は generic optional field ではなく、
current best bias では
`PTR` path が candidate-flavored branch reopening を行うための
最小 refinement として持つのが安全である。

## 4. Safest Current Reading In One Shape

現時点の safest reading は次のように要約できる。

```ts
type CombatDecision = {
  // special-candidate family candidate is admitted into current local consume path
  accepted: boolean

  // shared actor-local strict-fallback branch family
  branch: number

  // PTR-only sub-branch refinement (current best bias: 0 | 1)
  branchVariant?: 0 | 1
}
```

この shape では、
`accepted`
が policy bit、
`branch`
が shared branch family、
`branchVariant`
が PTR-only refinement
という役割分担になる。

## implication for step 6

この整理を採ると、step 6 では `combatDecision` を
ただの unresolved blob として持つ必要はかなり薄い。

少なくとも first-line では:

- `accepted` = local accept-policy bit
- `branch` = shared fallback branch family
- `branchVariant` = PTR-only refinement

として code / debug / docs をそろえてよい。

つまり次の battle-side 解析は、
shape の再検討より
**各 field の exact meaning を recovered semantics へ押し上げる作業**
に集中できる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `accepted=true` 側が current consume path への admission と読んでよいか
2. `branch` が strict-fallback branch family のどの分類に当たるか
3. `branchVariant 0/1` の exact battle-side meaning が pointer-origin / target-origin のどちらに強く依るか

ここが取れれば、`combatDecision` は provisional shape から field-level recovered semantics にかなり近づく。
