# SaGa2 `00:0306` div/mod helper report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_043e_contract_report.md`

## 目的

- `00:0306` の算術意味を式化する
- `043E` の range reduction 部分を確定に寄せる

## 結論

`00:0306` は **8bit unsigned div/mod helper** とみるのが最も自然。

入力:

- `H` = dividend
- `L` = divisor

出力:

- `H` = quotient
- `L` = remainder

したがって `043E` の一般ケースは、`data_rng` 生値を span で **modulo reduction** している可能性が高い。

## 1. 実コード

```text
0306: PUSH AF
0307: PUSH BC
0308: LD A,L
0309: CPL
030A: LD C,A
030B: INC C
030C: XOR A
030D: LD B,$08
030F: SLA H
0311: RLA
0312: ADD A,C
0313: JR C,$0317
0315: ADD A,L
0316: INC H
0317: DEC B
0318: JR NZ,$030F
031A: LD L,A
031B: LD A,H
031C: CPL
031D: LD H,A
031E: POP BC
031F: POP AF
0320: RET
```

`C = (~L) + 1 = -L mod 256` なので、`ADD A,C` は実質 `A -= L`。

## 2. 典型的な restoring division との対応

ループ部分は、8bit restoring division の定型にかなり近い。

概念的には:

```ts
let rem = 0;
let q = H;

for (let i = 0; i < 8; i++) {
  [rem, q] = shiftLeftPair(rem, q);
  rem -= L;
  if (rem < 0) {
    rem += L;
    q = q + 1; // complemented quotient build
  }
}

H = ~q;
L = rem;
```

ここで loop 中の `INC H` と最後の `CPL` は、
**反転した quotient を組み立てて最後に戻す** 実装だと読むと整合する。

## 3. なぜ remainder と読めるか

終了時:

```text
031A: LD L,A
031B: LD A,H
031C: CPL
031D: LD H,A
```

つまり最終 `A` が `L` に保存される。
loop 中の `A` は部分 remainder として振る舞っているので、
終了後 `L = remainder` とみるのが自然。

一方 `H` は補数を取って返しているため、quotient 側と読むのが最も整合する。

## 4. `043E` への影響

`043E` の一般ケース:

```text
delta = D - E
span  = delta + 1
H = raw_rng
L = span
CALL 0306
A = L
A += E
```

したがって返り値は

```ts
return (raw_rng % span) + lower;
```

の形にかなり近い。

## 5. bias について

もしこれが本当に modulo reduction なら、`span` が 256 の約数でない場合は
分布がわずかに偏る。

つまり `043E` は

- 高品質な unbiased scaling

ではなく、

- ROM 実装としては十分な `raw % span`

を使っている可能性が高い。

## 6. `02F0` との対比

近傍の `02F0` は別の 8bit arithmetic helper で、shift/add 構造が似ている。
この一帯は

- multiply
- divide/mod

のような算術 helper 群である可能性が高い。

## 7. 擬似コード

```ts
function divmod8(dividend: number, divisor: number): { q: number; r: number } {
  let rem = 0;
  let q = dividend;

  for (let i = 0; i < 8; i++) {
    const carry = (q & 0x80) >>> 7;
    q = (q << 1) & 0xff;
    rem = ((rem << 1) & 0xff) | carry;

    const trial = rem - divisor;
    if (trial >= 0) {
      rem = trial;
    } else {
      q = (q + 1) & 0xff;
    }
  }

  q = (~q) & 0xff;
  return { q, r: rem };
}
```

`043E` 文脈では `r` だけを使う。

## 8. 現時点の整理

### 確度が高いこと

- `0306` は scale helper より div/mod helper と読むほうが自然
- `L` は remainder を返している可能性が高い
- `043E` の一般ケースは `raw % span + lower` に近い

### まだ未確定なこと

- divisor `L=0` の呼び出しが本当に避けられているか
- `H` quotient を呼び出し側が別用途で使う箇所があるか
- `02F0` の厳密な役割

## 次の一手

1. `02F0` も contract 化して算術 helper 群を並べる
2. `043E` caller 文脈で `D/E` の意味を照合する
3. `RST $10` / `RST $18` / `RST $20` を同様に確定する
