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
- `reports/saga2_rng_slot07_08_offset_report.md`
- `reports/saga2_rng_damage_core_gap_report.md`
- `reports/saga2_normal_attack_entry_gap_report.md`
- `reports/saga2_battle_runtime_entry_report.md`
- `reports/saga2_battle_state_helpers_report.md`

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
- bank `0D:4440` の slot `07/08` は上位/下位 byte を別々に引いて 16bit offset を作り、`HL` から差し引く pair RNG の可能性が高い
- bank `0D:5741` では slot `33` が `DE=$1300` とともに使われ、battle 側で `0..19` index を生成している可能性が高い
- `56C0` クラスタは `window_buffer_1.particle_*` を使う particle system で、slot `33` は particle 初期配置 RNG の可能性が高い
- battle runtime helper `0D:435A` は actor page 群の同 offset byte 合計 helper 候補
- battle runtime helper `0D:4361` は bank `0C:4680 + index*2` の 2 byte table を引く state/descriptor dispatch helper 候補
- `0D:4178` 以降の `actors ($D803)` は `0xFF` sentinel の 2 byte queue entry 群候補で、action resolve 前処理に見える
- `01E3` は `JP $18CE -> CALL $04BF ; 03 5D 0F ; RET` の thin wrapper で、battle queue 中の固定 dispatch hook 候補
- `437E` は `D0xx..D4xx` actor page を `C206` ベース work buffer へ正規化展開する state staging helper 候補
- `4579` は `D040` 付近の battle stat bits を走査して `actors ($D803)` へ 2 byte entry を積む queue builder 候補
- `0D:43FB-443A` は 9 個の 16bit entry を走査し、`0C:6F82 + entry*8` から 2 byte の集約 flag を作る prepass helper 候補
- `0D:443B-4499` は battle work record から base pointer / span を取り、slot `07/08` で 16bit signed offset を作って pointer record へ書き戻す battle/RNG bridge 候補
- `449A-44F3` は record expansion helper 風だが、`443B-4499` の continuation とまではまだ確定していない
- `4024-4075` 実バイトから、`44F4` caller は `D5xx` 3-page source loop、`443A` caller は `D500/D600/D700` 3-page prepass loop、さらに中間に `D0xx` 5-page staging loopがあると読める
- `44F4-4575` は `D?xx` page の low offsets と `0F:6EC0` / `0D:6F80` table を使って `DE00` scratch record を組む deterministic staging helper 候補
- `44F4` が作る `DE10` は直後に `D849/D949/DA49` family へ書き戻されるため、`DE00` は battle controller へ戻る staging record の可能性が高い
- `4024-403E` で `DE10 -> D849/D94A/D94B` 相当の metadata writeback を行い、`4048-405A` では `D0xx` 5-page loop で `1918` と `449A` を呼び、その後 `4067-4075` で `D500/D600/D700` に対して `443A` を回す
- `405C-4066` には `CALL $0198` と条件付き `D400/D401` clear があり、従来の「単なる phase switch」より一段具体的な cluster 中継部だった
- ただし現時点では `D849/D949/DA49` の direct readback は未確認で、隣接する `D84D + 2*n` lookup 系とは分けて扱うほうが安全
- `45A8` は `DE` source から 2 byte pair を `HL` 側 page-stride で書く generic scatter writer に見え、`D849` family の direct consumer とみなす根拠は弱い
- `4361` dispatch 先と `449A-44F3` 側からも、現時点では `D849/D949/DA49` の direct readback は未確認

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
- ただし slot `07/08` も pointer / position offset 生成寄りで、damage core とは別責務の可能性がある
- ただし slot `33` は battle logic 本体より演出 particle 側に属する可能性が高い
- 既存 pass21-23 の damage 主線候補では `016B/043E` が未検出で、core damage / hit 用 RNG slot は別系統の可能性が高い
- pass19 の高スコア routine には data 誤読や effect/setup 側候補が混ざり、通常攻撃 entry の起点としては弱い
- bank `0D:40E6` は `battle_turn` / `actors` / `current_actor_index` を扱う battle runtime 入口候補で、通常攻撃探索の起点として有望
- `435A/4361` はこの battle runtime 入口配下の state helper と読むほうが自然で、RNG helper と混同しないほうが安全
- `4178-424D` は `actors` queue を走査しつつ state `04/05/06/07` と `435A` 集計を使う action resolve 前処理候補
- `01D4-01E3` は固定 inline operand つき `04BF` wrapper 群で、battle controller 側の descriptor dispatch 群に見える
- `437E` も RNG 本体ではなく、battle round 開始時の actor state / candidate 展開側に見える
- `4579` も RNG 本体ではなく、`actors` queue を構築する battle controller 前処理側に見える
- `443B-4499` は battle 側が slot `07/08` 指定で RNG を 2 回呼ぶ最初の具体的接続部として有力
- したがって battle 側での RNG の役割は、少なくとも一部で direct damage 値ではなく pointer/record 候補選択にある

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
2. `445E` ループの実初期レジスタと `BC` record ベースを確定する
3. index / seed 更新規則の確定
4. 行動順 / 命中 / ダメージ / ドロップでの消費順
5. `443B` caller を追って slot `07/08` の record writer を確定する
6. `D933` / `5FBC/60D3` を追って particle 初期化 API を固める
