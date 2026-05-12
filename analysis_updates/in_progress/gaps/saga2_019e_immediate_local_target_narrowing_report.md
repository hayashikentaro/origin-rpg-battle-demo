# SaGa2 `019E` Immediate-Local-Target Narrowing Report

## Summary
- `019E` の first writeback を local hidden 側とみる前提に立つと、**その immediate target は `C73D` や `FF8C` のような前段 source/token ではなく、`611C` local gate の中にある別の result slot** とみるのが最も自然。
- `C20F` も player-local selector workspace として近い候補ではあるが、現時点では `611C` 入口で全 `FF` clear される前提 buffer としての性格が強く、`019E` がその既知 field を直更新する証拠はまだない。
- したがって次に最も疑うべきなのは、**`C20F` 既知領域そのものより、`611C` 周辺でまだ名前のついていない local hidden result field / shadow byte** である。

## 1. What `019E` Definitely Receives

`611C` 後半:

```asm
614A: CALL $5F07
614D: LD HL,$C73D
6150: RST $00
6151: LD A,(HL)
6152: CALL $019E
```

ここから確定しているのは:

1. `5F07` は local index を返す  
2. `C73D[index]` は resolved seed byte source  
3. `019E` はその 1byte seed を受け取る  

つまり `019E` は、
**source table から読んだ byte を消費する側**
であって、
source そのものを構築する helper ではない。

## 2. Why `C73D` Is Unlikely To Be The Target

`C73D..C744` は:

- `611C` 前半で `F0..F7` に毎回初期化される
- `5F07` の返す index で読まれる
- `019E` へ渡す直前の source table として使われる

この性格からすると、
`019E` が直後に再び `C73D` を更新する必要は薄い。

とくに現時点の evidence では、
`C73D` は **local seed source**
として十分に説明できている。

したがって `019E -> C73D writeback` は優先度を下げてよい。

## 3. Why `FF8C` Is Unlikely To Be The Target

`FF8C` は:

- `01B9` が materialize する current-selection token
- `0xFF` invalid sentinel を持つ
- `5F07` に渡す前段 token storage

として整理できている。

このため `019E` の役割は、
`FF8C` を further resolve したあとに得られた
resolved seed byte の commit にある。

要するに `FF8C` は
**`019E` の入力を作る前段 token**
であり、直受け先としては遠い。

## 4. `C20F` Is Close But Not Yet Confirmed

`C20F + 16*player` は:

- `611C` 入口で `FF` 16byte clear
- seeded candidate gate の local work
- selector/high-range path でも読む

という意味で、
`019E` immediate local target 候補としては近い。

ただし現時点で強いのは
**workspace / precondition buffer**
としての性格であって、
`019E` が `C20F` 内のどこか既知 field に書く証拠はまだない。

したがって今の段階では:

- `C20F` を完全除外はしない
- しかし first hypothesis は `C20F` 直更新より
  **別の local hidden result slot**

とするほうが安全である。

## 5. Best Current Reading

もっとも自然な高位像は次のようになる。

```ts
const token = materializeSelection()       // FF8C
const localIndex = remapToken(token)       // 5F07
const seedByte = C73D[localIndex]          // source
commitToLocalHiddenResult(seedByte)        // 019E
```

ここで `commitToLocalHiddenResult()` は:

- `C73D` source を更新するのではない
- `FF8C` token を更新するのでもない
- `6157` apply/staging state を直接更新するのでもない

という条件を満たす、
`611C` local gate の内側 result slot を指す。

## 6. Search Consequence

次に `019E` を詰めるときの immediate local target 観測順は:

1. `611C` 周辺の未命名 local hidden result field  
2. `C20F` 内 hidden field 仮説  
3. `C2F6` への later reflection  

の順でよい。

## Implication
- `019E` immediate target は `C73D` でも `FF8C` でもない
- `C20F` は近いが、まだ前提 workspace としての証拠のほうが強い
- いま一番自然なのは `611C` の未命名 local hidden result slot 仮説である
