# RNG Module

## 対象

TypeScript `rng` モジュールで再現する領域。

- 戦闘ダメージや分岐に使う乱数供給
- 将来的な成長 / ドロップ / 変身補助乱数

## 現時点の直接ソース

- `reports/saga2_damage_formula_pass21_report.md`
- `reports/Saga2DamageModelPass21.gd`
- `reports/Saga2DamagePipelinePass22.gd`
- `reports/saga2_growth_rng_structural_report.md`
- `reports/saga2_growth_rng_structures.json`
- `reports/saga2_random_seeds_callers_report.md`
- `reports/saga2_rng_entrypoints_report.md`
- `reports/saga2_rng_wait_io_report.md`
- `reports/saga2_ff89_behavior_report.md`
- `reports/saga2_0469_state_machine_report.md`
- `reports/saga2_input_wrappers_report.md`
- `reports/saga2_rng_battle_reachability_report.md`
- `reports/saga2_043e_contract_report.md`
- `reports/saga2_0306_divmod_report.md`
- `reports/saga2_02f0_mul_report.md`
- `reports/saga2_043e_callsite_report.md`
- `reports/saga2_rst10_report.md`
- `reports/saga2_rst18_report.md`
- `reports/saga2_rng_slot_classification_report.md`
- `reports/saga2_rng_battle_slot33_report.md`
- `reports/saga2_particle_state_machine_report.md`

## ROM から直接確定した構造

- `data_rng` は `bank $0F:$4000` の 256 byte table
- 次ラベル `data_sine` が `0x4100` にあるため、サイズはちょうど 256 byte
- テーブルは `0x00-0xFF` を一度ずつ含む順列になっている
- `00:0440` 付近に `random_seeds ($C0A0)` を increment して `0F:40xx` を引く強い参照候補がある
- `00:0258` 付近に `random_seeds ($C0A0)` を 64 byte 初期化する強い参照候補がある
- `00:0258` は起動シーケンスから fallthrough で到達する
- `00:0469` は `00:0493` / `00:0CC8` などの wrapper が存在する入力 repeat 制御候補
- `00:068F` は RNG 専用ではなく、入力待ち / フレーム更新の共有ルーチン候補
- `FF8A` は wrapper の戻り値に使われる有効入力値候補
- `FF89` は `00:0469` の分岐条件に使われる入力/状態フラグ候補
- `FF89` は `00:29A3` で 0..4 の方向 index 風値へ変換されるため、direction/button bitfield の可能性が高い
- `C774=0x1E/0x05` は key repeat の初回遅延 / 連続間隔候補
- `00:049D` / `00:04A6` は `FF89==0` を待つ input release wrapper 候補
- `00:043E` は dispatch table 公開入口候補で、`0440` はその内部本体の可能性が高い
- `00:043E` は `A=seed slot` と `D/E=range` を受け、`data_rng` 生値を modulo で範囲縮小して `A` で返す helper 候補
- callsite では `DE=$FF00/$0300/$0F00` が現れ、`E=lower`, `D=upper` の向きが強く支持される
- `00:0306` は `H/L -> quotient,remainder` の div/mod helper 候補で、`043E` は remainder 側を使っている可能性が高い
- `00:02F0` は `H*L -> HL` の 8bit multiply helper 候補
- `RST $10` は `06B0` 実行後に VBlank 近辺まで待つ frame sync helper 候補
- `RST $18` は `A` を DMA source page として OAM DMA を起動する helper 候補
- `00:068F` は `RST $18` を使って OAM staging page を OAM へ反映している可能性が高い
- slot `07/08` は battle / item 系 caller、`0C/0D` は 0..1 binary pair caller、`00/01/09/0A/20` は action / field / script 側 caller で見えている
- bank `0D:5741` では slot `33` が `DE=$1300` とともに使われ、battle 側で `0..19` index を生成している可能性が高い
- `56C0` クラスタは `window_buffer_1.particle_*` を使う particle system で、slot `33` は particle 初期配置 RNG の可能性が高い

したがって、これは単純な seed 値保存域ではなく、lookup/permutation 型の補助表である可能性が高いです。

## 現状

乱数ルーチン単体の実行フローはまだ未確定です。ただし、battle 側の仮説だけだった状態から、少なくとも ROM 上に専用 256 byte table があることは確認できました。

- ダメージ算出で `rng & 0x03` 相当の分散を使う仮説がある
- 乱数値そのものは table 参照や index 更新を伴う可能性がある
- 少なくとも 1 本は RAM seed byte -> `data_rng` lookup の形が見えている
- `random_seeds` への direct 参照は現時点で `00:0258` と `00:0440` の 2 箇所のみ確認
- direct call/jp は `00:0440` ではなく `00:0469` に集まっている
- ただし `0469` は RNG API ではなく、待機/入力制御の key repeat ルーチンとして読むほうが自然になった
- したがって `0440` と `0469` は ROM 上で隣接していても、論理的には別責務の可能性がある
- `0CC4` 周辺は fresh input wait の高位 API と見なすほうが自然
- `043E/0469/049D` は usage handler 側の dispatch table に載るため、battle 専用 helper と断定する根拠は弱い
- `RST $28 -> 04B1` は ROM bank swap helper で、`043E` の `0F:4000` 参照を支えている
- したがって `043E` の一般ケースは unbiased scale より `raw % span + lower` に近い可能性がある
- `02F0-0306` は bank0 arithmetic helper 帯として読める
- `068F` は `RST $10` と `RST $18` を下位 primitive に持つ高位 wait/update/OAM flush routine と見なせる
- `043E` の slot は少なくとも単一用途ではなく、caller cluster ごとに使い分けられている可能性が高い
- battle 側には少なくとも slot `07/08` に加えて slot `33` caller が存在する
- ただし slot `33` は battle logic 本体より演出 particle 側に属する可能性が高い

## 実装方針

最初は ROM 完全再現よりも、注入可能なインターフェースで始めるのが安全です。

- `next(): number`
- `peek?(): number`
- `fork?(seed): Rng`

ROM 実装が確定したら、内部を table-driven 実装に差し替える。

## battle 側との境界

- `battle` は RNG 実装詳細を知らない
- `rng` は seed 更新と値供給だけを担当する
- ROM 実機再現が進んだら実装を差し替えられる形にする

## 追加解析の優先度

1. damage / hit 本体で使う slot を別系統で探す
2. index / seed 更新規則の確定
3. 行動順 / 命中 / ダメージ / ドロップでの消費順
4. `D933` / `5FBC/60D3` を追って particle 初期化 API を固める
