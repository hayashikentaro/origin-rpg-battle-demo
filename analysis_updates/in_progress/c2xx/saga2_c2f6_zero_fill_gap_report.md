# SaGa2 `C2F6` zero-fill gap report

## 1. 目的

- `006D` caller 全体を見て `C2E0-C2FF` hidden shadow state 初期化候補があるかを確認する
- `C2F6` producer 探索で zero-fill 線をどこまで除外できるかを整理する

## 2. 結論

現時点で高確度に読める `006D` caller は、
**`C2F6` を含む `C2E0-C2FF` block を初期化していない**。

少なくとも見えている 4 系統は:

1. `0543 -> JP $006D`: `C380` 周辺 clear  
2. `5B6C: CALL $006D`: `C7E0..C7ED` を `FF` fill  
3. `612C: CALL $006D`: `C20F + 16*player` の 16 byte を `FF` fill  
4. `679C: CALL $006D`: `C2B9..C2D8` 32 byte workspace clear  

したがって `C2F6` producer 探索は、
`006D` caller の visible/runtime workspace clear 群からは
かなり切り離して考えてよい。

## 3. caller ごとの確認

### 3.1 `0543 -> JP $006D`

`item_usage_code_contexts_pass25.csv` では:

```text
0540: LD HL,$C380
0543: JP $006D
```

ここは `C380` base の clear で、
`C2xx` 域には届いていない。

### 3.2 `5B6C: CALL $006D`

既報どおり:

```text
5B64: LD HL,$C7E0
5B67: PUSH HL
5B68: LD A,$FF
5B6A: LD B,$0E
5B6C: CALL $006D
```

これは **`C7E0..C7ED` の 14 byte `FF` fill** で、
shared selector scratch の初期化。

### 3.3 `612C: CALL $006D`

既報どおり:

```text
6125: CALL $019B
6128: LD B,$10
612A: LD A,$FF
612C: CALL $006D
```

`019B` の現解釈に従えば、
ここは **`C20F + 16*player` の 16 byte local record fill** とみるのが自然。

### 3.4 `679C: CALL $006D`

usage handler cluster では:

```text
6797: LD HL,$C2B9
679A: LD B,$20
679C: CALL $006D
```

これは **`C2B9..C2D8` の 32 byte workspace clear** で、
high-range selector runtime buffer の初期化候補。

## 4. `C2F6` に届かない理由

`C2F6` を含むなら少なくとも次のどれかが見えるはずだが、
高確度 caller にはまだ出ていない。

- `HL=$C2F6`
- `HL=$C2E0` か `HL=$C2F0` を base にした fill
- `B=$10` 以上で `C2F6` を覆う `C2xx` clear

現時点で `C2xx` に触る `006D` caller は
`C20F` と `C2B9` に限られており、
**`C2E0-C2FF` block clear は未確認** のまま。

## 5. いま安全に言えること

- `C2F6` は `C200` visible record 群とは別レイヤ
- `C2F6` は `C2B9` selector workspace とも別レイヤ
- `C2F6` producer は、少なくとも既知の `006D` clear 群ではない

したがって `0198 -> 0608 -> 0661` が見る backing state は、
**より隠れた bulk init / overlay / banked load**
で準備される可能性がさらに高い。

## 6. 次の一手

1. `C2E0-C2FF` をまたぐ `0072/0067/00B5/00BC` caller を洗う  
2. `0198` caller 直前の wider init cluster を探す  
3. `C2F6` を単独 state でなく、別 workspace の overlay alias として疑う
