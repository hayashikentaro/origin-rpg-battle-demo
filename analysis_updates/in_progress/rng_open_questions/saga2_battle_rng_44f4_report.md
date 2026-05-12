# SaGa2 battle RNG 44F4 report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_battle_rng_bc_page_report.md`

## 目的

- `0D:44F4` の契約を切る
- `443A / 443B / 449A / 44F4` の helper family 内での位置づけを整理する

## 結論

`0D:44F4` は RNG caller ではなく、
**`D?xx` page の low offset 群を入力にして `DE00` 周辺へ正規化 record を組む scratch builder helper**
と読むのが自然。

見えている核は 3 つ。

1. 入力は caller が持っている `D` page をそのまま使う  
   `E=$0A`, `E=$02` などへ切り替えて `D?0A`, `D?02` を読む
2. banked copy を 2 回使う  
   `0F:6EC0` 側から 8 byte、`0D:6F80` 側から 10 byte 前後を引く
3. 出力は `DE00-` の scratch layout  
   特に `DE0B`, `DE0C`, `DE10`, `DE12..` へ整形書き込みが見える

したがって `44F4` は
`443B-4499` の pointer builder そのものではなく、
同じ battle control family に属する
**record expansion / staging helper**
として扱うのが安全。

## 1. caller 文脈

`4044` caller:

```text
4040: LD A,(DE)
4041: OR A
4042: JR Z,$4047
4044: CALL $44F4
4047: POP DE
4048: INC D
```

このため `44F4` は
caller が回している `D` page を受け取る helper と読める。

少なくとも:

- `DE` は page ベース入力
- return 後も caller は `D` を 1 つ進めて次 page へ行く

ので、`44F4` は page-local record を scratch へ展開する位置づけに合う。

## 2. 実コードの骨格

冒頭:

```text
44F4: LD E,$0A
44F6: LD A,(DE)
44F7: LD L,A
44F8: LD E,$02
44FA: LD H,$00
44FC: ADD HL,HL
44FD: PUSH HL
44FE: ADD HL,HL
44FF: ADD HL,HL
4500: PUSH DE
4501: LD DE,$6EC0
4504: ADD HL,DE
4505: POP DE
4506: LD A,$0F
4508: LD B,$08
450A: CALL $00B5
```

ここでは:

- `D?0A` を table index 風に読む
- `D?02` を保持したまま
- `0F:6EC0 + index*8` から 8 byte を取る

ので、まず bank `0F` の 8 byte record を参照している。

続き:

```text
450D: POP HL
450E: PUSH DE
450F: LD E,L
4510: LD D,H
4511: ADD HL,HL
4512: ADD HL,HL
4513: ADD HL,DE
4514: LD DE,$6F80
4517: ADD HL,DE
4518: LD B,$0A
451A: LD DE,$DE00
451D: LD A,$0D
451F: CALL $00B5
```

ここでは:

- さっき保持した index を再利用
- `index*5` を作って
- `0D:6F80 + index*5` を引く
- 10 byte を `DE00` へ展開

と読める。

## 3. `DE00` 側の layout

後半では `DE00` ベースに low offset 指定で書いている。

特に見えるのは:

- `DE0B`
- `DE0C`
- `DE10`
- `DE12..`
- 最後に `DE2D`

への書き込み。

途中の流れ:

```text
4524: LD DE,$DE00
4527: LDI A,(HL)
4528: PUSH AF
4529: AND $F0
452B: SWAP A
452D: LD E,$0B
452F: LD (DE),A
...
4546: AND $0F
4548: LD ($DE10),A
454B: INC A
454C: LD B,A
454D: LD E,$12
454F: LD A,$0D
4551: CALL $00D2
4554: INC HL
4555: LD (DE),A
4556: INC E
4557: XOR A
4558: LD (DE),A
4559: INC E
455A: LD A,$FE
455C: LD (DE),A
...
456F: XOR A
4570: LD E,$2D
4572: LD (DE),A
4573: INC E
4574: LD (DE),A
4575: RET
```

このため `44F4` は
**mixed-source table data を `DE00` scratch struct に正規化する helper**
とみるのが一番自然。

## 4. helper family の中での位置づけ

今回までの整理を並べると:

- `43FB-443A`: `BC` page の entry 群を読んで flag 集約
- `443B-4499`: slot `07/08` で pointer record を build
- `449A-44F3`: 別の expansion helper 候補
- `44F4-4575`: `D` page と ROM table から `DE00` scratch を build

つまりこの帯は
**battle control / descriptor / staging helper family**
としてまとまっている可能性が高い。

RNG が直接出るのは、この中では `443B-4499` だけ。

## 5. `BC` page 推定との関係

`44F4` は `BC` ではなく `D` page を主入力にしているため、
`443B` の `BC = D8xx/D9xx/DAxx family` 推定とは役割が分かれる。

より具体的には:

- `44F4` は `D?xx` page -> `DE00` scratch
- `443A/443B` は `D8xx-D Axx` control page 群 -> flag/pointer record

という 2 系統の staging が同じ controller cluster に並んでいる
可能性が高い。

## 6. 移植への意味

TypeScript 側では battle control helpers を
少なくとも次の 2 つに分けるのが安全。

```ts
buildPointerRecords(controlPage, rng)
buildScratchRecord(actorPageOrDescriptorPage)
```

このうち RNG を使うのは前者だけで、
`44F4` は deterministic な table expansion helper として
切り出せる可能性がある。

## 残る不明点

- `D?0A` index の正式意味
- `D?02` の役割
- `0F:6EC0` 8 byte record と `0D:6F80` 5 byte record の意味
- `DE00` scratch struct の正式レイアウト
- `44F4` caller が回している `D` page の正体

## 次の一手

1. `DE00` を参照する後続 caller を追う
2. `0F:6EC0` と `0D:6F80` の table dump を構造化する
3. `4040-408E` を helper family caller cluster として独立整理する
