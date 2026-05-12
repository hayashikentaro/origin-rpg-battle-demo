# Saga2 Post-Branch Route Anchoring Bias Report

## 要点

- current best reading では、`postBranchRoute` の exact battle-side anchoring は wide page staging より、**`actors` loop 内の actor-local opener から second-line reopening へ渡す narrow route-core belt** に置くのが最も自然である
- とくに `combatDecision -> postBranchRoute -> postBranchTargetSource -> pointerFlavor -> target` という 5-layer flow を採るなら、`postBranchRoute` は **`41A4-41EC` 近辺の actor-local gate 群と second-line reopening の境界** に最も近い provisional anchor とみるのが safest である
- したがって current frontier では、`postBranchRoute` の unresolved 点は「あるかないか」ではなく、**`41A4-41EC` 帯のどこまでを route core として数えるか** にかなり集約されている

## 1. Why The Anchor Should Stay Near The Actor-Local Opener

既報では:

- `branch` の最初の consumer は actor-local opener 側
- `41A4-41EC` は special-candidate gate / consume belt の主戦場
- second-line reopening は `postBranchRoute` のあとに現れる

と整理している。

この 3 本を合わせると、
`postBranchRoute`
の battle-side anchoring も、

- wide page staging
- later materialization bulk helper

より、
**actor-local opener から second-line reopening へ移る narrow belt**
に置くのが最も自然になる。

つまり safest bias は、
`postBranchRoute`
を
`actors` loop の局所 consumer 帯から
second-line reopening へ落ちる境界に anchored することである。

## 2. Why `41A4-41EC` Is Still The Best Provisional Window

既報 `actors loop`
および combat-RNG narrowing では、
`41A4-41EC`
を

- state `04/05` dispatch 近傍
- special-code gate
- counter consume belt

として重点観測帯に置いてきた。

いまの 5-layer reading に引き直すと、
この帯は

- `combatDecision`
 由来の branch/refinement が最初に局所的に読まれ
- その結果が `postBranchRoute`
 という route-core meaning に要約され
- 後段 reopening へ落ちる

という provisional flow を置くのに最も整合する。

したがって current best anchor は、
`41A4-41EC`
のどこかに `postBranchRoute` 相当の route-core effect を置くことである。

## 3. Relation To `branchVariant` Retention

既報では
`branchVariant`
は `postBranchRoute`
の中で早く消えるのではなく、
`pointerFlavor`
を reopen する直前まで retained される
と整理している。

この retention 読みを採るなら、
`postBranchRoute`
の anchor も

- `branchVariant` がまだ局所的に意味を持つ帯
- しかし raw candidate material はすでに first-line へ要約済みの帯

に置くのが自然である。

この profile に最も合うのが、
やはり `41A4-41EC`
近辺の actor-local gate belt である。

## 4. Why The Anchor Should Stay Before Large Staging

既報では
`6157`
以降は

- `C200/C7EE`
- `D400/D500`

など larger staging/apply layer
と読むのが current best である。

このため `postBranchRoute`
をこの後段へ押し込むと、

- decision/routing split
- second-line reopening
- actor-local opener

の 3 本の境界がぼやける。

したがって safest reading は、
`postBranchRoute`
を large staging より前、
**actor-local opener の narrow belt**
に残すことである。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
postBranchRoute = routeAfterDecision(branch, branchVariant?)
```

の battle-side anchoring は:

```ts
actor-local route-core belt
near 41A4-41EC
before second-line reopening
before large staging/apply
```

にかなり近い。

つまり `postBranchRoute`
は abstract routing concept ではなく、
**actor-local opener と second-line reopening の境界にある shared route core**
として持つのが current best である。

## implication for step 6

この整理を採ると、
step 6 で still-provisional として残すべき route-core 論点もかなり絞れる。

- unresolved:
  - `41A4-41EC` のどこが exact anchor か
  - retained refinement がどこで `pointerFlavor` へ落ちるか
- already stable:
  - decision before route
  - route before reopening
  - reopening before target terminal

つまり next analysis は、
`postBranchRoute`
の existence や role を疑うより、
**その exact local anchor を `41A4-41EC` 内で sharpen する**
ことへ集中すればよい。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `41A4-41EC` の中で route-core effect が最も濃い sub-block がどこか
2. retained `branchVariant` が `pointerFlavor` reopening へ落ちる直前の局所境界がどこか
3. `postBranchTargetSource` が route-core belt の出口 marker としてどこまで扱えるか

ここが取れれば、`postBranchRoute` の exact battle-side anchoring はかなり recovered decomposition に近づく。
