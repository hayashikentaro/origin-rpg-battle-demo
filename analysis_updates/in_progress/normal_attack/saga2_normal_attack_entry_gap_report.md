# SaGa2 normal attack entry gap report

## 対象

- `reports/saga2_damage_bgb_breakpoint_plan_pass19.csv`
- `reports/saga2_damage_candidate_functions_pass19.csv`
- `reports/saga2_damage_candidate_disassembly_pass19.md`
- `reports/saga2_usage_handler_names_pass28_report.md`
- `reports/saga2_usage_value_named_handlers_pass28.csv`
- 既存 `saga2_rng_damage_core_gap_report.md`

## 目的

- 通常攻撃 command の entry 側から battle core RNG へ届く探索線を作る
- 既存候補のうち、どこが本線でどこが演出/誤検出寄りかを切り分ける

## 結論

今回の再確認で、
**pass19 の高スコア candidate routine をそのまま通常攻撃本線とみなすのは危険**
だとはっきりした。

理由は 2 つある。

1. bank `0A:5440 / 56C0 / 77C0` は逆アセンブル断片が不自然で、code ではなく data 誤読を強く疑う
2. code としてまだ読める bank `08:54C0 / 55C0` は、既知の slot `07/08` や effect helper 群に寄っており、core damage RNG 直結とは言いにくい

したがって、
**通常攻撃 entry を pass19 の score 上位から選ぶ方針はいったん弱い**
と整理する。

## 1. pass19 上位候補の再確認

`saga2_damage_bgb_breakpoint_plan_pass19.csv` 上位:

- `0A:5440`
- `0A:56C0`
- `0A:77C0`
- `08:54C0`
- `07:7DC0`
- `07:5E40`

## 2. bank `0A` 候補の問題

`saga2_damage_candidate_disassembly_pass19.md` の
`0A:5440` と `0A:56C0` は、

- `RST $38` が過剰
- 算術/制御の並びが不自然
- 命令列全体が data を code として読んでいる形に近い

という特徴が強い。

したがってこれらは
**通常攻撃の実コード入口候補としては優先度を下げる** ほうが安全。

## 3. bank `08:54C0 / 55C0` の位置づけ

この cluster はまだ code として読める箇所があり、
後段で次を含む。

- `5637: CALL $430D`
- `56EA: CALL $4612`
- `572F: CALL $0E42`

また既報の slot `07/08` caller
`0D:4440` と同じく、
pointer / offset / effect 初期化寄りの流れと重なる。

したがってここは

- battle 中には実行されうる
- しかし通常攻撃の core damage / hit 式そのものではなく
- effect / record writer / setup 側の可能性が高い

とみるのが自然。

## 4. usage handler 側の限界

`saga2_usage_handler_names_pass28_report.md` と
`saga2_usage_value_named_handlers_pass28.csv`
も再確認したが、

- handler 名は broad kind にとどまる
- `battle_item_effect_handler` は拾えても
- 「通常攻撃」専用 entry までは切れていない

そのため、
usage handler pass だけで normal attack entry を固定するのはまだ難しい。

## 5. 現時点で一番安全な言い方

今わかるのは次の 4 点。

1. battle core RNG slot はまだ未発見
2. slot `33` は particle/effect 側
3. slot `07/08` は 16bit offset 生成側
4. normal attack 本線は、既存 pass19 高スコア候補の外側にある可能性がある

## 6. 探索方針の修正

通常攻撃 entry を探すには、
「damage writeback 側」や「high score routine 側」ではなく、
**battle command dispatch / actor action resolve 側から辿る** ほうが有効。

つまり次は:

1. 通常攻撃 command の dispatch value / branch を battle command 側から探す
2. そこから命中判定 block と damage amount block を分離する
3. その近傍で `016B` callsite を再探索する

## 7. 現時点の整理

### 確度が高いこと

- pass19 上位候補には data 誤読が混ざる
- bank `0A:5440 / 56C0 / 77C0` は code 候補として危うい
- bank `08:54C0 / 55C0` は effect / setup 側の可能性が高い
- 通常攻撃本線は別入口から探すべき

### まだ未確定なこと

- 通常攻撃 command の dispatch value
- 命中判定 block の bank と入口
- final damage amount block の bank と入口

## 次の一手

1. battle command dispatch / actor action resolve 側の既存レポートを起点にする
2. 通常攻撃 command value を先に固定する
3. その command 専用 branch 近傍だけで `016B` を探す
