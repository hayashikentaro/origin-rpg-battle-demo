# SaGa2 `60C0-6156` hidden-seed layer report

## 1. 目的

- `60C0-6156` を `C2F6` producer 候補に最も近い hidden/shared seed layer としてまとめ直す
- `60C0-60E1`, `60E8-611B`, `611C-6156` の役割差を保ったまま、どこが hidden backing state に近いかを整理する

## 2. 結論

現時点で `C2F6` producer に最も近い cluster は、
**`60C0-6156` 全体を 3 段の hidden/shared seed layer として読む線**
だと考えるのがいちばん整合する。

この 3 段は次のように分けるのが自然。

1. `60C0-60E1`: **packed-entry -> block/sentinel 中間表 builder**  
2. `60E8-611B`: **player-by-player orchestration / entry bulk setup**  
3. `611C-6156`: **player-local candidate/selector seed + gate helper**

重要なのは、`6157-61FF` 以降の apply/staging 層よりも、
**`611C-6156` のほうが `0198` backing state に近い匂いを持っている**
ことだ。

したがって次に最優先で詰めるべきは、
`60C0` の `DE` destination そのものより、
**`611C` がどの hidden-local 中間表を前提に gate を返しているか**
である可能性が高い。

## 3. 第1段: `60C0-60E1`

既報の通りこの段は:

- 14件 2byte entry を走査
- `C21F + 16*block` の `+0` へ `sourceIndex`
- `DE` 側へ `FF` sentinel list

を並行生成する builder だった。

これは `C2F6` direct write ではないが、
visible dispatch 層より一段前の
**hidden/shared 中間表構築**
として扱うのが自然である。

ただしここだけでは、
`C2F6` と直接つながる証拠はまだ弱い。

## 4. 第2段: `60E8-611B`

この帯は:

- `CALL $5F22`
- `CALL $5E77`
- `C709` player loop
- `611C` / `6157` を反復

という高位 orchestration loop だった。

ここで大事なのは、
`611C` と `6157` を単発 helper でなく、
**subsystem entry で繰り返し適用する parent loop**
の中に置いていることだ。

`C2F6` producer が caller 直前 local setup に見えないのなら、
このレベルの parent loop で hidden/shared state を前置きしている可能性は高い。

## 5. 第3段: `611C-6156`

この帯では:

- `C20F + 16*player` を `FF` fill
- `C73D..C744 = F0..F7`
- `RST $08(E=$15)`
- `CALL $5F0E`
- `CALL $01B9`
- `FF8C` / `5F07` を使う gate
- `C73D + A` を `019E` へ流す

が見えている。

ここで目立つのは、
visible event/message というより
**candidate/selector seed と current pick を束ねる中間層**
の匂いが強いことだ。

特に:

1. player-local 16byte fill (`C20F + 16*player`)  
2. 8要素 seed (`C73D..C744`)  
3. current selection (`FF8C`)  
4. remap/resolve (`5F07`, `C73D + A`, `019E`)

が 1 本に集まっている。

この密度は、`0198` が後段で見る
optional presence backing state と層が近いことを示唆する。

## 6. なぜ `611C` が最重要か

`60C0` は builder だが、まだ output destination が粗い。
`60E8` は parent loop だが、抽象度が高い。

それに対して `611C` は:

- player-local state を直接初期化し
- selector seed を直接置き
- current selection gate を直接返す

という **中間表と gate の接点** にいる。

したがって `C2F6` producer を hidden/shared init 側から絞るなら、
現時点で最も再読価値が高いのは `611C-6156` である。

## 7. `6157-61FF` を一段後ろへ置く理由

`6157-61FF` は:

- `C200 <-> C7EE` 4byte scratch copy
- `D400/D500` 初期化
- `RST $08(E=$2C/$2D)`

などから、
**apply/staging 層**
としては非常に強い。

ただし今の evidence では、
`C2F6` backing state を作る層というより
`611C` 以前に整えた中間表を
battle-side staging へ落とす後段に見える。

そのため producer 本体としては、
`611C` より優先度を下げるのが妥当である。

## 8. 安全な高位擬似コード

現時点での安全な高位擬似コードは次の程度。

```ts
function buildSharedHiddenSeedLayer(entries) {
  buildPackedEntryBlockIndex(entries)   // 60C0

  for (player of players_1_to_3) {      // 60E8
    if (!seedAndValidatePlayerLocalCandidate(player)) { // 611C
      retryPreviousOrCurrentPlayer()
      continue
    }
    applyBattleSideStaging(player)      // 6157
  }
}
```

ここで `seedAndValidatePlayerLocalCandidate()` が、
いま最も `C2F6` backing state に近い候補である。

## 9. `C2F6` 探索への意味

この整理により、次の探索順はさらに明確になる。

1. `611C-6156` を hidden seed helper 候補として最優先で再読する  
2. その前提入力として `60C0-60E1` の `DE` sentinel 出力を必要範囲だけ確認する  
3. `60E8-611B` は subsystem entry bulk setup として補助的に扱う  
4. `6157-61FF` は apply/staging 層として一段後ろに回す

## 10. 次の一手

1. `611C-6156` の `RST $08(E=$15)` / `CALL $01B9` / `CALL $019E` をまとめて contract 化する  
2. `60C0` の `DE` destination を hidden flat sentinel list 候補として再固定する  
3. `60E8-611B` を `mode-entry bulk setup` として `C2F6` 探索線へ正式に再接続する
