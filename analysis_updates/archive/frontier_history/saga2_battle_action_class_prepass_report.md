# SaGa2 battle action class prepass report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_battle_descriptor_cluster_correction_report.md`
- 既存 `saga2_battle_rng_prepass_report.md`

## 目的

- `0D:43FB-443A` を実バイトベースで擬似コード化する
- `4417+` の action class / RNG 本線と、その直前 prepass を切り分ける

## 結論

`0D:43FB-443A` は
`4417+` の action class 判定そのものではなく、
**9 個の 2byte entry を走査して `D?2D` / `D?2E` に class-bit 集約を作る prepass helper**
とみるのが自然。

流れは:

1. `DE = D?2D`
2. `D?2D` と `D?2E` を 0 初期化
3. `B = 9` で 9 entry loop
4. `HL` から 2byte entry を読む
5. 非 `FF` entry だけ `0D:6F82 + entry*8` を引く
6. record 先頭 byte の `0x30` を見る
7. 非 0 なら、record 4 byte 目を `D?2D` か `D?2E` に OR 集約する

したがってこれは
**battle action の即時 descriptor build**
ではなく、
**page-local action candidate 群から class-dependent aggregate flags を作る前処理**
として扱うのが安全。

## 1. 実コード

```text
43FB: LD E,$2D
43FD: LD D,H
43FE: XOR A
43FF: LD (DE),A
4400: INC E
4401: LD (DE),A
4402: DEC E
4403: LD B,$09

4405: PUSH BC
4406: LDI A,(HL)
4407: CP $FF
4409: JR Z,$4434
440B: PUSH HL
440C: LD H,(HL)
440D: LD L,A
440E: PUSH DE
440F: ADD HL,HL
4410: ADD HL,HL
4411: ADD HL,HL
4412: LD DE,$6F82
4415: ADD HL,DE
4416: LD A,$0C
4418: CALL $00D2
441B: AND $30
441D: JR Z,$4432
441F: POP DE
4420: PUSH DE
4421: CP $10
4423: JR Z,$4426
4425: INC DE
4426: INC HL
4427: INC HL
4428: INC HL
4429: LD A,$0C
442B: CALL $00D2
442E: LD L,A
442F: LD A,(DE)
4430: OR L
4431: LD (DE),A
4432: POP DE
4433: POP HL
4434: INC HL
4435: INC HL
4436: POP BC
4437: DEC B
4438: JR NZ,$4405
443A: RET
```

## 2. entry の読み方

`4406-440D` は:

```text
LDI A,(HL)
CP $FF
...
LD H,(HL)
LD L,A
```

なので loop 入力は
**`HL` 上の 2byte little-endian entry 列**
と読むのが自然。

`A == FF` のときだけ即 skip しているため、
`FFxx` か少なくとも low byte `FF` が空 slot sentinel として使われている可能性が高い。

## 3. `0D:6F82 + entry*8`

entry 非空時は:

```text
ADD HL,HL
ADD HL,HL
ADD HL,HL
LD DE,$6F82
ADD HL,DE
```

で record base を作る。

したがって参照先は
**`0D:6F82` 起点の 8byte record table**
とみるのが自然。

ここで `CALL $00D2` を使っているため、
record 自体は banked ROM table として読まれている。

## 4. 先頭 byte の `0x30`

最初の fetch は:

```text
LD A,$0C
CALL $00D2
AND $30
JR Z,$4432
```

なので record 先頭 byte の
**bit4-5 だけを class selector として見ている**
ことになる。

分岐は:

- `00`: 集約対象外
- `10`: `D?2D` 側へ集約
- `20` または `30`: `D?2E` 側へ集約

と読むのが自然。

## 5. 集約するのは record 4 byte 目

class 対象なら:

```text
INC HL
INC HL
INC HL
LD A,$0C
CALL $00D2
LD L,A
LD A,(DE)
OR L
LD (DE),A
```

なので
**同じ 8byte record の 4 byte 目**
を `D?2D` か `D?2E` へ OR fold している。

ここで `DE` は `D?2D` または `D?2E` を指している。

## 6. 擬似コード

```ts
function foldActionClassFlags(entryList: Uint16Array, pageBaseHigh: number): void {
  let flagA = 0
  let flagB = 0

  for (let i = 0; i < 9; i++) {
    const entry = entryList[i]
    if ((entry & 0x00ff) === 0x00ff) continue

    const record = readBankedRecord8(0x0d, 0x6f82 + entry * 8)
    const klass = record[0] & 0x30
    if (klass === 0) continue

    if (klass === 0x10) {
      flagA |= record[3]
    } else {
      flagB |= record[3]
    }
  }

  write8((pageBaseHigh << 8) | 0x2d, flagA)
  write8((pageBaseHigh << 8) | 0x2e, flagB)
}
```

`entry` の型そのものはまだ未確定だが、
**「9件の candidate から class-dependent flags を畳み込む」**
という骨格はかなり強い。

## 7. `4417+` との関係

今回の重要点は、
`4417` という番地がこの helper の内部にも現れること。

ただしこれは
**`43FB-443A` の途中で `CALL $00D2` へ入る位置**
であって、
以前 battle core 本線として切っていた
**`4417+` の action class / RNG 分岐帯そのものと混同しないほうがよい**。

整理すると:

```ts
// 43FB-443A
foldActionClassFlagsFromCandidateList()

// 443B-4499
buildPointerCandidatesWithRng(slot07, slot08)
```

という 2 本立てで見るのが自然。

## 移植への意味

TypeScript 側では、
これを `battle` の即時 action resolve に直接混ぜるより、
controller/preparation 側 helper として分離しておくほうが安全。

```ts
prepareActionClassFlags(page)
buildPointerCandidates(page, rng)
```

## 次の一手

1. `43FB` 入口時点の `HL` が指す 9 entry list の実体を caller 側から固定する
2. `0D:6F82` 8byte record の field 意味を item/skill table と照合する
3. `443B-4499` に入る `BC` record layout を `D500/D600/D700` page から固定する
