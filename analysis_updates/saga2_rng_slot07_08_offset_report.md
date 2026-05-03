# SaGa2 RNG slot07_08 offset report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_rng_slot_classification_report.md`

## 目的

- bank `0D:4440` 周辺で使われる slot `07/08` の後段計算を確定に寄せる
- battle/item 系 caller が何を乱数化しているかを整理する

## 結論

bank `0D:4440` の slot `07` / `08` は、
単純な「1 個の値の範囲乱数」ではなく、
**上位 byte / 下位 byte を別々に引いて 16bit offset を組み立てる pair RNG**
とみるのが自然。

しかも call 後は

- `DE = random_hi:random_lo`
- `DE = -DE`
- `HL += DE`

の形になっているため、実質的には
**base `HL` からランダム 16bit offset を後退させた位置** を作っている。

したがって slot `07/08` は、
hit / damage 本体より
**battle/item 系の pointer / candidate position / scatter offset 生成**
として扱うほうが安全。

## 1. 実コード

`0D:4440` 以降の実バイト:

```text
4440: 0A          LD A,(BC)
4441: 6F          LD L,A
4442: 0C          INC C
4443: 0A          LD A,(BC)
4444: 67          LD H,A
4445: 54          LD D,H
4446: 5D          LD E,L
4447: 0E 0A       LD C,$0A
4449: 0A          LD A,(BC)
444A: 3C          INC A
444B: 20 03       JR NZ,$4450
444D: 11 00 00    LD DE,$0000
4450: CB 3A       SRL D
4452: CB 1B       RR E
4454: CB 3A       SRL D
4456: CB 1B       RR E
4458: CB 3A       SRL D
445A: CB 1B       RR E
445C: F1          POP AF
445D: 0E 40       LD C,$40
445F: F5          PUSH AF
4460: E5          PUSH HL
4461: C5          PUSH BC
4462: D5          PUSH DE
4463: 1E 00       LD E,$00
4465: 3E 07       LD A,$07
4467: CD 6B 01    CALL $016B
446A: 4F          LD C,A
446B: D1          POP DE
446C: D5          PUSH DE
446D: 53          LD D,E
446E: 1E 00       LD E,$00
4470: 3E 08       LD A,$08
4472: CD 6B 01    CALL $016B
4475: 5F          LD E,A
4476: 51          LD D,C
4477: 7A          LD A,D
4478: 2F          CPL
4479: 57          LD D,A
447A: 7B          LD A,E
447B: 2F          CPL
447C: C6 01       ADD A,$01
447E: 5F          LD E,A
447F: 7A          LD A,D
4480: CE 00       ADC A,$00
4482: 57          LD D,A
4483: 19          ADD HL,DE
4484: D1          POP DE
4485: C1          POP BC
4486: AF          XOR A
4487: 02          LD (BC),A
4488: 0C          INC C
4489: 7D          LD A,L
448A: 02          LD (BC),A
448B: 0C          INC C
448C: 7C          LD A,H
448D: 02          LD (BC),A
448E: 79          LD A,C
448F: E6 F8       AND $F8
4491: C6 08       ADD A,$08
4493: 4F          LD C,A
4494: E1          POP HL
4495: F1          POP AF
4496: 3D          DEC A
4497: 20 C6       JR NZ,$445F
4499: C9          RET
```

## 2. 上限値の作り方

前半:

```text
4445: LD D,H
4446: LD E,L
...
4450-445A: SRL D / RR E を 3 回
```

なので、まず `HL` を `DE` に写してから
**16bit 値として 3bit 右シフト** している。

つまり `DE = HL >> 3`。

直前の

```text
4447: LD C,$0A
4449: LD A,(BC)
444A: INC A
444B: JR NZ,$4450
444D: LD DE,$0000
```

は guard 条件で、特定条件では上限そのものを 0 に落としている。

## 3. slot `07`

1 本目:

```text
4462: PUSH DE
4463: LD E,$00
4465: LD A,$07
4467: CALL $016B
446A: LD C,A
```

既知契約では `D=upper`, `E=lower` なので、
この call は

- slot = `07`
- lower = `00`
- upper = shifted `DE` の high byte

として呼ばれる。

返値は `C` に保存される。

## 4. slot `08`

2 本目:

```text
446B: POP DE
446C: PUSH DE
446D: LD D,E
446E: LD E,$00
4470: LD A,$08
4472: CALL $016B
4475: LD E,A
4476: LD D,C
```

ここでは一度元の shifted `DE` を戻し、
`D = old E` に入れ替えてから slot `08` を呼んでいる。

したがってこの call は

- slot = `08`
- lower = `00`
- upper = shifted `DE` の low byte

を意味する。

call 後は

- `D = slot07_result`
- `E = slot08_result`

となる。

## 5. 2 本を 16bit offset に合成している

後半:

```text
4477: LD A,D
4478: CPL
4479: LD D,A
447A: LD A,E
447B: CPL
447C: ADD A,$01
447E: LD E,A
447F: LD A,D
4480: ADC A,$00
4482: LD D,A
4483: ADD HL,DE
```

これは `DE` の 2 の補数化なので、

```text
DE = -DE
HL = HL + DE
```

すなわち

```text
HL = HL - ((slot07 << 8) | slot08)
```

と読める。

したがって slot `07/08` は
**16bit backward offset を作る pair RNG**
である可能性が高い。

## 6. 書き戻し先の形

```text
4486: XOR A
4487: LD (BC),A
4488: INC C
4489: LD A,L
448A: LD (BC),A
448B: INC C
448C: LD A,H
448D: LD (BC),A
...
448F: AND $F8
4491: ADD A,$08
```

ここでは

- `00`
- `HL low`
- `HL high`

を書いたあと、
`C` を 8 byte 境界へ進めて次 record に回している。

よってこのルーチンは
**8 byte stride の record 群へ、ランダム offset 付き pointer/position を並べる処理**
とみるのが自然。

## 7. RNG への影響

この整理により、slot `07/08` は

- battle 側で使われる
- しかし単純な命中や最終ダメージ乱数とは限らない
- 16bit pointer / position offset の生成に近い

と考えるのが安全になった。

少なくとも現時点では、
slot `07/08` を damage core RNG と即断する根拠は弱い。

## 8. 現時点の整理

### 確度が高いこと

- `0D:4440` は slot `07` と `08` を pair で使う
- `07` は high-byte side、`08` は low-byte side の range RNG
- 2 本の返値は 16bit 値に再合成される
- 合成後は 2 の補数化され、`HL` から差し引かれる
- 結果は 8 byte stride record 群へ書き戻される

### まだ未確定なこと

- `HL` の base が何のテーブル / 座標系を指すか
- 書き戻し先 record が item candidate か particle seed か別の battle buffer か
- この cluster が battle logic / item use / effect init のどこに属するか

## 次の一手

1. `4440` caller 側を追って `HL` と `BC` の実体を確定する
2. 8 byte stride record の後続 consumer を探す
3. damage / hit 本体で別 slot が使われていないかを継続調査する
