# SaGa2 `019E` Local-Result-Slot Isolation Report

## Summary
- `611C` 周辺の既存 evidence を突き合わせると、`019E` の immediate target として最も自然に残るのは、**inner core と同居する未命名 local result slot / shadow byte** である。
- すでに除外優先度を下げられるものは多い。`C73D` は source、`FF8C` は token、`6157` 以降の `C7EE/C200/D400/D500` は後段 apply/staging 層であり、いずれも `019E` first writeback としては遠い。
- `C20F` は近い候補だが、現段階では workspace/precondition buffer としての証拠のほうが強いため、まず疑うべきは **`611C` inner core のすぐ外側にある別の local hidden result field** である。

## 1. Elimination Map

`019E` の immediate target 候補を、今ある evidence で消去法にかけるとこうなる。

### Low fit
- `C73D..C744`
- `FF8C`
- `C7EE`
- `C200`
- `D400/D500`

### Medium fit
- `C20F + 16*player` のどこか

### Highest fit
- `611C` core と同じ layer にある未命名 local hidden result slot

## 2. Why Source/Token Are Unlikely

`C73D` は:

- `611C` 前半で毎回 `F0..F7` へ初期化
- `5F07` index で参照
- `019E` 入力 byte の source

`FF8C` は:

- `01B9` が materialize する current-selection token
- `0xFF` invalid sentinel
- `5F07` 前段の token storage

どちらも **`019E` 入力を作る側**
としては十分説明できている。

したがって `019E` がその直後にこれらへ書き戻す必要性は薄い。

## 3. Why Apply/Staging Is Too Far

`6157` は:

- `611C` 成功後にだけ呼ばれる
- `C200 <-> C7EE`
- `D400/D500` init

を担う後段 apply/staging helper である。

このため `019E` の first writeback が
いきなり `6157` 側の state に落ちるなら、
`611C` / `6157` の層境界が不自然になる。

いまの 4 層モデルでは、
`019E` は **candidate/selection 確定層**
にあるとみるほうがきれいに収まる。

## 4. Why `C20F` Is Not Yet The Best First Guess

`C20F + 16*player` は確かに近い。

理由:

- `611C` 冒頭で直接 clear される
- player-local 16byte stride
- seeded candidate workspace

しかし evidence 上は、
まだ **precondition/work buffer**
としての役割が強い。

つまり:

- `019E` が `C20F` 内 field を更新しているかもしれない
- ただし今それを first hypothesis にすると、
  workspace と result slot を早合点で混同しやすい

そのため今は、
`C20F` を secondary candidate に置きつつ、
まずは **未命名 local result field**
を先に立てるのが安全。

## 5. Best Current High-Level Model

```ts
prepareLocalWorkspace(player)        // C20F
initLocalSeedTable()                 // C73D
const token = resolveSelection()     // FF8C
const localIndex = remapToken(token) // 5F07
const seedByte = C73D[localIndex]
const localResult = commitSeed(seedByte) // 019E
applyLater(localResult)              // 6157 and/or shared reflection
```

この形だと、
`019E` は workspace 準備の最後ではなく、
**workspace を使って導いた選択結果を local result として確定する点**
に置かれる。

## 6. Updated Search Focus

次に local 観測を進めるなら、
焦点は次の順でよい。

1. `611C` inner core 直近の未命名 local hidden result slot  
2. `C20F` 内 hidden field 仮説  
3. `019E` 後段で shared `C2F6` presence に反映される橋  

## Implication
- `019E` immediate target の最有力は未命名 local result slot
- `C20F` は依然候補だが second line に下げてよい
- これで次の探索単位は `611C` core 周辺の local hidden state にかなり集中できる
