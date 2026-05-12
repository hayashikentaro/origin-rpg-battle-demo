# SaGa2 battle RNG phase switch report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_battle_rng_cluster_boundary_report.md`
- 既存 `saga2_battle_rng_caller_cluster_report.md`
- 既存 `saga2_battle_rng_bc_page_report.md`

## 目的

- `0D:405A-4083` の役割を、既知 loop 契約から一段強く推定する
- `4040-408E` cluster の擬似コード化に向けた中間仮説を整理する

## 結論

実バイトを取り直した結果、
`405A-4083` は単なる空白ではなく、
かなり明確に
**`D0xx` 5-page loop の終了処理と、`D5xx` 3-page prepass loop の初期化をつなぐ phase switch**
だった。

重要な点は 4 つある。

1. `403C` ではなく、前半 source deposition loop の実開始は `4024`
2. `4048-405A` には別の **`D0xx` 5-page loop** があり、`CALL $1918` と `CALL $449A` を回している
3. `405C: CALL $0198` の条件で `D400-` 先頭 2 byte を clear する分岐がある
4. `4067-4075` で本当に `BC=$D500`, `A=3` を再設定し、`CALL $443A` を 3 回回している

したがって、この帯の役割は
**前半 deposition loop -> 中間 5-page staging loop -> 3-page prepass loop**
をつなぐ cluster 中継部とみるのが最も整合する。

## 1. 実バイト

今回取れた `0D:4024-4075`:

```text
4024: C5          PUSH BC
4025: D5          PUSH DE
4026: 1E 00       LD E,$00
4028: 1A          LD A,(DE)
4029: B7          OR A
402A: 28 03       JR Z,$402F
402C: CD F4 44    CALL $44F4
402F: D1          POP DE
4030: 14          INC D
4031: C1          POP BC
4032: C5          PUSH BC
4033: 3E 03       LD A,$03
4035: 90          SUB B
4036: C6 49       ADD A,$49
4038: 4F          LD C,A
4039: 06 D8       LD B,$D8
403B: FA 10 DE    LD A,($DE10)
403E: 02          LD (BC),A
403F: C1          POP BC
4040: 05          DEC B
4041: 20 E1       JR NZ,$4024
4043: AF          XOR A
4044: 16 D0       LD D,$D0
4046: 06 05       LD B,$05
4048: C5          PUSH BC
4049: F5          PUSH AF
404A: 21 00 C2    LD HL,$C200
404D: CD 18 19    CALL $1918
4050: D5          PUSH DE
4051: CD 9A 44    CALL $449A
4054: D1          POP DE
4055: 14          INC D
4056: F1          POP AF
4057: 3C          INC A
4058: C1          POP BC
4059: 05          DEC B
405A: 20 EC       JR NZ,$4048
405C: CD 98 01    CALL $0198
405F: 20 06       JR NZ,$4067
4061: 21 00 D4    LD HL,$D400
4064: AF          XOR A
4065: 22          LDI (HL),A
4066: 77          LD (HL),A
4067: 01 00 D5    LD BC,$D500
406A: 3E 03       LD A,$03
406C: F5          PUSH AF
406D: C5          PUSH BC
406E: CD 3A 44    CALL $443A
4071: C1          POP BC
4072: 04          INC B
4073: F1          POP AF
4074: 3D          DEC A
4075: 20 F5       JR NZ,$406C
```

これで `405A-4083` のうち、少なくとも `405A-4075` は実体が取れた。

## 2. 前半 deposition loop

source deposition loop の実体は `4024-4041` だった。

```text
4024: PUSH BC
4025: PUSH DE
4026: LD E,$00
4028: LD A,(DE)
4029: OR A
402A: JR Z,$402F
402C: CALL $44F4
...
403B: LD A,($DE10)
403E: LD (BC),A
4040: DEC B
4041: JR NZ,$4024
```

ここで `LD E,$00` のあと `(DE)` を見ているので、
`D` は page 高位、`E=0` は page 先頭 byte の活性判定だったとかなり明確になった。

また `404B: A=3 ; SUB B ; ADD 49`
から、各 iteration で writeback 先 low offset は

```text
C = 0x49 + (3 - B)
```

となる。

つまり前半 loop の `B` は:

- 残回数カウンタ
- 同時に `D849/D94A/DA4B` 風 writeback 先を選ぶ index

として二重に使われている可能性が高い。

少なくとも phase switch に入る時点では、
この `B` はもう source loop 用に消費済みだと考えるのが自然。

## 3. 中間 5-page loop

