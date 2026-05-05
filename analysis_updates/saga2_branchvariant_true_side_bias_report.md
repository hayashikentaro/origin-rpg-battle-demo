# Saga2 BranchVariant True-Side Bias Report

## 要点

- current best reading では、`branchVariant` は false 側だけの artifact ではなく、**true 側でも PTR path の admitted refinement として残る** とみるのが最も自然である
- 理由は、`branchVariant` の source を `candidateOffset -> 2-way bucket -> direct mapping` と読んでいる以上、その refinement は reject 専用のものより **PTR path の candidate-flavored local branching** 全体に属するとみるほうが対称的で軽いからである
- したがって current best bias は、`branchVariant` は  
  - false 側では strict fallback refinement  
  - true 側では admitted-path refinement  
 を表す shared optional field として持つのが safest である

## 1. Why A True-Side Reading Is More Natural Than False-Only

もし `branchVariant` を false 側専用 artifact とみなすなら、
その source である `candidateOffset` は
PTR path の candidate-flavored structure であるにもかかわらず、
reject 時にしか意味を持たないことになる。

しかし current best reading では、
`PTR` の差分は

- candidateOffset
- branchVariant
- candidate-flavored second-line reopening

と一貫して path-specific refinement を作っている。

このため safest reading は、
`branchVariant` も
true 側 / false 側の両方で使われる
**PTR path の optional refinement**
とみることである。

## 2. How The Semantics Differ By `accepted`

この reading でも、
`branchVariant` の exact meaning は `accepted` の値で少し変わる。

- `accepted=false`  
  strict fallback の下位 refinement
- `accepted=true`  
  admitted consume path の下位 refinement

つまり field は shared だが、
reader-side では
current local path の位置に応じて解釈が変わる、
という形になる。

これは既報の
`branch` の true/false dual reading
ともよく噛み合う。

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
if (branchVariant !== undefined) {
  // PTR-only local branch refinement
  // meaning depends on accepted true/false
}
```

と読むのが自然である。

つまり `branchVariant` は
false-side 専用 field ではなく、
PTR path の optional refinement field
として持つのが safest になる。

## implication for step 6

この整理を採ると、step 6 の current code shape はかなり安定する。

- `branchVariant` を PTR-only optional field として保持
- true/false の exact semantics は consumer 側で読む

で十分であり、
accepted に応じて別 field を増やす必要は薄い。

つまり field shape は固定しつつ、
semantics を reader-side で強くする方針がかなり自然になる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `branchVariant` が true 側でも PTR path の admitted refinement として残るか
2. `branchVariant 0/1` の exact meaning が true/false でどの程度共通か
3. second-line reopening も `branchVariant` の結果を受けるとみてよいか

ここが取れれば、`branchVariant` の field-level semantics はかなり recovered semantics に近づく。
