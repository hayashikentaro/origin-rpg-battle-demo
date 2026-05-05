# Saga2 PointerFlavor Semantics Snapshot Report

## 要点

- current best reading では、`pointerFlavor` は単なる debug 用ラベルではなく、**second-line reopening の中心にある pointer/materialization provenance class** とみるのが最も自然である
- その値は current frontier では  
  - `"shared"`  
  - `"candidate"`  
  の 2 値に整理でき、これは second-line で pointer-like resolution が **共有系の流れ** か **PTR/candidate 系の流れ** かを分ける class として読むのが safest である
- したがって `pointerFlavor` は、現時点で second-line の中でもっとも battle-side meaning が強く見えている field のひとつである

## 1. Why PointerFlavor Is More Than A Label

既報では second-line の current best order を

1. `postBranchTargetSource`
2. `pointerFlavor`
3. `target`

としている。

このとき `postBranchTargetSource` は weak entry marker、
`target` は downstream result と読まれているため、
second-line の実質的な meaning center は
`pointerFlavor`
に寄ることになる。

したがって `pointerFlavor`
は単なる観測用文字列というより、
**pointer/materialization reopening がどの provenance class に属するか**
を表す field とみるのが自然である。

## 2. What The Two Values Mean

current frontier での safest reading は次の通りである。

- `"shared"`  
  = ATK を含む共有系の pointer/materialization reopening
- `"candidate"`  
  = PTR 系の candidate-flavored pointer/materialization reopening

ここで重要なのは、
`pointerFlavor`
が final target そのものを指すのではなく、
**その target を後で生む pointer-side provenance class**
を表している点である。

つまり current best reading では、
`pointerFlavor`
は second-line の causal center であり、
`target`
はその result である。

## 3. How It Connects To First-Line Fields

既報では `branchVariant`
が second-line reopening に carry される PTR-specific refinement
とみている。

この読みと合わせると、
`pointerFlavor`
は

- first-line では `branchVariant`
- second-line では `pointerFlavor="candidate"`

という形で、
PTR-specific path refinement が可視化された field と読める。

つまり:

- `branchVariant` = first-line PTR refinement
- `pointerFlavor` = second-line PTR refinement center

という対応になる。

## 4. Safest Current Reading

現時点の safest reading は次のように要約できる。

```ts
type PointerFlavor = "shared" | "candidate"
```

そして semantics は:

```ts
"shared"    => shared pointer/materialization path
"candidate" => PTR-specific candidate-flavored pointer/materialization path
```

である。

この reading は、
current debug matrix と current battle-side narrowing の両方にかなりよく噛み合う。

## implication for step 6

この整理を採ると、step 6 では
`pointerFlavor`
を second-line の中心 field として扱うのがかなり自然になる。

つまり next analysis / next implementation の優先順は:

1. `pointerFlavor` の exact meaning を強める
2. `target` をその downstream result として解釈する

でよい。

これは field-readiness snapshot の優先度とも一致する。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `"candidate"` が battle-side で本当に PTR-specific pointer/materialization class を指すか
2. `"shared"` が ATK 側の default reopening class とみてよいか
3. `target` の差分が `pointerFlavor` の class 差でかなり説明できるか

ここが取れれば、`pointerFlavor` の field-level semantics はかなり recovered semantics に近づく。
