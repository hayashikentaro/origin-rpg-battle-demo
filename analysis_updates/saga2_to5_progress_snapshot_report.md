# Saga2 To5 Progress Snapshot Report

## 要点

- `to 5` の作業線は current frontier ではかなり前進していて、主戦場はすでに `41A4-41EC` 全体ではなく **`41E3-41E5` handoff edge** にまで絞れている
- 5-step で見ると、  
  1. route-core nucleus の絞り込み  
  2. second-line reopening 開始点  
  3. `postBranchTargetSource` の弱い marker 化  
  4. `postBranchRoute -> pointerFlavor -> target` の順序固定  
  5. code-ready / still-provisional 境界の更新  
  まで current best reading をかなり明文化できている
- したがって次の解析は wide 探索ではなく、**`41E3-41E5` の micro-boundary と `41E6+` reopening/consume halo の境界** をさらに sharpen する段階にある

## 1. Step 1: Route-Core Nucleus

current best reading では、
`41A4-41EC`
の中で `postBranchRoute`
の nucleus に最も近いのは
**`41D9-41E5`**
である。

さらにその内部も一様ではなく、

- `41D9-41E2`
  = route material gathering
- `41E3-41E5`
  = retained refinement handoff edge

と読むのが safest である。

つまり route-core の exact anchor は、
`41A4-41EC`
全体より
**`41E3-41E5`**
へかなり寄っている。

## 2. Step 2: Second-Line Reopening Start

current best reading では、
second-line reopening の実効開始は
`41E6`
以降へ置くのが自然である。

このため:

- `41E3-41E5`
  = handoff edge
- `41E6-41EC`
  = consume/reopen halo

という境界が current best である。

つまり `pointerFlavor`
の strongest landing point は
handoff edge の後ろにあり、
route core そのものではなく
その downstream reopening 側に本体がある。

## 3. Step 3: `postBranchTargetSource`

`postBranchTargetSource`
は current best reading では
PTR-specific 本体ではなく、
**weak/shared entry marker**
としてかなり安定している。

retained `branchVariant`
の strongest effect は
`postBranchTargetSource`
より
**`pointerFlavor`**
に現れる、
という bias もかなり強い。

このため second-line の役割分担は:

- `postBranchTargetSource`
  = entry marker
- `pointerFlavor`
  = reopening core
- `target`
  = downstream terminal

でかなり固定できている。

## 4. Step 4: Route/Pointer/Target Order

current best reading では 5-layer flow は:

```text
combatDecision
-> postBranchRoute
-> postBranchTargetSource
-> pointerFlavor
-> target
```

でかなり stable である。

さらに meaning としては:

- `postBranchRoute`
  = alignment transfer core
- retained `branchVariant`
  = `pointerFlavor` まで保持
- `target`
  = `pointerFlavor` pair の downstream result

と読むのが safest である。

## 5. Step 5: Readiness Boundary

current frontier では、
shape / layer order / field split 自体はかなり code-ready である。

### strongly code-ready

- `combatDecision`
- `postBranchRoute`
- `postBranchTargetSource`
- `pointerFlavor`
- `target`

### still-provisional

- `branch` の exact family naming
- `branchVariant 0/1` の exact numeric naming
- `pointerFlavor` の exact ROM-side provenance wording
- `postBranchRoute` の exact battle-side anchoring
- final `target` の exact route

つまり今は interface redesign の段階ではなく、
**semantic sharpening stage**
に入っている。

## implication

`to 5` の線で最も効いたのは、
探索対象を

- wide battle staging
から
- `41E3-41E5` handoff edge

へ圧縮できたことである。

次の最短線は、
この handoff edge と `41E6+` reopening/consume halo の境界をさらに詰め、
`postBranchRoute` の exact micro-boundary を recovered semantics に寄せることである。
