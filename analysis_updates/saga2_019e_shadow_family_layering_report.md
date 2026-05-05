# SaGa2 `019E` Shadow-Family Layering Report

## Summary
- `019E` の immediate target 候補として残る未命名 local result/shadow family は、`611C` の **outer edge** や `6157` の **apply/staging 層** ではなく、`01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E` と同じ **inner core 層** に属するとみるのが最も自然。
- つまり次に探すべき shadow/result family は、presentation/UI 側の scratch でも、battle-side apply 側の record でもなく、**selection/seed commit の直近にいる hidden-local family** である。
- この layering を固定すると、今後の探索は `611C` outer edge や `6157` の side effect を再び広げずに、core 近傍の unnamed local state へかなり集中できる。

## 1. Three Layers Around `019E`

現在の evidence では、`019E` の周囲は高位で 3 層に分けて持つのが自然。

1. outer edge  
   `RST $08(E=$15)`, `5F0E`
2. inner core  
   `01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E`
3. apply/staging  
   `6157` 以降 (`C7EE`, `C200`, `D400/D500`)

`019E` がいるのは明らかに 2 層目である。

## 2. Why The Shadow Family Belongs To The Inner Core

`019E` は:

- `FF8C` token を直接受けない
- `C73D` source を受け取るわけでもない
- `6157` 以降の apply/staging より前に成功を返す

この 3 点から、
その first writeback 先も
**`019E` と同じ inner core の中で完結する**
と考えるのが自然になる。

もし shadow/result family が outer edge 側に属するなら、
`RST $08(E=$15)` や `5F0E` ともっと近い振る舞いが見えるはずだが、
今のところそうした evidence はない。

もし apply/staging 側に属するなら、
`611C` 成功後にだけ呼ばれる `6157` をまたいで初めて意味を持つはずで、
`019E` immediate target とみるには距離がありすぎる。

## 3. What This Excludes

この layering で優先度を下げられるもの:

- `RST $08(E=$15)` 周辺の visible dispatch scratch
- `5F0E` 周辺の refresh/finalize state
- `6157` で触る `C7EE`, `C200`, `D400/D500`
- parent loop の one-shot precondition 側 state

要するに、
**`019E` immediate target を outer edge / post-core side effect に求める線**
はかなり弱くなる。

## 4. What Remains Plausible

逆に、今も plausible なのは:

- `611C` inner core と同層の unnamed local result byte
- same core layer にある small hidden result family
- 場合によっては `C20F` の未観測 subfield

ただし first guess は最後ではなく、
**inner core 専用の unnamed local family**
として置くのが安全。

## 5. Updated Search Boundary

今後の探索境界は次の形で持つのがよい。

```ts
outerEdge()
const token = resolveSelection()
const localIndex = remap(token)
const seedByte = C73D[localIndex]
const shadowResult = commit(seedByte) // 019E
applyLater(shadowResult)
```

ここで `shadowResult` は:

- outerEdge ではない
- applyLater でもない
- **inner core が first-class に持つ hidden local result**

である。

## Implication
- 未命名 shadow/result family は inner core 層に属するとみるのが自然
- outer edge と apply/staging 層は、`019E` immediate target 探索からさらに外せる
- 次の主戦場は `611C` core 直近の unnamed local state で固定してよい
