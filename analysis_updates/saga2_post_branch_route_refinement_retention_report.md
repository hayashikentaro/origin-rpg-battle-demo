# Saga2 Post-Branch Route Refinement Retention Report

## 要点

- current best reading では、`branchVariant` refinement は `postBranchRoute` の中で早々に失われるより、**second-line の `pointerFlavor` pair を reopen する直前まで保持される compressed refinement** とみるのが最も自然である
- したがって `postBranchRoute` は generic transfer core であると同時に、PTR path では **branch pair + retained branchVariant** を carrying する shared route core とみるのが safest である
- この整理を採ると、`routeAfterDecision(branch, branchVariant?)` は first-line refinement を second-line reopening order に写すだけでなく、**その refinement を pointer pair selection まで保持する** layer としてかなり自然に読める

## 1. Why `branchVariant` Should Survive Through `postBranchRoute`

既報では:

- `branchVariant`
  = PTR-only refinement
- second-line reopening
  = `postBranchTargetSource -> pointerFlavor -> target`
- `pointerFlavor`
  = second-line の中心 field

と整理している。

この前提を採ると、
もし `branchVariant`
が `postBranchRoute`
の中で即座に失われるなら、
second-line で最も PTR-specific な `pointerFlavor`
へどのように差分が届くかが弱くなる。

したがって safest reading は、
`branchVariant`
を
**`postBranchRoute` の中で保持されたまま second-line reopening に渡す**
ことである。

## 2. Why Retention Fits Better Than Early Collapse

`postBranchRoute`
を alignment transfer core と読む以上、
ここで collapse されるべきなのは
raw `candidateOffset`
のような pre-first-line material であって、
既に first-line へ要約された
`branchVariant`
ではない。

つまり current best role split は:

- raw candidate source
  -> first-line で `branchVariant`
- `branchVariant`
  -> route core で保持
- second-line
  -> `pointerFlavor` opening に反映

である。

このため `branchVariant`
を `postBranchRoute`
以前に潰すより、
**refinement-retaining transfer**
として読むのが自然になる。

## 3. Relation To `pointerFlavor`

既報では `pointerFlavor`
は second-line の pair alignment の中心であり、
とくに `"candidate"`
側は strict-side aligned provenance reopening
と読むのが current best である。

この前提を採ると、
`pointerFlavor`
が持つ strict-side alignment も、
`postBranchRoute`
が
`branchVariant`
を保持しているほうが綺麗につながる。

つまり:

- `branch`
  = pair-level family
- `branchVariant`
  = retained PTR-only refinement
- `postBranchRoute`
  = both are carried into second-line reopening

という chain が safest reading である。

## 4. Relation To `target`

既報では final `target`
は `pointerFlavor`
の downstream terminal
と読むのが current best である。

このため `branchVariant`
を final target まで直接 carry するとみる必要はなく、
`postBranchRoute`
が
**`pointerFlavor` selection まで refinement を保持する**
と読むので十分である。

つまり retention の endpoint は:

- `target` ではなく
- `pointerFlavor` reopening

に置くのが最も自然になる。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
postBranchRoute = routeAfterDecision(branch, branchVariant?)
```

の exact-bias は:

```ts
alignment transfer with retained PTR refinement
```

にかなり近い。

つまり `postBranchRoute`
は generic transfer core であると同時に、
PTR path では
**`branchVariant` を pointer-side reopening まで保持する route result**
として持つのが current best である。

## implication for step 6

この整理を採ると、
step 6 の provisional API でも
`postBranchRoute`
を単独 field として置いている意味がさらに明確になる。

- `combatDecision`
  = first-line compressed decision
- `postBranchRoute`
  = alignment transfer + refinement retention
- `pointerFlavor`
  = retained refinement が reopen する second-line class

という 3 段がかなり自然にそろうからである。

つまり next analysis / next implementation では、
`branchVariant`
を `postBranchRoute`
の前後で別扱いするより、
**route core が保持する compressed refinement**
として読むのが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `postBranchRoute` が `pointerFlavor="candidate"` と `"shared"` のどちらを reopen するかを `branchVariant` でどこまで直接に決めるか
2. `postBranchTargetSource` が retained refinement にどこまで依存せず entry marker に留まるか
3. final `target` が retained refinement の downstream result としてどこまで説明できるか

ここが取れれば、`postBranchRoute` の exact semantics はかなり recovered decomposition に近づく。
