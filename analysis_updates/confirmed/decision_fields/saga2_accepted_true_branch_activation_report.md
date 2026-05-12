# Saga2 Accepted-True Branch Activation Report

## 要点

- current best reading では、`accepted=true` のあとに現れる `branch` / `branchVariant` は **fallback 先の指定** より、まず **admitted consume path の内側でどの local branch を使うかの activation** とみるのが最も自然である
- 理由は、`accepted` 自体を current consume path admission bit とみるなら、その直後に必要なのは「fallback へ戻る情報」ではなく、「この admitted path の中でどの branch family を開くか」の情報だからである
- したがって current best bias は、`accepted=true` のとき  
  - `branch` は current consume path 内の shared branch family を activate し  
  - `branchVariant` は PTR path だけが持つ admitted-path refinement  
 になる、という形になる

## 1. Why Activation Fits Better Than Fallback On The True Side

false 側では current best reading がすでに

- current consume path denied
- strict fallback retained

に寄っているため、
`branch`
は false 側では fallback branch family と読むのが自然だった。

しかし true 側では
`accepted=true`
の時点で current consume path が開いている。

このため true 側で同じ `branch` を見るときの safest reading は、
fallback 先そのものではなく
**admitted path の inside-branch activation**
である。

つまり `branch` は field として shared でも、
true/false で reader position が少し違うとみるのが自然になる。

## 2. How `branchVariant` Fits The True Side

`branchVariant` は current best bias では
PTR false-side にだけ現れる optional refinement
として狭めてきた。

ただし true 側でも、
もし PTR path が current consume path へ admission されるなら、
その path-specific refinement が
**admitted path の内側**
で効く可能性が高い。

このため safest reading は、

- `branchVariant` は false 側では strict fallback refinement
- true 側では admitted-path refinement

という symmetry を持ちうるとみることになる。

もちろん current evidence は true 側でまだ弱いが、
field-level semantics としてはこの読みが最も軽い。

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
if (accepted) {
  // activate local branch inside admitted consume path
} else {
  // select strict fallback branch
}
```

と読むのが自然である。

つまり `branch` は field として shared だが、
reader-side では
admitted path / fallback path
の両方で使われる branch family とみるのが safest である。

## implication for step 6

この整理を採ると、step 6 の provisional API では
`accepted / branch / branchVariant`
の shape はそのままでよく、
true/false の exact semantics は
consumer 側で分けて解釈すればよい。

つまり field を増やすより、
`accepted`
の値に応じて
`branch` を

- admitted-path activation
- fallback selection

のどちらとして読むかを後段に委ねるのが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `accepted=true` 側で `branch` が current consume path 内の activation と読めるか
2. `branchVariant` が true 側でも PTR path の admitted refinement として残るか
3. false/true の両方で `branch` を shared branch family として保てるか

ここが取れれば、`branch` と `branchVariant` の field-level semantics はかなり recovered semantics に近づく。
