# SaGa2 growth / rng reverse lookup report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- `rom/data.s`

## 目的

`data_growth_table` と `data_rng` を参照するコード箇所を ROM から逆引きする。

## 結論

### `data_rng`

`data_rng` については、**強い参照候補を 1 本確認** できた。

### `data_growth_table`

`data_growth_table (0C:7FB0)` と `data_ability_learning_thresholds/results (0C:7FD0-7FFF)` については、**今回の静的探索では direct ref を未確認**。

ただし、同じ bank `0C` 上位アドレス帯を読む近縁アクセサは確認できた。

## 1. `data_rng` の強い参照候補

### 候補ルーチン

- ROM offset `0x0440`
- bank/address では `00:0440`

### 周辺バイト列

```text
21 A0 C0 C7 34 6E 26 40 3E 0F EF 66 EF ...
```

### 擬似コード

```text
HL = random_seeds ($C0A0)
HL += A                     ; RST $00 helper
(*HL)++                     ; seed byte increment
L = *HL
H = $40
switch bank = $0F
H = *(HL)                   ; read byte from 0F:40xx
restore bank
```

### 解釈

- `random_seeds` は `common.i` で `$C0A0`
- low byte は increment 後の seed 値
- high byte `$40` と bank `$0F` により、参照先は `0F:40xx`
- `data.s` では `0F:4000` が `data_rng`

したがって、このルーチンは

- RAM 上の seed byte を進める
- その値を index にして `data_rng` を引く

という lookup-based RNG の入口候補としてかなり強い。

## 2. `bank 0F` 参照の切り分け

`bank 0F` への切替自体は少数しかないが、すべてが `data_rng` ではない。

確認できた別用途候補:

- `00:11C6` 付近
- `00:1557` 付近
- `00:1665` 付近

特に `00:1665` は

```text
21 38 42
3E 0F
```

を含み、`0F:4238` 参照なので `data_rng` ではなく
`data_window_oam_template_pos` 側と見るのが自然。

## 3. `data_growth_table` の direct ref 探索結果

以下は未検出:

- `LD HL,$7FB0`
- `LD DE,$7FB0`
- `LD HL,$7FD0`
- `LD DE,$7FD0`
- `LD L,$B0` / `LD H,$7F` の近接組み立て
- `LD L,$D0` / `LD H,$7F` の近接組み立て
- `base $B0/$D0 + index -> H=$7F` の加算組み立て

つまり、今回の静的探索では

- `growth_table` が未使用
- あるいは別ルーチン経由の強い間接参照
- あるいは今回まだ未復元の banked code / dispatch を通る

のいずれか。

## 4. `growth` 周辺の近縁アクセサ

### `00:3F0D` 付近

```text
3E 80 81 6F 3E 7E CE 00 67 3E 0C CD D2 00
```

擬似コード:

```text
L = $80 + C
H = $7E + carry
switch/read bank $0C
```

これは `0C:7E80 + C` を読む computed-address 型アクセサ。

### `01:6350` 付近

```text
21 80 7F
...
3E 0C CD D2 00
```

擬似コード:

```text
HL = $7F80
HL += C                     ; via RST $00 helper
switch/read bank $0C
```

これは `0C:7F80 + index` を読む accessor。

## 5. 現時点の判断

`growth` テーブル群は、少なくとも「即値で `$7FB0/$7FD0` をそのまま持つ単純参照」では見えていない。

一方で `0C:7E80` や `0C:7F80` を読む computed-address 型アクセサがあるため、
`growth_table` も同系統の

- base address を演算で組み立てる
- 汎用 banked read に渡す
- pointer table / jump table から間接的に選ばれる

のどれかである可能性が高い。

## 次の一手

1. `CALL $00D2` の呼び出し元を bank `0C` 前提で分類する
2. 戦闘後処理や成長メッセージ周辺の call tree を追う
3. `random_seeds ($C0A0)` の呼び出し元を列挙して、`data_rng` 消費箇所を用途別に分ける
