# SaGa2 `5F22` Pre-Loop Setup Report

## Summary
- 現時点の high-confidence callsite では `5F22` は `60E8-611B` 親ループの先頭にのみ見えており、`CALL $5E77` より前に一度だけ走る。
- この配置から、`5F22` は player-by-player の local seed 処理そのものではなく、**親ループ突入前の pre-loop setup / global precondition helper** とみるのが自然。
- いっぽうで body 未取得のため、`visible refresh` と断定するより、`5E77` よりさらに前段の `global setup / mode-entry precondition` として持つのが安全。

## Evidence

### 1. Known callsite
```asm
60E8: CALL $5F22
60EB: CALL $5E77
60EE: LD A,$01
60F0: LD ($C709),A
60F3: CALL $611C
```

- `5F22` は `player_index ($C709)` 初期化より前にある。
- `611C` / `6157` の per-player loop より外側にある。
- `5E77` が既報どおり render/update 寄り helper なら、`5F22` はそれより前に置かれた setup helper とみるのが自然。

### 2. Contrast with `5E77`
既報の [saga2_mode_transition_helpers_report.md](/Users/hayashikentarou/Documents/New%20project%204/analysis_updates/saga2_mode_transition_helpers_report.md:1) では、
`5E77` は:

- `FF8B` 条件分岐
- `00AC`, `0177`, `0080`, `017A`, `00CA`
- VRAM/window/OAM 反映寄りの copy/update

を含む **mode transition 後の render/update helper** 候補として整理済み。

このため `5F22 -> 5E77` の並びは、

1. `5F22`: parent loop 前の global precondition/setup
2. `5E77`: visible/render-side update
3. `611C`: player-local seeded gate

という 3 段に分けるのがいちばん整合する。

## Safe Contract
現時点で安全に言える `5F22` の契約は次の程度。

- 入力: 親ループ突入直前の subsystem state
- 出力: `5E77` と `C709=1..3` loop 開始を成立させる global precondition
- 粒度: **per-player local seed helper ではなく、subsystem-entry setup helper**
- 位置づけ: `60E8-611B` を始める前の one-shot pre-loop helper

## What `5F22` Is Probably Not
- `611C` のような player-local candidate/selector seed helperではない
- `6157` のような per-player apply/staging helperでもない
- `0198` / `019E` のような hidden-local predicate/commit helperでもない

つまり `5F22` は `C20F/C73D/FF8C` の local pipeline そのものより、
**その pipeline を走らせる前に subsystem 全体を整える helper**
として持つほうが安全。

## Implication For `C2F6`
- `C2F6` producer を local gate 内に見つけられていない現状では、`5F22` はその候補を一段上の parent-loop entry へ戻す重要な境界になる。
- ただし body 未取得なので、今の段階では `C2F6` direct builder と断定せず、`hidden/shared init` へ最も近い **pre-loop entrypoint** 候補として置くのが妥当。

## Next Steps
1. `5F22` 本体バイト列を取得して direct body を切る。
2. `5E77` の caller 前提を parent-loop 文脈で再評価し、`5F22` と責務を分離する。
3. `60E8-611B` を `5F22 -> 5E77 -> 611C/6157` の 3 層として `C2F6` 探索線へ再接続する。
