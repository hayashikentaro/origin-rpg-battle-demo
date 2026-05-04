# SaGa2 `C2A2` budget report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c760_consumer_report.md`

## 目的

- `C2A2` の consumer を追う
- `C2A2` が単なる accumulator か、その後 budget/pool として使われるかを切る

## 結論

`C2A2` は `6632` で `C760` を加算されるだけでなく、
後段で **candidate value と比較・減算される 3byte budget/pool**
として使われている可能性が高い。

今回確度高く言えるのは次の 5 点。

1. `0162 -> 0390` は `[DE] += [HL]` の 3byte add helper 候補  
2. `0165 -> 03A6` は `[DE] -= [HL]` の 3byte subtract helper 候補  
3. `0168 -> 03BC` は `[DE]` と `[HL]` の 3byte compare helper 候補  
4. `6632` では `DE=$C2A2, HL=$C760` で add が呼ばれ、`C2A2 += candidateValue` が起きている  
5. `62D1` と `6554` では `DE=$C2A2` に対して compare/subtract が使われており、`C2A2` は後段で spendable pool として消費されている

したがって `C2A2` は、
「候補値を一時的に集計する accumulator」でもあり、
その次段では「消費可能な残量/budget」として振る舞う
二段階の 3byte workspace とみるのが最も整合する。

## 1. arithmetic helper 群

### `0162 -> 0390`

既報どおり:

```text
0394: LD A,(DE)
0395: ADD (HL)
...
039A: ADC (HL)
...
039F: ADC (HL)
```

なので 3byte add helper 候補。

### `0165 -> 03A6`

実体:

```text
03A6: LDH ($FF90),A
03A8: PUSH BC
03A9: PUSH DE
03AA: PUSH HL
03AB: LD A,(DE)
03AC: SUB (HL)
03AD: LD (DE),A
03AE: LD C,A
03AF: INC DE
03B0: INC HL
03B1: LD A,(DE)
03B2: SBC (HL)
03B3: LD (DE),A
03B4: LD B,A
03B5: INC DE
03B6: INC HL
03B7: LD A,(DE)
03B8: SBC (HL)
03B9: LD (DE),A
03BA: JR $03CD
```

これはかなり素直に:

```ts
sub24InPlace(dst: ptr3, src: ptr3): void
```

と読める。

### `0168 -> 03BC`

実体:

```text
03BC: LDH ($FF90),A
03BE: PUSH BC
03BF: PUSH DE
03C0: PUSH HL
03C1: LD A,(DE)
03C2: SUB (HL)
03C3: LD C,A
03C4: INC DE
03C5: INC HL
03C6: LD A,(DE)
03C7: SBC (HL)
03C8: LD B,A
03C9: INC DE
03CA: INC HL
03CB: LD A,(DE)
03CC: SBC (HL)
03CD: JR C,$03D3
03CF: OR C
03D0: OR B
03D1: JR $03D6
03D3: OR C
03D4: OR B
03D5: SCF
03D6: POP HL
03D7: POP DE
03D8: POP BC
03D9: LDH A,($FF90)
03DB: RET
```

carry を underflow/`dst < src` に使う 3byte compare helper とみるのが自然。

## 2. `6632` の add path

既報:

```text
6632: LD DE,$C2A2
6635: LD HL,$C760
6638: CALL $0162
```

なので current candidate value を `C2A2` に積む。

## 3. `62D1` の compare/subtract path

```text
62D1: LD DE,$C2A2
62D4: LD HL,$C745
62D7: CALL $0168
62DA: JR C,$62F6
62DC: CALL $0165
```

ここでは `C2A2` を `C745` 側 3byte 値と比較し、
足りなければ carry で skip、
足りればその値を差し引いている。

つまり `C2A2` はこの時点で **remaining pool** として使われている。

## 4. `6554` の compare/subtract path

`6548-655C`:

```text
6548: LD A,C
6549: LD DE,$C70A
654C: PUSH DE
654D: CALL $6669
6550: POP HL
6551: LD DE,$C2A2
6554: CALL $0168
6557: JR C,$6589
6559: CALL $0165
```

ここでは `6669` で `sourceIndex` 由来の 3byte value を `C70A` へ出し、
その値と `C2A2` を compare/subtract している。

よって `C2A2` の spend 先は少なくとも 2 系統ある。

## 5. 意味論の整理

この 3 本を並べると、
`C2A2` の lifecycle は

```ts
budget += adoptedCandidateValue
...
if (budget >= thresholdOrCost) {
  budget -= thresholdOrCost
  // candidate/selector path continues
}
```

にかなり近い。

つまりドメイン名としては

- `accumulatedValue`
- `budget`
- `remainingPool`

のどれか 1 つに固定するより、
**phase に応じて accumulation と spending の両方を持つ 3byte pool**
と見るのが安全。

## 6. bank0 `132C` の read path

bank0 にも:

```text
132C: LD HL,$C2A2
132F: RST $30
1330: AND A
1331: JR Z,$133B
...
```

という direct pointer path がある。

ここではまだ `RST $30` の厳密契約を切っていないが、
`C2A2` が bank1 selector-runtime 内だけで閉じず、
bank0 側の generic 3byte/formatting/helper 層へも渡されていることが分かる。

## 7. 移植上の意味

TypeScript 側では `C2A2` を固定名 1 個に決め打ちするより、
少なくとも内部表現では

```ts
type ValuePool24 = number
```

として持ち、

```ts
addToPool(value)
canAfford(cost)
spend(cost)
```

のような API で扱うほうが安全。

## 8. まだ未確定な点

- `C745` の 3byte 値が threshold か cost か
- `C70A` scratch を通る path の具体的ドメイン
- bank0 `132C` が formatting / conversion / branch のどれか
- `C2A2` の正式ラベル

## 次の一手

1. `C745` と `C70A` の producer を追って threshold/cost の意味を切る
2. bank0 `132C` の `RST $30` 契約を切る
3. `62D1` と `6554` の caller cluster を分けて subsystem ごとに予算の使い方を整理する
