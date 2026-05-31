# SaGa2 `019E` Outcome-Byte Priority Report

## Summary
- `019E` の immediate target を short settled-state family とみる場合、現時点では **`outcome byte` 仮説を first line**、`marker + outcome byte` を second line、`marker only` を third line に置くのが最も自然である。
- 理由は、`019E` が受け取るのが単なる真偽ではなく **resolved seed byte** であり、その値を local success-side state へ残すなら、まず意味付きの 1byte outcome とみるほうが情報保存量の面で整合するからである。
- したがって次の観測は、「どこへ書くか」だけでなく、**その byte が seed をそのまま保持するのか、ローカルな意味値へ写像された outcome なのか** を見る段階に入っている。

## 1. Why Outcome Byte Deserves Priority

現在の core chain:

```asm
614A: CALL $5F07
614D: LD HL,$C73D
6150: RST $00
6151: LD A,(HL)
6152: CALL $019E
6155: SCF
6156: RET
```

ここで `A` に入るのは resolved seed byte である。

`019E` がこの値を immediate target へ落とすなら、
最小限でも次のどちらかになる。

1. raw seed をそのまま残す  
2. seed 由来の local meaning を持つ outcome byte にする  

しかし既報どおり `019E` は単なる cache/store より
**success-side commit** とみるほうが自然なので、
優先順位としては 2 のほうが上になる。

## 2. Why Marker Is Still Second Line

marker 仮説もまだ有効である。

たとえば:

- adopted
- valid
- resolved
- committed

のいずれかを示す 1byte/2byte state かもしれない。

ただしこれだけだと、
`019E` が受け取った resolved seed byte の中身が
どこにも残らない形になりやすい。

そのため今は、
**marker only** より
**outcome を伴う形**
を一段優先するのが自然。

## 3. Safe Current Ranking

現時点の優先順位は次のように置ける。

1. outcome byte  
   local meaning を持つ 1byte result
2. marker + outcome byte  
   success/adopted と result を分けて持つ short pair
3. marker only  
   commit 成功だけを表す short state

## 4. What To Look For Next

次に観測すべき差分は:

- `A` がそのまま 1byte outcome として入るのか
- `A` が別 code/outcome に写像されてから保持されるのか
- `A` と独立に adopted/validity marker が並置されるのか

つまり、探索は「有無」より
**意味論の圧縮のされ方**
を見る段階へ入っている。

## Implication
- `019E` immediate target は outcome byte 仮説を first line に置くのが自然
- marker 仮説は残るが、いまは補助線として扱うほうが安定する
- 次の主戦場は `resolved seed -> local outcome value` の写像有無である
