# SaGa2 RNG battle reachability report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 damage / usage handler reports

## 目的

- `00:0440` が battle 側から静的に見えるかを確認する
- 見えない場合は、どの系統に近いかを整理する

## 結論

現時点の静的解析では、**`00:0440` を battle / damage 系から直接つなぐ証拠は未検出**。
その一方で、`00:043E` / `00:0469` / `00:049D` は bank0 の dispatch table に載っており、
既存 `usage handler` 解析では **rendering / menu / item-usage helper 群** に近い位置にいる。

したがって、少なくとも今ある静的材料だけでは

- `0440` を battle RNG API と断定することはできない
- `043E-04A6` 周辺は UI / menu / input helper クラスタとして扱うほうが安全

という整理になる。

## 1. `0440` への direct xref

既存 reverse lookup と今回の再確認では、`00:0440` そのものへの

- `CALL $0440`
- `JP $0440`

は未検出。

これは以前の `random_seeds` レポートとも一致する。

## 2. `043E` は dispatch table に載っている

既存 `usage handler` レポートでは、bank0 dispatch table に

```text
0168: JP $03BC
016B: JP $043E
016E: JP $1712
0171: JP $0469
0174: JP $049D
```

が並んでいる。

出典:

- `saga2_usage_handlers_pass27.csv`
- `saga2_usage_handler_names_pass28.csv/.md`

## 3. この dispatch table の既存解釈

`usage handler` 側ではこの一帯は

- rendering
- menu
- item usage helper
- input / LCD / OAM support

に近い bank0 helper 群として扱われている。

特に `0469` と `049D` は、今回の追加解析で

- key repeat
- input release wait

として非常に自然に読めるようになった。

このため、`043E` も同じ helper cluster に属する可能性が高い。

## 4. `043E-0468` の局所構造

周辺 bytes:

```text
043E: D5 E5
0440: 21 A0 C0 C7 34 6E 26 40 3E 0F EF 66 EF ...
0465: 7D 83 E1 D1 C9
```

観察点:

- `043E` の `PUSH DE / PUSH HL` から始まり
- `0465-0468` の `... POP HL / POP DE / RET` で閉じる
- よって `0440` は `043E` の内部本体で、公開入口名はむしろ `043E` 側の可能性がある

この形なら、dispatch table が `043E` を指していることとも整合する。

## 5. battle 側レポートとの照合

既存 damage / upstream reports を再確認しても、

- `0440`
- `043E`
- `random_seeds`
- `data_rng`

を battle 候補へ直接つなぐ明示的な記述は見つからなかった。

現状 battle 側で見えているのは

- damage writeback 候補
- upstream arithmetic helper 群
- banked data / ability table 参照候補

までで、RNG helper 入口まではまだ届いていない。

## 6. 現時点の整理

### 確度が高いこと

- `0440` そのものへの direct xref は未検出
- `043E` は dispatch table に公開されている helper 入口候補
- `0469` / `049D` は battle RNG より input/UI helper として読むほうが自然
- `043E-04A6` 周辺は bank0 helper cluster の可能性が高い

### まだ未確定なこと

- `043E` が純粋 RNG helper か、他の UI helper と複合しているか
- battle 側が `043E` を経由して間接的に使うかどうか
- `A/B/C/D/E` のどのレジスタが RNG seed slot / range 指定に使われるか

## 次の一手

1. `043E` の入出力レジスタ契約を局所解析する
2. `RST $00 / $18 / $20` helper を確定して `043E` の意味を上げる
3. battle 側は `ability table` / `upstream arithmetic helper` から別系統で追う
