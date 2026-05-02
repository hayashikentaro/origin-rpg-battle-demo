# SaGa2 random_seeds caller report

## 対象

- `rom/common.i`
- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`

## 目的

`random_seeds ($C0A0)` を参照するコード箇所を列挙する。

## 結論

ROM 全体の静的探索で、`random_seeds ($C0A0)` を**直接参照する箇所は 2 本**だけ確認できた。

1. `00:0258` 付近
2. `00:0440` 付近

## 1. `00:0258` 付近

### 参照形

```text
21 A0 C0
```

### 周辺バイト列

```text
06 40
21 A0 C0
F0 04
22
3C
05
20 FB
```

### 擬似コード

```text
B = $40
HL = random_seeds ($C0A0)
A = DIV ($FF04)
loop 64 times:
  (HL+) = A
  A++
```

### 判断

これは `random_seeds` 配列 64 byte を初期化するルーチン候補。

さらにこの近傍は

- RAM 初期化
- ワーク領域セットアップ
- 割り込み/システム初期化

に続く位置なので、**起動時またはリセット直後の seed 初期化** とみるのが自然。

## 2. `00:0440` 付近

### 参照形

```text
21 A0 C0
```

### 周辺バイト列

```text
21 A0 C0 C7 34 6E 26 40 3E 0F EF 66 EF ...
```

### 擬似コード

```text
HL = random_seeds ($C0A0)
HL += A
(*HL)++
L = *HL
H = $40
switch bank = $0F
H = *(HL)
restore bank
```

### 判断

これは `random_seeds[index]` を更新してから `data_rng (0F:4000-40FF)` を引く
**RNG 消費ルーチン本体** の強い候補。

## direct caller 探索結果

以下の direct xref は今回の静的探索で未検出だった。

- `CALL 00:0258`
- `JP 00:0258`
- `CALL 00:0440`
- `JP 00:0440`

## 解釈

つまり `random_seeds` を直接触るコードは少なくとも 2 本あるが、
それらの入口は

- 直前からの fallthrough
- jump table / dispatch table
- 別ルーチンからの間接制御移動

のいずれかで到達している可能性が高い。

## 現時点で列挙できる「呼び出し元」

静的に確定して言えるのは、厳密な callsite というより
**`random_seeds` の直接利用元ルーチン一覧**:

- `00:0258` 相当の seed 初期化ルーチン
- `00:0440` 相当の seed 消費 + `data_rng` lookup ルーチン

## 次の一手

1. `00:0258` へ fallthrough する起動シーケンスを復元する
2. `00:0469` / `00:0493` / `00:0CC8` の wrapper 関係を整理する
3. `00:068F` と `FF89/FF8A` の意味を切る
