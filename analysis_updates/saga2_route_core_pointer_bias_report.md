# Saga2 Route-Core Pointer-Bias Report

## 要点

- current best reading では、`postBranchRoute` に retained される `branchVariant` refinement は **`postBranchTargetSource` より `pointerFlavor` に強く効く** とみるのが最も自然である
- したがって `postBranchRoute` の exact semantics は、generic transfer core というだけでなく、**retained refinement を pointer-side reopening へ集中して渡す route core** として持つのが safest である
- この整理を採ると、retention の主な終点は  
  - `postBranchTargetSource` ではなく  
  - **`pointerFlavor`**  
  であり、`target` はその downstream terminal としてかなり自然に説明できる

## 1. Why The Retained Refinement Should End Up At `pointerFlavor`

既報では:

- `branchVariant`
  は second-line reopening に carry される
- `postBranchTargetSource`
  は weak / shared entry marker
- `pointerFlavor`
  は strong PTR-specific reopening core

と整理している。

この 3 本を route-core 文脈で合わせると、
`postBranchRoute`
が保持した refinement の最も自然な landing point は
`postBranchTargetSource`
ではなく
**`pointerFlavor`**
になる。

つまり route core の役割は、
retained refinement を
「pointer-side class reopening」
へきちんと渡すことにある。

## 2. Why `postBranchTargetSource` Stays Weak

もし retained `branchVariant`
が `postBranchTargetSource`
にも同じ強さで効くなら、
second-line の PTR specificity は

- entry marker
- pointer provenance

の両方に均等に散ってしまう。

しかし既報では second-line の中心は
明確に `pointerFlavor`
へ寄っている。

したがって safest reading は、

- `postBranchTargetSource`
  = route core が開いた reopening の shared marker
- `pointerFlavor`
  = retained refinement が本格的に効く landing point

という非対称な役割分担である。

## 3. Why This Clarifies `postBranchRoute`

既報 `alignment transfer core`
だけだと、
`postBranchRoute`
は「alignment を downstream へ運ぶ」
という一般的説明に留まる。

いっぽう current best reading では、
PTR path に限れば route core はもう一歩具体的で、

- branch pair
- optional branchVariant

を second-line reopening へ移し、
その refinement を
**pointer-side class selection**
に最も強く効かせる
と読むほうが自然である。

このため exact-bias は:

```ts
postBranchRoute = alignment transfer
                 + retained refinement routed mainly into pointerFlavor
```

となる。

## 4. Relation To `target`

既報では final `target`
は `pointerFlavor`
の downstream terminal
と読むのが safest である。

このため route core の retained refinement も、
`target`
へ直接に作用するとみる必要は薄く、
まずは
`pointerFlavor`
へ強く現れ、
その結果として target 差分が downstream に出る、
と読むのが最も軽い。

つまり second-line の force flow は:

```text
postBranchRoute
  -> weak marker: postBranchTargetSource
  -> strong reopening core: pointerFlavor
  -> downstream terminal: target
```

である。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
postBranchRoute = routeAfterDecision(branch, branchVariant?)
```

の exact-bias は:

```ts
route core whose retained refinement lands primarily in pointerFlavor
```

にかなり近い。

つまり `postBranchRoute`
は first-line の pair/refinement を downstream へ運ぶだけでなく、
**その refinement をどこへ strongest に reopen するか**
まで含んだ shared core
と読むのが current best である。

## implication for step 6

この整理を採ると、
step 6 の provisional API でも
`postBranchTargetSource`
と `pointerFlavor`
の重み付けがさらに明確になる。

- `postBranchTargetSource`
  = route-open marker
- `pointerFlavor`
  = retained refinement の主 landing point
- `target`
  =その downstream result

で十分だからである。

つまり next analysis / next implementation でも、
`pointerFlavor`
を second-line の主要観測点に置く方針がさらに強く正当化される。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `postBranchRoute` が `"candidate"` / `"shared"` の pointer class をどこまで直接に選ぶか
2. `postBranchTargetSource` が branchVariant 非依存の marker としてどこまで保てるか
3. final `target` 差分の residual が pointerFlavor downstream だけで本当に吸収できるか

ここが取れれば、route core の exact semantics はかなり recovered decomposition に近づく。
