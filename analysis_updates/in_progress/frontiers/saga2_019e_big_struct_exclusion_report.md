# SaGa2 `019E` Big-Struct Exclusion Report

## Summary
- ここまでの layering と family 整理を重ねると、`019E` の immediate target を **big struct / long record / apply-side page** とみなす必要はかなり薄くなっている。
- もっとも自然なのは、`019E` が inner core 内で **short settled-state family** を確定し、その結果が後段で `6157` や `C2F6` 反映に使われる、という順序である。
- したがって次の探索は、record/page 全体を疑うより **単発 byte / marker + status / short tuple** を first line に置くのが安全である。

## 1. What Counts As “Too Big” Here

現時点で immediate target 候補から優先度を下げてよい big 側のもの:

- full `C20F` 16byte workspace
- visible `C200` main record
- `C7EE` scratch header block
- `D400/D500` battle-side apply/staging page family

これらはどれも、
`019E` がいる inner core より外側か、
役割が重すぎる。

## 2. Why `C20F` Still Doesn’t Need To Be The First Guess

`C20F` は最も近い big 候補だが、
現時点で見えているのは:

- `611C` 冒頭で `FF` clear
- player-local workspace
- high-range selector source 候補

であり、
result sink としての証拠ではない。

したがって `C20F` を immediate target にするとしても、
それは full record write ではなく
**未観測 subfield**
として考えるべきである。

## 3. Why Apply-Side Pages Are Too Late

`6157` は:

- `611C` 成功後にだけ起動
- `C200`, `C7EE`, `D400/D500`
- dispatch / staging / init

を担う。

この位置関係から、
`019E` immediate target が apply-side page family にあるなら、
`611C` / `6157` の二段構造が崩れやすい。

今の evidence では、
`019E` は apply の前に
**まず local settled state を作る**
と読むほうがはるかに自然。

## 4. Best Current Size Estimate

`019E` immediate target のサイズ感として
安全に残せるのは次の 3 つ。

1. single byte  
2. marker + status (2 bytes 前後)  
3. very short tuple / tiny shadow family  

逆に、いまは積極的に疑わなくてよいもの:

1. long workspace
2. page-wide shadow record
3. battle-side staging struct

## 5. Updated Search Consequence

次に観測すべきものを size 観点で言い直すと:

- `A` の直保存先 1 byte
- commit success を表す short marker pair
- local outcome を持つ tiny shadow tuple

であって、
record/page 全体を掘り直すことではない。

## Implication
- `019E` immediate target は big struct より short settled-state family とみるのが自然
- `C20F` を見るにしても full record ではなく hidden subfield の観点で十分
- 次の主戦場は single byte / marker pair / short tuple の local hidden state である
