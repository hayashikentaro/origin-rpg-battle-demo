# SaGa2 `00:02F0` multiply helper report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_0306_divmod_report.md`

## 目的

- `00:02F0` の算術意味を式化する
- `02F0-0306` を bank0 arithmetic helper 群として並べる

## 結論

`00:02F0` は **8bit unsigned multiply helper** とみるのが最も自然。

入力:

- `H` = multiplier
- `L` = multiplicand

出力:

- `H:L` = 16bit product

つまり

```ts
HL = H_in * L_in;
```

の helper 候補。

## 1. 実コード

```text
02F0: PUSH AF
02F1: PUSH BC
02F2: LD B,$08
02F4: XOR A
02F5: LD C,A
02F6: RR H
02F8: JR NC,$02FB
02FA: ADD A,L
02FB: RRA
02FC: RR C
02FE: DEC B
02FF: JR NZ,$02F6
0301: LD H,A
0302: LD L,C
0303: POP BC
0304: POP AF
0305: RET
```

## 2. 読み筋

これは shift-and-add 型 multiply の定型に近い。

観察点:

- `B=8` で 8 回ループ
- `RR H` で multiplier の bit を 1bit ずつ取り出す
- bit が立っていれば `A += L`
- そのあと `A` と `C` を右回転して 16bit 部分積を育てる
- 最後に `H=A`, `L=C`

よって `A:C` が最終 16bit 積、返値 `HL` はそのコピーと読むのが自然。

## 3. 擬似コード

```ts
function mul8x8(multiplier: number, multiplicand: number): number {
  let hi = 0;
  let lo = 0;
  let m = multiplier;

  for (let i = 0; i < 8; i++) {
    const bit = m & 0x01;
    m >>>= 1;

    if (bit) {
      hi = (hi + multiplicand) & 0xff;
    }

    const carryFromHi = hi & 0x01;
    hi >>>= 1;
    lo = ((carryFromHi << 7) | (lo >>> 1)) & 0xff;
  }

  return (hi << 8) | lo;
}
```

より直感的には:

```ts
return (multiplier * multiplicand) & 0xffff;
```

## 4. `0306` との対比

近傍 helper:

- `02F0`: 8bit x 8bit -> 16bit multiply
- `0306`: 8bit / 8bit -> quotient + remainder

この 2 本が並ぶことで、bank0 の `02F0-0320` は
**汎用算術 helper 帯** とみるのがかなり自然になった。

## 5. `043E` への影響

直接 `043E` は `0306` を使っており `02F0` は使わない。
ただし、「multiply ではなく modulo で縮めている」という今回の解釈を、
近傍 helper の役割分担が間接的に補強している。

もし `043E` が unbiased scaling をしたいなら、通常は multiply 系 helper を使う余地がある。
それを使わず `0306` を呼んでいる点は、やはり **modulo reduction** 説と整合しやすい。

## 6. 現時点の整理

### 確度が高いこと

- `02F0` は 8bit multiply helper と読むのが自然
- 戻り値 `HL` は 16bit product 候補
- `02F0` と `0306` は bank0 arithmetic helper 群として並べられる

### まだ未確定なこと

- flags の戻り値利用
- 呼び出し側が `H`/`L` のどちらだけを使うパターン
- `0321` 以降の helper との体系的な関係

## 次の一手

1. `043E` caller 文脈で `D/E` の意味を照合する
2. `RST $10` / `RST $18` / `RST $20` を契約化する
3. 算術 helper 群 `0321/033F/0376...` の役割を必要に応じて追う
