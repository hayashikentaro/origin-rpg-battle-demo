# Saga2 Post-Branch Route Micro-Boundary Report

## 要点

- current best reading では、`41D9-41E5` nucleus の中でも `postBranchRoute` の **micro-boundary** に最も近いのは、entry resolution の開始点そのものより **`41E6` 直前の handoff edge** とみるのが最も自然である
- したがって `41D9-41E5` 全体を一様な route-core 本体とみるより、  
  - 前半 = local entry resolution / route material gathering  
  - 後半 = retained refinement を second-line reopening / consume halo へ渡す handoff edge  
  とみるのが safest である
- この整理を採ると、`postBranchRoute` の exact battle-side anchoring は **`41D9-41E5` nucleus の後半寄り** にかなり絞れる

## 1. Why The Exact Center Is Better Placed Near The Handoff Than At `41D9`

既報では `41D9-41E5` を route-core nucleus とみるのが current best である。

ただし nucleus と言っても、
その先頭 `41D9`
はまだ

- local entry resolution
- record/pointer-side material gathering

の色が強い。

いっぽう current best reading の `postBranchRoute`
は、
単なる local entry 展開というより、
**first-line decision/refinement を second-line reopening 側へ渡す route-core effect**
である。

このため exact center を `41D9`
に置くより、
`41E6`
の consume halo へ入る直前、
すなわち nucleus 後半の
**handoff edge**
に置くほうが flow に合う。

## 2. Suggested Internal Split Of `41D9-41E5`

現時点の safest internal split は次のように書ける。

```text
41D9-41E2  = local entry resolution / route material gathering
41E3-41E5  = handoff edge toward reopen/consume
41E6-41EC  = consume halo
```

この分け方の利点は、
既報の

- `41D9-41E5` = route-core nucleus
- `41E6-41EC` = consume halo

を保ちつつ、
exact route-core effect を
`41E6` 直前へさらに寄せられることにある。

つまり `41E3-41E5`
あたりを
**retained refinement が reopen/consume 側へ受け渡される最終局所境界**
として持つのが current best bias である。

## 3. Why This Fits Retained `branchVariant`

既報では retained `branchVariant`
は `postBranchRoute`
の中で保持され、
`pointerFlavor`
に strongest に landing すると読んでいる。

この前提を採ると、
micro-boundary も

- retained refinement をまだ保持している
- しかしすでに second-line reopening / consume halo へ渡す直前にある

帯に置くのが自然になる。

この profile に最もよく合うのが、
`41D9-41E5`
の中でも
**後半 handoff edge**
である。

## 4. Relation To `pointerFlavor`

既報では
`pointerFlavor`
が route-core retained refinement の strongest landing point
である。

このため micro-boundary も、
`postBranchTargetSource`
より先に
`pointerFlavor`
へ効く準備が整う場所、
すなわち
**pointer-side reopening の直前境界**
とみるのが最も自然になる。

つまり current best chain は:

```text
41C4-41D8  pre-filter
41D9-41E2  route material gathering
41E3-41E5  route-core handoff edge
41E6-41EC  consume halo / downstream effect
```

である。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
postBranchRoute
```

の exact micro-boundary は:

```text
best nucleus center = late 41D9-41E5
best handoff edge   = around 41E3-41E5
```

にかなり近い。

つまり `postBranchRoute`
の exact anchor は
`41D9-41E5`
全体よりさらに
**`41E6` 直前の後半 edge**
へ寄せて読むのが current best である。

## implication for step 6

この整理を採ると、
still-provisional な route-core 論点もさらに絞れる。

- already stable:
  - nucleus = `41D9-41E5`
  - consume halo = `41E6-41EC`
- narrower frontier:
  - exact route-core effect is late in the nucleus
  - retained refinement handoff likely sits just before `41E6`

つまり next analysis は、
`41D9-41E5`
全体より
**`41E3-41E5` handoff edge**
を first target にするのが最短になる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `41E3-41E5` が retained `branchVariant` を最も強く保持したまま downstream へ渡すか
2. `pointerFlavor` reopening の最初の実効点が `41E6` 以降にあるとみてよいか
3. `postBranchTargetSource` がこの handoff edge より前段 marker に留まるか

ここが取れれば、`postBranchRoute` の exact micro-boundary はかなり recovered decomposition に近づく。
