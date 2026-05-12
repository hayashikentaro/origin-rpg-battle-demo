# SaGa2 `C760` consumer report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_0180_0183_value_adjust_report.md`
- 既存 `saga2_c2b9_workspace_subsystems_report.md`

## 目的

- `661A` 以降の flow を切る
- `C760` の immediate consumer を確定する
- `C2B9` entry が採用後にどう処理されるかを整理する

## 結論

`C760` の immediate consumer は、いまのところ
**`6632: DE=$C2A2, HL=$C760, CALL $0162` による 3byte 累積加算**
だとかなり強く言える。

今回確度高く言えるのは次の 4 点。

1. `6610-6618` は補正後 `C760` の low 3byte が 0 なら `01` へ clamp する guard  
2. `6632: CALL $0162` は `0162 -> 0390` で、**`[DE] += [HL]` の 3byte add helper** 候補  
3. `DE=$C2A2`, `HL=$C760` なので、`C760` は採用時に **`C2A2` 累積値へ加算** されている  
4. その後 `663B-6647` で current `C2B9[index]` を `FF,FF` tombstone 化しており、採用済み candidate を workspace から消している

したがって `C760` は presentation 用の一時表示値ではなく、
**selector-runtime 内で選ばれた candidate の数量/value を `C2A2` accumulator へ足し込む scratch**
とみるのが最も整合する。

## 1. `6610-6647` の流れ

実バイト:

```text
6610: PUSH HL
6611: LD A,(HL+)
6612: OR (HL)
6613: INC HL
6614: OR (HL)
6615: POP HL
6616: JR NZ,$661A
6618: LD (HL),$01
661A: CALL $5E35
661D: LD E,$28
661F: RST $08
6620: XOR A
6621: CALL $01B9
6624: LDH A,($FF8C)
6626: CP $FF
6628: JP Z,$65A3
662B: CALL $5F07
662E: AND A
662F: JP NZ,$65A3
6632: LD DE,$C2A2
6635: LD HL,$C760
6638: CALL $0162
663B: LD A,($C70D)
663E: ADD A,A
663F: LD HL,$C2B9
6642: RST $00
6643: LD A,$FF
6645: LDI (HL),A
6646: LD (HL),A
6647: JP $65A3
```

ここから分かるのは:

- `6610-6618` は `C760` 全体が 0 かを確認する guard
- 0 なら byte0 を `01` へして最低値を保証
- その後 UI/selector 周りの helper を通したのち
- `C760` を `C2A2` へ加算
- current entry を tombstone 化

という流れである。

## 2. `0162 -> 0390` は 3byte add helper 候補

`0162` は jump entry:

```text
0162: JP $0390
```

実体 `0390`:

```text
0390: LDH ($FF90),A
0392: PUSH DE
0393: PUSH HL
0394: LD A,(DE)
0395: ADD (HL)
0396: LD (DE),A
0397: INC DE
0398: INC HL
0399: LD A,(DE)
039A: ADC (HL)
039B: LD (DE),A
039C: INC DE
039D: INC HL
039E: LD A,(DE)
039F: ADC (HL)
03A0: LD (DE),A
03A1: POP HL
03A2: POP DE
03A3: LDH A,($FF90)
03A5: RET
```

これはかなり素直に:

```ts
add24InPlace(dst: ptr3, src: ptr3): void
```

と読める。

つまり `6632-6638` は

```ts
C2A2 += C760
```

である可能性が高い。

## 3. `C760` の immediate consumer

これで `65C9-6647` の decode/adopt flow は:

```ts
entry = C2B9[index]
sourceIndex = entry.byte0
entryByte   = entry.byte1

value = lookup7860(sourceIndex)
canonical = table7E80[sourceIndex]

if (entryByte != canonical) {
  value = floor(value / canonical)
  value = value * entryByte
  value = floor(value / 2)
}

if (value == 0) value = 1

C2A2 += value
C2B9[index] = 0xFFFF
```

にかなり近くなる。

したがって `C760` は「最後に文字列化される値」ではなく、
**採用された candidate の value scratch**
とみるのが自然。

## 4. `661A-662F` の位置づけ

`661A: CALL $5E35`、`661D: LD E,$28 ; RST $08`、
`6621: CALL $01B9`、`662B: CALL $5F07`
はこの流れの中間にある。

ここで確定できるのは、
これらが **`C760` の加算前に通る gate / UI / selector-state refresh** だという点まで。

特に:

- `6624: LDH A,($FF8C) ; CP $FF ; JP Z,$65A3`
- `662B: CALL $5F07 ; AND A ; JP NZ,$65A3`

があるので、
加算は無条件ではなく condition を通過した場合だけ行われる。

ただし現時点では、`5E35` / `01B9` / `5F07` の厳密なドメイン名よりも、
**adopt gate を通った candidate の value が `C2A2` へ積まれる**
という点のほうが重要である。

## 5. `C2B9` workspace との関係

`663B-6647` は:

```text
663B: LD A,($C70D)
663E: ADD A,A
663F: LD HL,$C2B9
6642: RST $00
6643: LD A,$FF
6645: LDI (HL),A
6646: LD (HL),A
```

なので、current index `C70D` の entry を `FF,FF` にしている。

これは既報の
`C2B9` = 16件 * 2byte mutable workspace
という整理ときれいに合う。

つまり current entry は、

- decode
- rescale
- clamp
- adopt
- accumulate
- tombstone

という 1 サイクルで消費される candidate とみてよい。

## 6. `6657-6668` の意味

近傍 helper:

```text
6657: LD B,$10
6659: LD HL,$C2B9
665C: LD A,(HL)
665D: INC A
665E: JR Z,$6667
6660: INC HL
6661: INC HL
6662: DEC B
6663: JR NZ,$665C
6665: SCF
6666: RET
6667: AND A
6668: RET
```

これは既報どおり、
**`C2B9` に active entry が残っているかを見る scan helper**
と読むのが自然。

`661A-6647` の tombstone 化と合わせると、
workspace を 1 件ずつ消費していく selector-runtime の姿がかなりはっきりする。

## 7. 移植上の意味

TypeScript 側では、`C2B9` decode を battle/rng から切り離して
次のような selector-runtime として持つのが自然。

```ts
type CandidateEntry = {
  sourceIndex: number | null
  scaleByte: number
}

type CandidateRuntime = {
  entries: CandidateEntry[]
  accumulatedValue: number
}
```

そして 1 step は:

```ts
value = decodeAndRescale(entry)
value = max(value, 1)
runtime.accumulatedValue += value
entry = null
```

の形で再現しやすい。

## 8. まだ未確定な点

- `C2A2` の正式ラベルとドメイン名
- `5E35` / `01B9` / `5F07` の厳密な意味
- `C760` widened 4th byte をこの subsystem が使うか
- この accumulated value が最終的に何の UI/logic に使われるか

## 次の一手

1. `C2A2` の consumer を追って accumulated value の意味を確定する
2. `5E35` / `01B9` / `5F07` を切って adopt gate の意味を整理する
3. `0C:7E80` table を dump して `scaleByte` の分布を見る
