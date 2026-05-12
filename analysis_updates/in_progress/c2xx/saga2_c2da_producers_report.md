# SaGa2 C2DA producers report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `rom/common.i`
- 既存 `saga2_battle_prepass_page_seed_report.md`
- 既存 `saga2_battle_prepass_hl_source_report.md`

## 目的

- `C2DA` table の producer 候補を集約する
- battle prepass seed に使われる 14 entry の意味を一段具体化する

## 結論

`C2DA` は battle 専用に一度だけ作られる固定表というより、
**複数 helper が low nibble / high nibble / payload を段階的に埋める packed 2byte entry table**
とみるのが自然。

今回の高確度な点は 3 つある。

1. `0D:4090-40B4` は `C2DA` を **consumer** として使い、high nibble で `D?` page を選び `D?2A/2B/2C` に seed を配る
2. `01:634A-6365` は `C2DA` 各 entry の **low nibble を見て `7F80` table から byte を埋める writer** 候補
3. `01:5B70-5B91` は `C2DA` 各 entry の **high nibble / low nibble の両方を見て packed 値を書き直す builder** 候補

したがって `C2DA` は、
少なくとも battle prepass 直前には
**「page selector (high nibble) + kind/slot index (low nibble) + payload byte」**
の 14 件配列として読める。

## 1. 既知 consumer: `0D:4090`

既報どおり:

```text
4090: LD HL,$C2DA
...
4098: LD A,(HL)
4099: AND $F0
...
40A0: SWAP A
40A2: DEC A
40A3: ADD A,$D0
...
40AD: LD (HL),E  ; actually D?2C = entry byte1
```

なので battle 側 consumer は、
**entry byte0 の high nibble だけ** を page selector として使っている。

low nibble はこの loop では無視される。

## 2. producer 候補 1: `01:634A-6365`

実バイト:

```text
6347: LD BC,$0E00
634A: LD HL,$C2DA
634D: PUSH HL
634E: LDI A,(HL)
634F: AND $0F
6351: JR Z,$6360
6353: LD E,L
6354: LD D,H
6355: LD HL,$7F80
6358: LD A,C
6359: RST $00
635A: LD A,$0C
635C: CALL $00D2
635F: LD (DE),A
6360: POP HL
6361: INC HL
6362: INC HL
6363: INC C
6364: DEC B
6365: JR NZ,$634D
```

ここから読めること:

- 14 件ループ
- `C2DA` の entry byte0 を読む
- **low nibble が 0 でなければ**
- `7F80 + index` 系 table (`RST $00` なので `HL += A`) から banked byte を読む
- その結果を `DE`、つまり **元の `C2DA` entry 先頭 byte位置へ書く**

完全な意味はまだ未確定だが、
少なくともこれは
`C2DA` entry byte0 を low nibble 条件で更新する
**packed-entry writer**
とみるのが自然。

## 3. producer 候補 2: `01:5B70-5B91`

実バイト:

```text
5B70: LD HL,$C2DA
5B73: LD BC,$0E00
5B76: LD A,(HL)
5B77: AND $0F
5B79: JR Z,$5B8E
5B7B: LD A,(HL)
5B7C: AND $F0
5B7E: JR Z,$5B8B
5B80: SWAP A
5B82: DEC A
5B83: PUSH HL
5B84: CALL $5B95
5B87: LD (HL),C
5B88: POP HL
5B89: JR $5B8E
5B8B: LD A,C
5B8C: LD (DE),A
5B8D: INC DE
5B8E: INC HL
5B8F: INC HL
5B90: INC C
5B91: DEC B
```

ここは少し粗いが、
少なくとも:

- 14 件ループ
- low nibble 非 0 entry だけ対象
- high nibble があるかどうかで別経路
- `C` を順番 index として使う
- `5B95` / `004C` を使ってアドレス変換している

という構造が見える。

`5B95` は:

```text
5B95: CALL $004C
5B98: LD HL,$C21F
5B9B: RST $00
```

なので `A * 16 + $C21F` 型の scale/address helper に近い。

このため `5B70-5B91` は、
`C2DA` の packed entry をもとに別表 `C21F` 側を引き、
**entry index / page selector / payload を組み直す builder**
候補として読むのが自然。

## 4. reader 候補: `00:1251`

別系統として:

```text
1251: LD HL,$C2DA
1254: RST $00
1255: LD A,(HL)
1256: AND $0F
1258: LD L,A
1259: LD H,$00
125B: CALL $15CE
```

がある。

ここでは `C2DA + A` で引いた entry byte0 の
**low nibble**
だけを使って別 helper `15CE` へ渡している。

このため low nibble は battle 以外でも
**kind / slot / class id**
として再利用されている可能性が高い。

## 5. `C2DA` の暫定構造

今回の材料だけで最も安全な仮置きは次。

```ts
type C2daEntry = {
  head: number    // high nibble = page selector, low nibble = kind/slot id
  payload: number // page-local seed payload
}
```

より battle prepass 寄りに書くなら:

```ts
type BattlePrepassSeedEntry = {
  pageNibble: number
  kindNibble: number
  payload: number
}
```

少なくとも `0D:4090` consumer との整合は高い。

## 6. 移植への意味

TypeScript 側では、
`C2DA` を 14件の packed seed entry として持ち、
seed 配布と slot class fold を別 step にするのが安全。

```ts
seedBattlePagesFromC2da(entries)
preparePageClassFlagsFromSlots(page)
```

## 現時点の整理

### 確度が高いこと

- `C2DA` は 14 件 * 2 byte の table
- battle consumer は entry byte0 の high nibble で `D?` page を選ぶ
- `01:634A` は low nibble 条件で `C2DA` entry を書き換える producer 候補
- `01:5B70` は high/low nibble 両方を見ながら `C2DA` を組む producer 候補

### まだ未確定なこと

- `C2DA` entry byte1 の正式意味
- low nibble が item slot なのか command kind なのか
- `5B95 -> C21F` の table 意味
- `7F80` table が battle prepass とどう結びつくか

## 次の一手

1. `01:5B70-5B91` をもう一段切って `C21F` table の意味を確認する
2. `01:634A-6365` の `7F80` table を dump して low nibble との対応を取る
3. `C2DA` が battle round ごとに再構築される入口を caller 側から絞る
