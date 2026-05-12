# Saga2 BranchVariant Second-Line Carry Report

## 要点

- current best reading では、shared `branchVariant 0/1` は first-line の decision layer だけで完結するより、**second-line reopening にもそのまま持ち越される** とみるのが最も自然である
- 理由は、`PTR` の path-specific 差分を first-line で `branchVariant` に要約したあと、second-line で candidate-flavored `targetSource / pointerFlavor / target` が reopening する以上、その reopening も `branchVariant` の結果を受けていると読むほうが flow に合うからである
- したがって current best bias は、`branchVariant` は  
  - decision layer の PTR-only optional refinement  
 であると同時に  
  - second-line reopening の shape を条件づける carried refinement  
 として持つのが safest である

## 1. Why BranchVariant Should Carry Into Second-Line

既報では current frontier を

1. `combatDecision`
2. `postBranchRoute`
3. `postBranchTargetSource`
4. `pointerFlavor`
5. `target`

という 5 段に整理している。

このうち `PTR` の specialness は、
first-line では `branchVariant`
へ narrow 化され、
second-line では candidate-flavored reopening
として現れている。

もし `branchVariant` が second-line に全く影響しないなら、
`PTR` 側の first-line refinement と second-line reopening は
別々の偶然な差分になってしまう。

しかし current best reading では、
両者は同じ PTR-specific path refinement の表裏
とみるほうがずっと自然である。

## 2. How This Fits Shared Values

既報では `branchVariant 0/1` 自体は
true/false で shared value
とみるのが safest だとしている。

この shared-value reading とも、
second-line carry はよく整合する。

つまり:

- value alphabet は shared
- reader-side meaning は `accepted` に応じて変わる
- second-line でもその same value が reopening shape を条件づける

という構図になる。

このため `branchVariant`
を一度だけ使い捨てるより、
second-line まで carry するほうが自然である。

## 3. Provisional Meaning

現時点の safest provisional reading は次のように書ける。

```ts
type CombatDecision = {
  accepted: boolean
  branch: number
  branchVariant?: 0 | 1
}
```

そして current best bias では:

```ts
postBranchTargetSource = reopenTargetSource(branch, branchVariant?)
pointerFlavor = reopenPointerFlavor(branch, branchVariant?)
target = resolveFinalTarget(branch, branchVariant?)
```

のように、
second-line reopening も `branchVariant`
を受けるとみるのが自然である。

## implication for step 6

この整理を採ると、step 6 の current code shape では
`branchVariant`
を first-line debug fieldとして出すだけでなく、
second-line reopening にも影響する carried refinement
として扱うほうが battle-side reading と揃う。

つまり `branchVariant`
は narrow actor-local API の中で、
decision layer と second-line reopening を橋渡しする最小の PTR-specific field
だとみるのが safest である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `branchVariant` が `postBranchTargetSource` の candidate/shared 差にどの程度効くか
2. `branchVariant` が `pointerFlavor` の candidate/shared 差により強く効くか
3. final `target` は `branchVariant` の downstream effect としてだけ変わるか

ここが取れれば、first-line と second-line の接続はかなり recovered semantics に近づく。
