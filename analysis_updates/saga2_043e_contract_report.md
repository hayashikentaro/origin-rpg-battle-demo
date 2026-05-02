# SaGa2 `00:043E` contract report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 RNG reports

## 目的

- `00:043E` の入出力レジスタ契約を局所解析する
- `RST $00` / `RST $28` を含めて `0440` 本体の意味を上げる

## 結論

`00:043E` は **seed slot を 1 つ進めて `data_rng` から 1 byte を取り、必要なら `[E, D]` の範囲へ縮小して `A` で返す helper** とみるのが自然。

特に確度が上がった点は次の 3 つ:

- `A` は `random_seeds[$C0A0]` の slot index
- `RST $28 -> $04B1` は bank switch helper で、前 bank を `A` に返す
- `D/E` は上限/下限を表す inclusive range 候補
- callsite では `DE=$FF00/$0300/$0F00` が現れ、`E=lower`, `D=upper` の読みを強く支持する

## 1. helper の確定

### `RST $00`

vector `0000`:

```text
0000: PUSH BC
0001: LD B,$00
0003: LD C,A
0004: ADD HL,BC
0005: POP BC
0006: RET
```

したがって `RST $00` は

```ts
HL += A;
```

の小 helper。

### `RST $28` / `00:04B1`

vector `0028`:

```text
0028: DI
0029: CALL $04B1
002C: RETI
```

`04B1`:

```text
04B1: PUSH BC
04B2: LD C,A
04B3: LDH A,($FF88)
04B5: LD B,A
04B6: LD A,C
04B7: LDH ($FF88),A
04B9: LD ($2100),A
04BC: LD A,B
04BD: POP BC
04BE: RET
```

これは

```ts
function swapRomBank(newBank: number): number {
  const oldBank = FF88;
  FF88 = newBank;
  ROM_BANK_REG_2100 = newBank;
  return oldBank;
}
```

と読める。

## 2. `00:043E` 実コード

```text
043E: PUSH DE
043F: PUSH HL
0440: LD HL,$C0A0
0443: RST $00
0444: INC (HL)
0445: LD L,(HL)
0446: LD H,$40
0448: LD A,$0F
044A: RST $28
044B: LD H,(HL)
044C: RST $28
044D: LD A,E
044E: CP $FF
0450: JR Z,$0466
0452: LD A,D
0453: AND A
0454: JR Z,$0466
0456: CP E
0457: JR Z,$0466
0459: SUB E
045A: LD L,A
045B: CP $FF
045D: LD A,H
045E: JR Z,$0465
0460: INC L
0461: CALL $0306
0464: LD A,L
0465: ADD A,E
0466: POP HL
0467: POP DE
0468: RET
```

## 3. 前半の意味

前半はほぼ確定で:

```ts
push(DE, HL);

HL = 0xC0A0;          // random_seeds base
HL += A;              // seed slot index
(*HL)++;              // advance slot
L = *HL;              // use incremented byte as table index
H = 0x40;

const oldBank = swapRomBank(0x0f);
H = ROM[0x0f:0x4000 + L];   // data_rng[L]
swapRomBank(oldBank);
```

ここで `H` に入る値が、生の乱数 byte 候補。

## 4. 後半の意味

後半は `D/E` を見て返り値を調整している。

### 退化ケース

- `E == 0xFF` -> 即 return
- `D == 0x00` -> 即 return
- `D == E` -> 即 return

このとき `A` はそれぞれ

- `0xFF`
- `0x00`
- `D(=E)`

なので、**定数範囲の最適化** と読むのが自然。

### 一般ケース

```text
A = D - E
L = A
if (A == 0xFF) {
  A = H
  return A + E
}

L = (D - E) + 1
CALL 0306
A = L
return A + E
```

もっとも自然な読みは:

- `E` = lower bound
- `D` = upper bound
- `0306(H, L)` = `H / L` の remainder を `L` に返す div/mod helper

つまり戻り値は **inclusive range `[E, D]`** の乱数。

## 5. `0306` の役割

`0306` は 8 回ループの restoring division 風 helper で、`H/L` を使って結果を返している。
現時点では

- 入力 `H = raw rng byte`
- 入力 `L = range_size`
- 出力 `L = remainder`

という **div/mod helper** とみるのが最も整合的。

## 6. 擬似コード

```ts
function rngRange(slot: number, upper: number, lower: number): number {
  let idx = random_seeds[slot];
  idx = (idx + 1) & 0xff;
  random_seeds[slot] = idx;

  const raw = data_rng[idx];

  if (lower === 0xff) return 0xff;
  if (upper === 0x00) return 0x00;
  if (upper === lower) return lower;

  const delta = (upper - lower) & 0xff;
  if (delta === 0xff) {
    return (raw + lower) & 0xff;
  }

  const span = delta + 1;
  const scaled = raw % span; // likely via 0306 remainder
  return (scaled + lower) & 0xff;
}
```

## 7. 現時点の整理

### 確度が高いこと

- `A` は seed slot index
- `H` に `data_rng` 由来の raw byte が入る
- `D/E` は範囲指定レジスタ候補
- `043E` は dispatch table 公開 helper 入口として自然

### まだ未確定なこと

- slot 番号ごとの用途差
- `0306` の quotient 側の利用有無
- 戻り値 `A` 以外に `H/L/flags` を呼び出し側が使うか

## 次の一手

1. `02F0` を独立 helper として式化する
2. `043E` を使う dispatch caller 文脈を拾って `D/E` の意味を照合する
3. `RST $10` / `RST $18` / `RST $20` も同様に契約化する
