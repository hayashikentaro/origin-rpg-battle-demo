# SaGa2 `019E` Post-Resolve / Pre-Apply Window Report

## Summary
- `019E` の immediate target として残る未命名 local shadow/result family は、`611C` inner core の中でも **post-resolve / pre-apply window** に置くのが最も自然である。
- つまり位置づけとしては、`FF8C` token と `5F07` remap で selection を解決し、`C73D[index]` から seed byte を読んだ**その直後**、しかし `6157` apply/staging に渡る**その前**の短い窓に属する state である。
- これにより次の探索単位は、「`019E` が何かへ書く」よりさらに具体的に、**resolved seed byte を local result として一時確定する post-resolve shadow slot** へ絞れる。

## 1. Temporal Placement Inside `611C`

`611C` inner core を時間順に並べると:

1. `01B9`  
   current-selection token materialize
2. `FF8C`  
   token validity gate
3. `5F07`  
   token -> local index remap
4. `C73D[index]`  
   resolved seed byte fetch
5. `019E`  
   resolved seed byte consume/commit
6. `6157`  
   success後の apply/staging

この並びで見ると、
未命名 shadow/result family が入る場所は
5 と 6 の間、あるいは 5 の副作用先そのものとして置くのが自然。

## 2. Why It Is Post-Resolve

次のことはすでにかなり固い。

- `FF8C` は final index ではない
- `5F07` 後に初めて caller-local index が確定する
- `019E` が受け取るのは token ではなく `C73D[index]` の seed byte

したがって shadow/result family が持つ内容は、
selection token や unresolved candidate ではなく、
**すでに resolve 済みの local result**
である可能性が高い。

## 3. Why It Is Pre-Apply

`6157` は:

- `611C` 成功後にだけ起動
- `C200 <-> C7EE`
- `D400/D500`

を扱う apply/staging 層である。

このため、`019E` first writeback がここに直結するより、
まずは local result を inner core 内で一度確定し、
その後 `6157` がそれを battle-side state へ反映すると見るほうがきれいである。

要するに shadow/result family は、
**apply の入力になる前の local settled state**
に近い。

## 4. Best Current High-Level Model

```ts
const token = materializeSelection()        // FF8C
const localIndex = remapToken(token)        // 5F07
const seedByte = C73D[localIndex]           // resolved source
const shadowResult = settleLocalResult(seedByte) // 019E
applyLater(shadowResult)                    // 6157
```

ここで `shadowResult` は:

- unresolved token ではない
- source table そのものでもない
- battle-side applied record でもない

つまり **post-resolve / pre-apply** の位置を占める。

## 5. Search Consequence

次に local hidden state を探るときは、
候補を次のようにさらに絞れる。

1. resolved selection/seed を一時確定する small local shadow slot  
2. apply/staging に渡す前の settled local result field  
3. その後段で shared `C2F6` presence へ反映される bridge

## Implication
- 未命名 shadow/result family は inner core 内でも post-resolve / pre-apply window にある
- これで `019E` 探索は token/source 側からかなり切り離せる
- 次の本命は `resolved seed byte` を一時確定する local settled-state slot である
