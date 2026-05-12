# Saga2 Branch Pair-Alignment Report

## 要点

- current best reading では、`branch` は pure strict-fallback family に閉じるより、**fast/default side と strict side を持つ shared branch-family alignment** とみるのが最も自然である
- したがって `accepted=false` 側ではこの pair を fallback selection として読み、`accepted=true` 側では同じ pair を admitted-path activation として読む、という構図が safest である
- この整理を採ると、first-line の `branch` と second-line の `pointerFlavor` はともに **same alignment, different role** で読めるようになり、5-layer API 全体がかなり対称にそろう

## 1. Why `branch` Should Be Read As A Pair Rather Than A Strict-Only Family

既報では `branch`
を
shared strict-fallback branch family
と読んでいた。

しかしその後、

- `accepted=true`
 では `branch` が admitted-path activation に使われる
- `branchVariant`
 には strict-side polarity / fast-side polarity の pair がある
- second-line `pointerFlavor`
 も strict-side / fast-default side の pair alignment を保つ

という整理まで進んでいる。

この時点で `branch`
だけを strict-only family とみなすより、
**shared branch-family pair**
として読むほうが全体に整合する。

つまり safest reading は:

- one side = fast/default aligned branch family
- other side = strict/non-fast-path aligned branch family

である。

## 2. Why `accepted` Then Naturally Becomes A Role Selector

この pair reading を採ると、
`accepted`
の役割も自然に揃う。

- `accepted=false`
 では same branch pair を fallback selection として読む
- `accepted=true`
 では same branch pair を admitted-path activation として読む

つまり `accepted`
は branch family の向きを変えるのではなく、
**same alignment を fallback / activation のどちらの control-flow role で読むか**
を決める field とみるのが safest になる。

この点は
`branchVariant`
と
`pointerFlavor`
の cross-acceptance reading
ともよく整合する。

## 3. Relation To `branchVariant`

既報では `branchVariant`
は branch pair の下位 refinement として、

- one side = fast/shortcut-leaning
- one side = strict/non-fast-path-leaning

を shared に保つと読んでいる。

この前提を上位 field に戻すと、
`branch`
自体も first-line では
**alignment pair を持つ shared branch family**
として読むのが自然になる。

つまり current best role split は:

- `branch`
  = pair-level family
- `branchVariant`
  = PTR-only sub-branch refinement

である。

## 4. Relation To `pointerFlavor`

second-line では
`pointerFlavor`
が

- `"candidate"` = strict-side aligned provenance reopening
- `"shared"` = fast/default aligned provenance reopening

の pair を保つと current best reading で整理している。

この対称性を first-line まで戻すと、
`branch`
も

- strict-side aligned branch family
- fast/default aligned branch family

の pair を持つほうが自然になる。

つまり current best reading では、

- first-line `branch`
  = pair-aligned branch family
- second-line `pointerFlavor`
  = pair-aligned provenance reopening

という 2 層対称が成立する。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
branch: number
```

の exact-bias は:

```ts
shared branch-family alignment
// one side = fast/default aligned
// one side = strict/non-fast-path aligned
```

にかなり近い。

そして:

```ts
if (accepted) {
  // admitted-path activation
} else {
  // fallback selection
}
```

という reader-side role だけが変わる、
とみるのが current best である。

## implication for step 6

この整理を採ると、
step 6 の provisional API では
`branch`
を strict-only label で読むより、
**pair-aligned branch family**
として読むほうが安全になる。

つまり next analysis / next implementation では、
`branch`
の exact semantics も
`pointerFlavor`
と同様に
same alignment, different role
の原則で sharpen できる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `branch` の fast/default side と strict side のどちらが `branchVariant` の strict-side polarity と自然に噛み合うか
2. `postBranchRoute` がこの branch pair alignment を second-line へどう渡すか
3. final `target` 差分もこの branch/pointer pair の downstream result としてどこまで説明できるか

ここが取れれば、first-line と second-line の whole-structure alignment はかなり recovered semantics に近づく。
