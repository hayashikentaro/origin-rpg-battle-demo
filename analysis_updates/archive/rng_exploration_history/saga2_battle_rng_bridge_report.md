# SaGa2 battle RNG bridge report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_00d2_battle_callers_report.md`
- 既存 `saga2_rng_slot07_08_offset_report.md`

## 目的

- `battle` と `rng` の接続部を `443B-4499` 周辺で整理する
- battle 文脈で `016B -> 043E` に入る契約を一段固める

## 結論

今回の修正で、
`battle` と `rng` の直接接続部として見るべき帯は
**bank `0D:443B-4499`**
だと整理し直した。

ここでは:

1. `BC` 側 work record を guard する
2. `BC+0C/0D` を base pointer `HL` として読む
3. `BC+0A` 由来値から span 上限候補を作る
4. `CALL $016B -> JP $043E` を 2 回呼ぶ
5. slot `07/08` の返り値で 16bit signed offset を作る
6. その offset でずらした pointer を `BC` 側 record 配列へ書き戻す

したがってここは
**battle work record -> RNG range request -> pointer record build**
の橋渡し部とみるのが自然。

## 1. 実コード

```text
443B: LD A,(BC)
443C: OR A
443D: RET Z
443E: PUSH AF
443F: LD C,$0C
4441: LD A,(BC)
4442: LD L,A
4443: INC C
4444: LD A,(BC)
4445: LD H,A
4446: LD D,H
4447: LD E,L
4448: LD C,$0A
444A: LD A,(BC)
444B: INC A
444C: JR NZ,$4451
444E: LD DE,$0000
4451: SRL D
4453: RR E
4455: SRL D
4457: RR E
4459: SRL D
445B: RR E
445D: POP AF
445E: LD C,$40
4460: PUSH AF
4461: PUSH HL
4462: PUSH BC
4463: PUSH DE
4464: LD E,$00
4466: LD A,$07
4468: CALL $016B
446B: LD C,A
446C: POP DE
446D: PUSH DE
446E: LD D,E
446F: LD E,$00
4471: LD A,$08
4473: CALL $016B
4476: LD E,A
4477: LD D,C
4478: LD A,D
4479: CPL
447A: LD D,A
447B: LD A,E
447C: CPL
447D: ADD A,$01
447F: LD E,A
4480: LD A,D
4481: ADC A,$00
4483: LD D,A
4484: ADD HL,DE
4485: POP DE
4486: POP BC
4487: XOR A
4488: LD (BC),A
4489: INC C
448A: LD A,L
448B: LD (BC),A
448C: INC C
448D: LD A,H
448E: LD (BC),A
448F: LD A,C
4490: AND $F8
4492: ADD A,$08
4494: LD C,A
4495: POP HL
4496: POP AF
4497: DEC A
4498: JR NZ,$445E
449A: RET
```

## 2. 前半の意味

前半 `443B-445D` で見えているのは次の構造。

- `A=(BC)` を 0 判定して空 record を弾く
- `BC+0C/0D` から base pointer `HL` を取る
- その pointer を `DE` に写して 3bit 右シフトする
- `BC+0A == $FF` のときだけ上限を `0` に落とす

つまりここは
**work record 内の base pointer と span を取り出す前処理**
として読むのが自然。

## 3. RNG 呼び出し

`445E-4484` の核心は 2 回の `016B`。

1 本目:

```text
4464: LD E,$00
4466: LD A,$07
4468: CALL $016B
```

2 本目:

```text
446E: LD D,E
446F: LD E,$00
4471: LD A,$08
4473: CALL $016B
```

既知契約と合わせると、

- `A` = seed slot
- `E` = lower
- `D` = upper

なので、
ここは slot `07` と slot `08` を使って
**record 由来上限で 2 byte の範囲乱数を取る**
形に見える。

## 4. 16bit signed offset

call 後は:

```text
4476: LD E,A
4477: LD D,C
4478-4483: DE を 2 の補数化
4484: ADD HL,DE
```

なので、

```text
HL = HL - ((slot07_result << 8) | slot08_result)
```

と読むのが自然。

したがって battle 側での RNG の役割は、
ここでは direct damage 値ではなく
**pointer / candidate record の後退選択**
に寄っている。

## 5. 書き戻し先

offset 適用後は:

```text
4487: LD (BC),A   ; 0
448A: LD (BC),L
448D: LD (BC),H
448F-4494: C を 8 byte 境界へ進める
```

このため `BC` 側は
**8 byte stride 風の pointer record 配列**
として読むのが自然。

このブロックは
「乱数で record を選ぶ」だけでなく、
**選ばれた pointer を work record 群へ書き戻す builder**
でもある。

## 6. 重要な修正点

前回までの仮説で混ざっていた 2 点は、今回分離した。

- `slot 05/08` 解釈は誤りで、この帯の直接 caller は `slot 07/08`
- `449A` はこのブロックの `RET` であり、`449A-44F3` は別 helper

したがって
`443B-4499` と `449A-44F3` は同じ helper とみなさないほうが安全。

## 7. Godot/TypeScript への示唆

battle 側 API では少なくとも次が必要。

```ts
rng.next(slot, lower, upper)
```

そしてこの path では:

```ts
const hi = rng.next(0x07, 0x00, upperHi)
const lo = rng.next(0x08, 0x00, upperLo)
const offset = toSigned16(hi, lo)
const source = basePointer + offset
writePointerRecord(source)
```

という構造を持つ可能性が高い。

## 現時点の整理

### 確度が高いこと

- `443B-4499` は battle と rng の具体的接続部
- slot `07/08` を 2 回使って 16bit signed offset を作る
- `BC+0C/0D` は base pointer 候補
- `BC+0A` は span 上限候補
- 結果は `BC` 側の 8 byte stride 風 record 配列へ書き戻される

### まだ未確定なこと

- `BC` の実 page と record struct の正式レイアウト
- base pointer が何の table/record を指すか
- loop count の意味
- この path の caller が action/target/variant のどれを解決しているか

## 次の一手

1. `443B` 入口時点の `BC` ベース page を caller 側から固定する
2. `43FB-443A` を別 helper として切り出して `0C:6F82` table の意味を確認する
3. `449A-44F3` の caller を追って、record expansion helper として独立整理する
