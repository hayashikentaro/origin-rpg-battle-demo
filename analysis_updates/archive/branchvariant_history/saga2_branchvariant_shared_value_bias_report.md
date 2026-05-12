# Saga2 BranchVariant Shared-Value Bias Report

## 要点

- current best reading では、`branchVariant 0/1` は true/false で **別の値体系** を持つより、まず **共通の 2-way refinement value** を持つとみるのが最も自然である
- ただしその **reader-side meaning** は `accepted` の値に応じて少し変わり、  
  - false 側では strict fallback refinement  
  - true 側では admitted-path refinement  
 として解釈される、とみるのが safest である
- したがって current best bias は、`branchVariant` は field 値としては共通、meaning と consumer position が true/false で分かれる optional refinement として持つのが自然になる

## 1. Why Shared Values Fit Better Than Separate Alphabets

もし `branchVariant` が true 側と false 側で別の value alphabet を持つなら、
それは field shape を保ったまま semantics だけを強める current strategy と噛み合いにくい。

既報では `branchVariant` は

- `candidateOffset`
- 2-way bucket
- direct mapping

まで narrowed されている。

この narrowing は、
まず **shared 0/1 value**
があり、その値をどの path position で読むかだけが変わる、
とみるほうがずっと軽い。

## 2. How Meaning Can Still Differ By `accepted`

shared values を採ることは、
意味が完全に同じだという主張ではない。

current best reading は次のようになる。

- `branchVariant=0/1` という値自体は shared
- `accepted=false` では strict fallback の sub-branch
- `accepted=true` では admitted consume path の sub-branch

つまり:

- value alphabet is shared
- semantic role is contextual

という構図である。

これは `branch` 自体の true/false dual reading ともよく整合する。

## 3. Provisional Meaning

現時点の safest provisional reading は次のように書ける。

```ts
type CombatDecision = {
  accepted: boolean
  branch: number
  branchVariant?: 0 | 1
}
```

そして current best bias は:

```ts
// value-level
branchVariant in {0, 1}

// reader-level
if (accepted) {
  // admitted-path refinement
} else {
  // strict-fallback refinement
}
```

である。

つまり `branchVariant`
は shape と value-range を固定しやすく、
meaning は consumer-side で contextual に読むのが自然になる。

## implication for step 6

この整理を採ると、step 6 の current code shape はかなり安定する。

- `branchVariant?: 0 | 1` を固定
- true/false で別 enum へ分けない
- exact semantics は reader-side で強める

で十分である。

つまり current frontier では、
field の redesign より
consumer semantics の sharpening
へ力を振るのが最も効率的になる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `branchVariant 0/1` が true/false の両側で同じ bucket source を持つか
2. value は shared でも consumer 位置の違いだけで説明し切れるか
3. second-line reopening もこの shared `branchVariant` を受けるとみてよいか

ここが取れれば、`branchVariant` の field-level semantics はかなり安定する。
