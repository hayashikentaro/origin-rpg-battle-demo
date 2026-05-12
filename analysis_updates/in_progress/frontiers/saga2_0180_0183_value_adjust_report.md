# SaGa2 `0180/0183` value adjust report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c2b9_entry_decode_report.md`
- 既存 `saga2_7860_descriptor_report.md`

## 目的

- `65F8-6618` の差異補正部を切る
- `0180` / `0183` が `C760` に対して何をしているかを整理する
- `C2B9.byte1` の意味を一段具体化する

## 結論

`65F8-6618` の補正部は、単なる class 一致判定ではなく、
**`C760` の 3byte value scratch を `0C:7E80 + sourceIndex` の canonical byte と `C73C` の entry byte で再スケールする段**
とみるのが最も自然。

現時点で確度高く言えるのは次の 4 点。

1. `0183` は `JP $040B` で、**3byte value / 8bit divisor** の restoring-division helper 候補
2. `0180` は `JP $03DC` で、**3byte value と 8bit factor の 24-step shift/add 乗算 helper** 候補
3. mismatch 時の call sequence は  
   `divideBy(canonicalByte) -> multiplyBy(entryByte) -> divideBy(2)`  
   と読むのが最も整合する
4. したがって `C2B9.byte1` は単なる表示 aux ではなく、**倍率/階級/価格種別のような rescale byte** 候補へ上がった

ただし `03DC` の low-value 側アラインメントはなお少し不安定で、
厳密には「3byte 値の拡張付き乗算 helper」として持っておくのが安全。

## 1. call site

差異補正本体:

```text
65E9: LD A,($C73B)
65EC: LD HL,$7E80
65EF: RST $00
65F0: LD A,$0C
65F2: CALL $00D2
65F5: LDH ($FF92),A
65F7: LD B,A
65F8: LD A,($C73C)
65FB: CP B
65FC: JR Z,$6609
65FE: LDH A,($FF92)
6600: CALL $0183
6603: LD A,($C73C)
6606: CALL $0180
6609: LD A,$02
660B: CALL $0183
660E: LD L,E
660F: LD H,D
6610: PUSH HL
6611: LD A,(HL+)
6612: OR (HL)
6613: INC HL
6614: OR (HL)
6615: POP HL
6616: JR NZ,$661A
6618: LD (HL),$01
```

ここでは:

- `C73B = sourceIndex`
- `B = bank0C:7E80[sourceIndex]`
- `C73C = entry byte1`
- `DE = C760`

の状態から、
`entry byte1 != canonical byte` のときだけ補正に入る。

## 2. wrapper 対応

bank0 dispatch wrappers:

```text
0180: JP $03DC
0183: JP $040B
```

したがって実体は:

- `0180 -> 03DC`
- `0183 -> 040B`

である。

## 3. `040B` は 24bit / 8bit division helper 候補

実コード:

```text
040B: PUSH BC
040C: PUSH DE
040D: PUSH HL
040E: LD C,A
040F: CPL
0410: LD B,A
0411: INC B
0412: PUSH HL
0413: LD E,(HL)
0414: INC HL
0415: LD D,(HL)
0416: INC HL
0417: LD A,(HL)
0418: LD H,C
0419: LD C,A
041A: XOR A
041B: LD L,$18
041D: SLA E
041F: RL D
0421: RL C
0423: RLA
0424: ADD A,B
0425: JR C,$0429
0427: ADD A,H
0428: INC C
0429: DEC L
042A: JR NZ,$041D
042C: POP HL
042D: LD B,A
042E: LD A,E
042F: CPL
0430: LDI (HL),A
0431: LD A,D
0432: CPL
0433: LDI (HL),A
0434: LD A,C
0435: CPL
0436: LD (HL),A
0437: LD A,B
0438: POP HL
0439: POP DE
043A: POP BC
043B: RET
```

`B = -divisor mod 256` を作り、
`SLA/RL/RLA` で 24bit dividend を左シフトしながら
`ADD A,B` で試し引きしているので、
構造は `0306` と同系の restoring division にかなり近い。

最も自然な契約は:

```ts
// DE points to 3-byte little-endian scratch
divide24By8InPlace(divisor: number, ptr: number): number
```

で、

