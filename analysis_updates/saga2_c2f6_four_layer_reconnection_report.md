# SaGa2 `C2F6` Four-Layer Reconnection Report

## Summary
- `60E8-611B` 親ループまわりは、今回までの整理で **4 層モデル** としてかなり安定した。
- この 4 層を `C2F6` 探索線へ戻すと、`hidden-init 候補` と `battle-side apply` の境界は `611C / 6157` の間に引くのが最も自然。
- したがって今後の `C2F6` producer 探索では、`5F22`, `5E77`, `611C` までは上位候補として保持し、`6157` 以降は原則後段 apply layer として優先度を落としてよい。

## The Four Layers

1. `5F22`  
   one-shot global precondition / pre-loop setup
2. `5E77`  
   one-shot visible update / render-precondition
3. `611C`  
   player-local seed / validate gate  
   `C20F + 16*player`, `C73D..C744`, `FF8C`, `5F07`, `019E`
4. `6157`  
   player-local apply / staging  
   `C200 <-> C7EE`, `RST $08(E=$2C/$2D)`, `D400/D500`

## Boundary For `C2F6`

### Hidden-init side
- `5F22` は subsystem-entry の one-shot precondition helper
- `5E77` は visible/render 側だが、loop 前の one-shot precondition helper
- `611C` は local seed / selection / remap / commit を束ねる gate

この 3 層は、いずれも `6157` より前で
**candidate/selection を作る側**
に属している。

特に `611C` は:

- `C20F` local candidate workspace
- `C73D` local seed/remap table
- `FF8C -> 5F07 -> 019E`

が同居しており、`0198` backing state に最も近い。

したがって `C2F6` producer 候補としては、
現時点でも **`611C` が最上位** のままでよい。

### Apply side
- `6157` は `611C` 成功後にだけ呼ばれる
- `C7EE` scratch header を経由する
- `D400/D500` family を初期化する
- `RST $08(E=$2C/$2D)` を含む

この性質から、`6157` は
**前段で決まった candidate/selection を battle-side state へ落とす段**
と見るのが自然で、
`C2F6` direct producer を探す層としては一段後ろに置ける。

## Updated Search Order
4 層モデルを反映すると、探索順は次のように更新できる。

1. `611C-6156`  
   hidden-local seed/validate gate 本命
2. `60C0-60E1`  
   `611C` 前提の shared block/sentinel builder
3. `5F22`  
   subsystem-entry global precondition
4. `5E77`  
   mode-entry visible precondition
5. `6157-61FF`  
   battle-side apply/staging layer
6. banked import/export residuals
7. overlay alias 仮説

## Porting Implication
移植観点でも、この境界は有用。

- `5F22/5E77`: frontend or setup-adjacent orchestration
- `611C`: selector/runtime/core bridge に近い
- `6157`: battle-side staging / apply bridge

つまり TypeScript core に寄せるべきのは、
まず `611C` の seed/validate 契約であって、
`6157` の page/init/staging をそのまま core 化するより先に、
`611C` を抽象化するほうが筋がよい。

## Next Steps
1. `611C` を 4 層モデルの中核として再度詰め、`0198` との距離を確認する。
2. `60C0-60E1` の `DE` destination を再固定し、`611C` の前段 shared builder を補強する。
3. `6157` は producer 探索より後段 apply/staging として扱い、必要なら `D400/D500` field の細分化に回す。
