# SaGa2 `00:043E` callsite report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_043e_contract_report.md`

## 目的

- `CALL $016B -> JP $043E` の実 callsite を見て `A/D/E` の意味を照合する
- `D/E` が本当に range 指定かを確認する

## 結論

callsite 文脈から見て、`043E` の契約

- `A` = seed slot
- `E` = lower bound
- `D` = upper bound

はかなり強くなった。

特に

- `DE = $FF00` で **raw 0..255**
- `DE = $0300` で **0..3**
- `DE = $0F00` で **0..15**

を作っているように見える箇所があり、`raw % span + lower` 仮説とよく一致する。

## 1. callsite 一覧

既存 `saga2_action_dispatch_edges_pass16.csv` から、`CALL $016B` は少なくとも次を確認できる。

- `00:289C`
- `00:2AFF`
- `00:3100` 系クラスタ内の複数箇所
- `00:3DB9`
- `00:3DCB`

今回まず、明瞭に読める `289C / 2AFF / 324D / 3256 / 326D` 周辺を確認した。

## 2. `00:289C`

bytes:

```text
2894: LD A,($C455)
2897: LD C,A
2898: LD DE,$FF00
289B: LD A,$09
289D: CALL $016B
28A0: CP C
28A1: RET NC
```

解釈:

- slot = `09`
- lower = `00`
- upper = `FF`
- 返値 `A` を `C` と比較

`DE=$FF00` は `delta = 0xFF` の special case を通るので、
ここは **生の 0..255 を返す呼び方** とみるのが自然。

## 3. `00:2AFF`

bytes:

```text
2AF4: LD A,$0D
2AF6: RST $28
2AF7: LD HL,$6560
2AFA: LD A,$0A
2AFC: LD DE,$FF00
2AFF: CALL $016B
```

この callsite も

- slot = `0A`
- lower = `00`
- upper = `FF`

で、やはり **生 8bit RNG 値** を取りたい呼び方に見える。

## 4. `00:324D`

bytes:

```text
3248: LD A,$01
324A: LD DE,$0300
324D: CALL $016B
3250: OR A
3251: RET NZ
```

これは

- slot = `01`
- lower = `00`
- upper = `03`

を意味すると読むと、返値は `0..3`。

呼び出し直後に `OR A / RET NZ` があるので、
**4 分の 1 でだけ先へ進む分岐** を作っている可能性が高い。

これは range 解釈と非常によく整合する。

## 5. `00:3256`

bytes:

```text
3252: XOR A
3253: LD DE,$0F00
3256: CALL $016B
3259: LD B,A
325A: SWAP A
```

ここでは

- slot = `00`
- lower = `00`
- upper = `0F`

つまり **0..15 の nibble 値** を作っている読みが自然。

その直後に `SWAP A` をしているので、
4bit 値をそのまま nibble/table index として扱う文脈に見える。

## 6. `00:326D`

bytes:

```text
3269: LD C,A
326A: LD A,$20
326C: LD DE,$0300
326F: CALL $016B
3272: AND $03
```

ここは呼び出し後にさらに `AND $03` があるため少し冗長に見えるが、

- slot = `20`
- lower = `00`
- upper = `03`

として 0..3 を取っている読みは依然自然。

後段の `AND $03` は安全側の正規化か、以前のコード流儀の残りかもしれない。

## 7. `D/E` の向き

これらの callsite を総合すると

- `E = 00`
- `D = FF / 03 / 0F`

というパターンが多く、期待される結果は

- 0..255
- 0..3
- 0..15

である。

したがって現時点では

- `E` = lower
- `D` = upper

と置くのが最も自然。

## 8. 現時点の整理

### 確度が高いこと

- `CALL $016B` は `043E` を直接呼ぶ実 callsite
- `DE=$FF00` は raw 8bit RNG 取得
- `DE=$0300` は 0..3 取得
- `DE=$0F00` は 0..15 取得
- `E=lower`, `D=upper` の向きが強く支持される

### まだ未確定なこと

- slot `00/01/09/0A/20` の用途差
- 呼び出し側が `A` 以外の flags/H/L を使うか
- `3DB9/3DCB` 側の文脈

## 次の一手

1. `RST $10` / `RST $18` / `RST $20` を契約化する
2. slot 番号ごとの用途差を caller 群で分類する
3. `3DB9/3DCB` を追加確認して battle/action 側の利用を広げる