- memory `[ptr+0..2]` = quotient を書き戻す
- `A` = remainder を返す

と読むのが整合する。

## 4. `03DC` は 24-step shift/add multiply helper 候補

実コード:

```text
03DC: PUSH AF
03DD: PUSH BC
03DE: PUSH DE
03DF: PUSH HL
03E0: PUSH DE
03E1: LD L,E
03E2: LD H,D
03E3: LD E,(HL)
03E4: INC HL
03E5: LD D,(HL)
03E6: INC HL
03E7: LD L,(HL)
03E8: LD H,A
03E9: LD B,$18
03EB: XOR A
03EC: RR L
03EE: RR D
03F0: RR E
03F2: JR NC,$03F5
03F4: ADD A,H
03F5: RRA
03F6: DEC B
03F7: JR NZ,$03EC
03F9: RR L
03FB: RR D
03FD: RR E
03FF: LD C,L
0400: POP HL
0401: LD (HL),E
0402: INC HL
0403: LD (HL),D
0404: INC HL
0405: LD (HL),C
0406: INC HL
0407: LD (HL),A
0408: JP $000B
```

これは:

- `DE` が指す 3byte scratch を読む
- `A` を factor として使う
- 24 回の `RR` と条件付き `ADD A,H` で product を育てる
- 4 byte を scratch へ書き戻す

という形になっている。

最も安全な整理は:

```ts
// DE points to 3-byte scratch, result widens to 4 bytes
mul24By8WidenInPlace(factor: number, ptr: number): void
```

である。

low-value の厳密な bit alignment はもう一段確認したいが、
少なくとも **division helper ではなく multiply-side helper** と読むのが自然。

## 5. mismatch 補正式の読み筋

以上をそのまま call site に当てると、
`C73C != canonicalByte` のときは

```ts
value = divide24By8InPlace(canonicalByte, C760)
value = mul24By8WidenInPlace(entryByte, C760)
value = divide24By8InPlace(2, C760)
if (low24(value) == 0) low24(value) = 1
```

という順になる。

意味論としては、

```ts
adjusted ~= floor((baseValue / canonicalByte) * entryByte / 2)
```

にかなり近い。

このため `C73C` は単なる補助表示 byte ではなく、
`7860` value に作用する **rank/class multiplier**
として読むほうが整合する。

## 6. `C760` scratch の扱い

`6669` は `0F:7860 + sourceIndex*3` から
`xx yy 00` 形式の 3byte value を `C760` へ入れていた。

今回の補正部を見ると、この `C760` は
opaque descriptor ではなく

- canonical lookup で割る
- entry byte で掛ける
- `2` で割る
- 0 なら 1 へ clamp する

という **数量/価格/容量系 scratch** として使われている可能性が高い。

## 7. `C2B9.byte1` の再整理

従来は `byte1 = aux/class byte` とだけ置いていたが、
今回の補正経路まで含めると

```ts
type C2b9Entry = {
  sourceIndex: number
  scaleClassByte: number
}
```

くらいまで寄せてよい。

もちろん「価格クラス」「使用回数クラス」「階級」など
具体名はまだ保留したほうが安全だが、
少なくとも **value16 を rescale する byte** という点はかなり強い。

## 8. 移植上の意味

TypeScript 側では selector-runtime と presentation を分けつつ、
`C2B9` decode bridge に次の責務を持たせると安全。

```ts
resolveSourceIndex(entry): number | null
lookupBaseValue24(index): number
lookupCanonicalScaleByte(index): number
rescaleValue24(baseValue24, canonicalByte, entryByte): number
```

特に `entryByte != canonicalByte` のときの rescale が
selector/lookup 層で完結するなら、
battle / rng 本線にこの補正ロジックを持ち込まずに済む。

## 9. まだ未確定な点

- `03DC` の widened 4th byte を後段がどこまで使うか
- `7860` が価格 table か、より広い quantity table か
- `canonicalByte` / `entryByte` のドメイン名
- `03DC` の low-value 側 bit alignment の厳密式

## 次の一手

1. `661A` 以降の consumer を追って `C760` の最終用途を確定する
2. `0C:7E80` 側 table を dump して canonical scale byte の分布を見る
3. `7860` caller をさらに拾って quantity/value table の用途範囲を切る