今回の最大の更新点は、
`4048-405A` に別 loop が存在したこと。

```text
4043: XOR A
4044: LD D,$D0
4046: LD B,$05
4048: PUSH BC
4049: PUSH AF
404A: LD HL,$C200
404D: CALL $1918
4050: PUSH DE
4051: CALL $449A
4054: POP DE
4055: INC D
4056: POP AF
4057: INC A
4058: POP BC
4059: DEC B
405A: JR NZ,$4048
```

ここから読めること:

- `D = $D0` から始めて `INC D` しているので、`D0xx..D4xx` の 5 page を回している
- `B = 5` が明示されている
- `A` も `0..4` の index として増えている
- `CALL $1918` と `CALL $449A` が page ごとに走る

したがって、
以前「phase switch の空白」と見ていた帯の前半は、
実際には **actor/descriptor page 側 5-entry staging loop**
だった。

## 4. 条件付き clear と後半 prepass loop

`405C` 以降は本当に phase switch / prepass 初期化だった。

```text
405C: CALL $0198
405F: JR NZ,$4067
4061: LD HL,$D400
4064: XOR A
4065: LDI (HL),A
4066: LD (HL),A
4067: LD BC,$D500
406A: LD A,$03
406C: PUSH AF
406D: PUSH BC
406E: CALL $443A
4071: POP BC
4072: INC B
4073: POP AF
4074: DEC A
4075: JR NZ,$406C
```

ここで見えた重要点:

- `CALL $0198` の結果で `D400/D401` clear が入る条件分岐がある
- `LD BC,$D500` と `LD A,$03` が明示されている
- `CALL $443A` は `D500/D600/D700` の 3 page に回っている

つまり以前の
`BC=$D849 -> D949 -> DA49`
仮説はここでは誤りで、
**`443A` caller は `D500/D600/D700` page family**
と読むのが正しい。

## 5. `443A` family の見直し

今回の実バイトで、
少なくとも `406E: CALL $443A` の caller 契約は修正が必要になった。

旧仮説:

- `BC=$D849/D949/DA49`

新しい高確度仮説:

- `BC=$D500/D600/D700`

そのうえで `443A` 本体が low offset を切り替えるかどうかは別問題として残るが、
**caller 側の page family は `D5xx-D7xx`**
とみるべき段階になった。

一方 `DE10 -> D849/D94A/D94B` 相当の writeback が前段にあること自体は変わらない。

## 6. `405A-4083` の最小責務

いまの材料だけで、この帯の最小責務は次の 4 つに絞れる。

1. `D0xx` 5-page staging loop の終了
2. `CALL $0198` による分岐判定
3. 必要なら `D400/D401` の clear
4. `D5xx-D7xx` 3-page prepass loop の初期化

なので、この帯は
「ただのレジスタ再設定」より一段重く、
**cluster 内の phase handoff control**
とみるほうが自然。

## 7. 暫定擬似コード

```ts
for (let i = 0; i < 3; i++) {
  const sourcePage = d5xxPages[i]
  if (sourcePage[0] !== 0) {
    scratch = buildScratchRecord(sourcePage) // 44F4
  }
  d8xxMeta49Family[i] = scratch.de10
}

for (let i = 0; i < 5; i++) {
  stageFromD0xxPage(i) // CALL 1918 + CALL 449A
}

if (!check0198()) {
  d400[0] = 0
  d400[1] = 0
}

for (let i = 0; i < 3; i++) {
  prepassFlags(d5xxFamily[i]) // 443A
}
```

ここで page family 名はまだ仮だが、
少なくとも loop count は
`3 -> 5 -> 3`
の並びで見えている。

## 8. 何が進んだか

今回の整理で、
`405A-4083` は
「何かあるはずの空白」ではなく、
具体的に:

- `CALL $0198`
- 条件付き `D400/D401` clear
- `BC=$D500`, `A=3` 初期化
- `CALL $443A` 3-page loop

を持つと確定した。

これで次に bytes が取れたとき、
見るべきポイントは明確。

- `CALL $1918` の契約
- `CALL $449A` の `D0xx` 5-page loopでの役割
- `CALL $0198` の意味
- `443A` が `D5xx-D7xx` page 内のどこを読むか

## 次の一手

1. `1918` と `449A` の契約を切って `D0xx` 5-page loop の意味を確定する
2. `443A` caller page family を `D5xx-D7xx` 前提で prepass report 側へ反映する
3. `4024-4075` 全体を battle controller prepare cluster として擬似コード化する
