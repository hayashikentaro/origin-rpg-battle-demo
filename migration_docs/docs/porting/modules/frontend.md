# Frontend Module

## 対象

Godot 側で担当する領域。

- UI
- 入力
- 表示
- マップ
- テキスト
- スクリプト VM の反映

## 主要ソース

- `reports/saga2_script_vm_spec_pass7.md`
- `reports/saga2_script_engine_report.md`
- `reports/saga2_script_event_integration_pass8_report.md`
- `reports/saga2_maps_pass18_report.md`
- `reports/saga2_collision_report.md`
- `reports/saga2_action_word_pass13_report.md`
- `reports/saga2_action_dispatch_pass16_report.md`
- `reports/saga2_action_call_targets_pass17_report.md`
- `reports/saga2_usage_handler_names_pass28_report.md`

## VM の基本方針

script VM は Godot ノードを直接触らず、中立アクション列を返す。

- `text`
- `flush_text`
- `set_actor_context`
- `flow`
- `flag`
- `inventory`
- `battle`
- `menu`
- `unknown_opcode`
- `end`

## frontend でやること

- neutral actions を画面や入力へ接続する
- テキスト制御や speaker context を表示へ反映する
- map / tile / object action を scene 操作へ変換する
- battle 開始や menu 起動を UI レイヤへ渡す

## map 系で確度が高いこと

- map index は 512 record
- unique header は 213
- 511 map で parse 成功
- tile action と object/NPC stream はかなり実用的な形まで来ている

## 注意点

- low-confidence opcode は stub 扱いにする
- action word は raw と classification を両持ちする
- rendering/menu と core battle logic を混ぜない

## 最初の実装単位

1. text window adapter
2. script VM action dispatcher
3. battle start bridge
4. map action resolver
