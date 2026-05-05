# SaGa2 `C2F6` hidden-init candidate clusters report

## 1. 目的

- `C2F6` producer 探索を hidden/shared init 側へ寄せたうえで、次に当てる具体 cluster を A/B/C ランクで整理する
- 既存レポートだけで、visible 層を掘り直さずに進める実務順を固定する

## 2. 結論

現時点の evidence から、`C2F6` producer 候補として次に当てるべき cluster は
次の 3 群にかなり絞れる。

### Aランク

1. `01:60C0-60E1`  
   `C21F` block table + flat sentinel list builder
2. `01:60E8-611B`  
   player-by-player orchestration loop
3. `01:611C-6156`  
   `C20F + 16*player` fill と `C73D..C744` seed を伴う validator/picker

### Bランク

4. `01:6157-61FF`  
   `C200 <-> C7EE` scratch copy と `D400/D500` staging
5. `67F8-6803` を除いた banked import/export 周辺  
   visible `C200` transport の外側にある別 shadow reload 候補

### Cランク

6. runtime overlay alias 仮説  
   `C2F6` が独立 table でなく hidden tail reuse である線

要するに、次に最優先で切るべきなのは
**`60C0-6156` を hidden/shared init 入口候補としてまとめて再評価すること**
である。

## 3. Aランク cluster 1: `60C0-60E1`

既報では:

- 14件 2byte entry を走査
- `C21F + 16*block` の `+0` に source index を置く
- `DE` 側へ `FF` sentinel list を並行生成

という構造まで見えている。

これは visible selector dispatch より一段前の
**中間表 builder**
としてかなり自然で、
`C2F6` hidden backing state がこの近辺の larger block と同時に準備される可能性がある。

特に重要なのは、
まだ `DE` destination が完全固定できていない点である。

ここが `C7EE` ではなく別 flat list だと分かった以上、
`C2F6` を含む hidden shadow block と同層にある可能性はまだ残っている。

## 4. Aランク cluster 2: `60E8-611B`

`60E8-611B` は:

- `CALL $5F22`
- `CALL $5E77`
- `C709` player loop
- `611C` / `6157` 反復

という高位 orchestration loop だった。

これ自体は visible update も含むが、
**subsystem entry で一度だけ hidden/shared state を振り分ける親ループ**
としての性格が強い。

`C2F6` producer が caller 直前 local setup に見えない以上、
このレベルの orchestration で hidden state を先に整えている可能性は高い。

## 5. Aランク cluster 3: `611C-6156`

この帯では:

- `C20F + 16*player` を `FF` fill
- `C73D..C744 = F0..F7`
- `RST $08(E=$15)`
- `CALL $5F0E`
- `CALL $01B9`
- `FF8C` と `5F07` を使う gate

が見えている。

ここは visible validation だけでなく、
**player-local candidate/selector seed を hidden-local 中間表へ写す gate**
としても読める。

特に:

- `C20F` fill
- `C73D` seed
- `FF8C` 選択値

の 3 つが同じ helper にあるため、
`0198` の backing state と近い層にいる可能性がある。

したがって `611C` は、
hidden/shared init 側の候補としてかなり優先度が高い。

## 6. Bランク cluster 4: `6157-61FF`

`6157` 以降では:

- `C200 + 16*player -> C7EE` 4byte copy
- `RST $08(E=$2C/$2D)`
- `D400` clear
- `D500` fill
- `C7EE -> C200 + 16*player` 逆向き copy

が見えている。

この帯は battle-side staging としては強いが、
今の evidence では `C2F6` 直結より
**Aランク helper 群の後段 apply layer**
に見える。

したがって producer 本体としては Bランクに落とすのが妥当。

## 7. Bランク cluster 5: banked import/export の残差

`6748-6803` の `C200 <-> A600` large transport は既に除外できている。

ただしこれは裏返すと、
**それ以外の banked import/export**
にまだ余地があることを意味する。

point write が見えず、
visible helper にも出ず、
reload 的に一括復元されるなら、
`C2F6` producer はこの残差 cluster にいる可能性がある。

ただし具体 cluster がまだ粗いため、現段階では Bランクに置く。

## 8. Cランク: overlay alias

overlay alias 仮説は依然として残るが、
いまはまだ直接 evidence が薄い。

現段階でこれを上位にすると、
wider init / orchestration / import の探索より先に
抽象度の高い仮説へ飛びすぎる。

したがって alias は最後に回すのが安全。

## 9. 実務的な次の順番

次のターン以降は、次の順で当てるのがよい。

1. `60C0-60E1` の `DE` destination をさらに固定する  
2. `611C-6156` を hidden/shared seed helper として再読する  
3. `60E8-611B` 全体を subsystem entry bulk setup としてまとめ直す  
4. そのあと `6157-61FF` を apply/staging layer として分離する  
5. まだ出なければ banked import/export の残差 cluster を当てる

## 10. 次の一手

1. `60C0-60E1` の `DE` destination と `C21F` block head 以外の field をもう一段切る  
2. `611C-6156` を `0198` backing state に近い hidden seed helper 候補として整理する  
3. `60E8-611B` を mode-entry bulk setup 候補として `C2F6` 探索に再接続する
