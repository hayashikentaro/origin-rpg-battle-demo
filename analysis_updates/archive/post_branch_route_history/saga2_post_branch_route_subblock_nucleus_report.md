# Saga2 Post-Branch Route Subblock Nucleus Report

## 要点

- current best reading では、`41A4-41EC` 全体の中で `postBranchRoute` の **route-core nucleus** に最も近いのは **`41D9-41E5`** とみるのが最も自然である
- 理由は、`41C4-41D8` は pre-filter / special-candidate gate、`41E6-41EC` は consume belt としてすでに役割が濃く、**その中間にある `41D9-41E5` が first-line decision を second-line reopening へ渡す最も薄い route-core 帯** と読めるからである
- したがって current best bias は、`postBranchRoute` の exact battle-side anchoring を `41A4-41EC` 全体にぼかすより、**`41D9-41E5` を nucleus とし、前後を pre-filter / consume halo として持つ** ことである

## 1. Why `41D9-41E5` Fits Better Than `41C4-41D8`

既報では:

- `41C4-41D8`
  = pre-filter / special-code gate
- `41D9-41EC`
  = local consume/update belt

と整理している。

このとき `41C4-41D8`
は `0E/0F` / qualifier / sentinel の判定が密集しており、
battle-side semantics としては
まだ **decision source**
に寄っている。

いっぽう current best reading の `postBranchRoute`
は、
decision layer の後ろで
branch/refinement を reopening 側へ渡す
**route core**
である。

このため `41C4-41D8`
全体を route-core 本体とみるより、
そこは route-core の前段 pre-filter として残し、
その出力を最初に局所 record/pointer 側へ渡す
`41D9-41E5`
のほうを nucleus に置くのが自然になる。

## 2. Why `41D9-41E5` Fits Better Than `41E6-41EC`

既報では:

- `41D9-41E5`
  = local entry resolution
- `41E6-41EC`
  = counter consume/writeback

と分けている。

さらに `41E6-41EC`
は

- counter read
- sentinel gate
- consume/writeback

として、
すでに **consume belt**
の意味がかなり強い。

これに対し `postBranchRoute`
は current best reading では
consume そのものではなく、
その前に

- branch pair
- optional retained branchVariant

を second-line reopening へ渡す
route-core effect
である。

したがって `41E6-41EC`
を route-core 本体とみるより、
その直前の `41D9-41E5`
を
route-core nucleus、
`41E6-41EC`
をその downstream consume halo
とみるのが safest になる。

## 3. Three-Part Reading Of `41C4-41EC`

現時点の current best split は次のように書ける。

```text
41C4-41D8 = pre-filter / special-candidate gate
41D9-41E5 = route-core nucleus
41E6-41EC = consume belt / downstream effect
```

この 3 分割を採ると、
5-layer flow との対応もかなり綺麗になる。

- first-line `combatDecision`
  は pre-filter / gate 側に近い
- `postBranchRoute`
  は nucleus 側に近い
- second-line reopening / consume downstream
  は `41E6+` 側に近い

つまり exact anchor を求めるなら、
`41D9-41E5`
を中心に据えるのが最も軽い。

## 4. Relation To `branchVariant` Retention

既報では retained `branchVariant`
の strongest effect は
`pointerFlavor`
に landing すると読んでいる。

この前提を採ると、
route-core nucleus も

- retained refinement をまだ失っていない
- しかし consume belt そのものには入っていない

帯に置くのが自然である。

この profile に最も合うのが、
やはり `41D9-41E5`
である。

つまり `41D9-41E5`
は
**retained refinement が second-line reopening へ渡る直前の局所 nucleus**
として読むのが safest になる。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
postBranchRoute
```

の exact battle-side anchoring は:

```text
nucleus: 41D9-41E5
halo before: 41C4-41D8 (pre-filter)
halo after: 41E6-41EC (consume belt)
```

にかなり近い。

つまり `postBranchRoute`
は `41A4-41EC`
全体に一様に広がるのではなく、
**`41D9-41E5` を中心に前後へ意味がにじむ narrow route-core belt**
として持つのが current best である。

## implication for step 6

この整理を採ると、
`postBranchRoute`
の still-provisional 部分もかなり具体化できる。

- stable:
  - decision before route
  - route before second-line reopening
  - route before consume belt
- unresolved:
  - `41D9-41E5` 内のどこが exact route-core effect か
  - retained refinement が nucleus 内でどう扱われるか

つまり次の解析は
`41A4-41EC`
全体を掘り直すより、
**`41D9-41E5` nucleus を主戦場にする** のが最短になる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `41D9-41E5` のどこが retained `branchVariant` を最も強く保持しているか
2. `41D9-41E5` が `pointerFlavor` reopening へ落ちる直前の局所 boundary とみてよいか
3. `41E6-41EC` が route-core 後の consume halo として十分に分離できるか

ここが取れれば、`postBranchRoute` の exact anchoring はかなり recovered decomposition に近づく。
