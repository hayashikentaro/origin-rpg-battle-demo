# SaGa2 `5E77` Parent-Loop Context Report

## Summary
- `5E77` は既報どおり `FF8B` 条件分岐と copy/update 系 helper 群を含む visible/render-side helper だが、`60E8-611B` 親ループ文脈では役割がもう一段絞れる。
- `CALL $5F22` の直後、`player_index ($C709)` 初期化より前に一度だけ走るため、`5E77` は per-player gate (`611C`) の一部ではなく、**parent loop 開始直前の mode-entry visible update / render-precondition helper** とみるのが自然。
- これにより `5F22 -> 5E77 -> 611C/6157` は、`global precondition -> visible/update precondition -> player-local seed/apply loop` の 3 層としてきれいに分離できる。

## Evidence

### 1. Parent-loop placement
```asm
60E8: CALL $5F22
60EB: CALL $5E77
60EE: LD A,$01
60F0: LD ($C709),A
60F3: CALL $611C
```

- `5E77` は `C709` の player loop より外側にある。
- `611C/6157` のように player ごとに繰り返されない。
- `5F22` で subsystem-entry の前提を整えたあと、`5E77` が visible/update 側を整えてから local seed loop に入る、という順序がもっとも整合する。

### 2. Existing helper profile
既報の [saga2_mode_transition_helpers_report.md](../frontiers/saga2_mode_transition_helpers_report.md) では `5E77` は:

- `FF8B` を条件に分岐
- `00AC`, `0177`, `0080`, `017A`, `00CA` を通る
- VRAM/window/OAM 反映寄りの copy/update を伴う

と整理されている。

この性質は parent-loop 文脈でも変わらず、むしろ
`611C` の `C20F/C73D/FF8C` local pipeline と責務がまったく異なることを補強する。

## Safe Contract
現時点で安全に言える `5E77` の契約は次の程度。

- 入力: `5F22` 後の subsystem-entry state
- 出力: `611C` seeded gate を開始できる visible/render-side precondition
- 粒度: **one-shot mode-entry visible update helper**
- 位置づけ: parent loop の player-local 処理に入る直前の render/update step

## Relation To `5F22`
- `5F22`: global precondition / pre-loop setup
- `5E77`: visible/update precondition
- `611C`: player-local seeded gate
- `6157`: per-player apply/staging

この分け方なら、`5F22` と `5E77` をどちらも「前段 helper」と見つつ、
`5F22` は subsystem state 側、`5E77` は visible/render 側、と責務を分離できる。

## Implication For `C2F6`
- `5E77` は parent-loop entry に置かれていても、依然として visible/update 側の helper とみるのが自然で、`C2F6` hidden backing state の direct producer 候補には上がらない。
- したがって `C2F6` 探索線では、`5E77` は producer 候補というより **hidden line へ入る前に除外できる visible boundary** を強める材料になる。

## Next Steps
1. `5F22` direct body と `5E77` direct body を並べて、pre-loop 2段の境界をさらに固める。
2. `6157` をこの 3 層構造の後段 apply/staging として再接続する。
3. `60E8-611B` 全体を `global -> visible -> local seed/apply` の parent setup として `C2F6` 探索線へ戻す。
