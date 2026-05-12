# SaGa2 7860 descriptor report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c2b9_entry_decode_report.md`

## 目的

- `0F:7860` table の形を確認する
- `6669 -> C760` が展開している `descriptor3` の実体を一段具体化する

## 結論

`0F:7860` は現時点で確認した範囲では、
**3byte 汎用 descriptor というより `little-endian 16bit value + 00 high byte` の配列**
とみるのが自然。

今回かなり強く言えるのは次の 3 点。

1. `6669` は `sourceIndex` を使って `0F:7860 + index*3` から 3 byte を `C760` へコピーしている  
2. dump した先頭 64 entry はすべて **`xx yy 00`** で、3 byte 目が常に `00`  
3. 値並びは `0x0032, 0x0190, 0x0578, ...` のような 16bit scalar 列としてかなり自然  

したがって `C760..C762` は、
少なくともこの subsystem では
**24bit 汎用 record** より
**16bit quantity/value を 3 byte scratch へ正規化したもの**
と読むのが安全。

## 1. `6669` の実体

既報どおり:

```text
6669: PUSH AF
666A: PUSH BC
666B: PUSH HL
666C: CP $FF
666E: JR NZ,$6678
6670: LD (DE),A
6671: INC DE
6672: LD (DE),A
6673: INC DE
6674: LD (DE),A
6675: INC DE
6676: JR $6688

6678: LD L,A
6679: LD H,$00
667A: ADD HL,HL
667B: RST $00
667C: LD BC,$7860
6680: ADD HL,BC
6681: LD B,$03
6683: LD A,$0F
6685: CALL $00B5
```

`A = sourceIndex` を:

- `FF` なら `FF FF FF`
- そうでなければ `0F:7860 + index*3` から 3 byte

として `DE`、つまり `C760` へコピーしている。

## 2. dump した table の形

先頭 64 entry dump:

```text
00 7860: 32 00 00
01 7863: 90 01 00
02 7866: 78 05 00
03 7869: 80 0C 00
04 786C: 90 1A 00
05 786F: F8 2A 00
06 7872: 90 65 00
07 7875: 90 65 00
08 7878: A0 8C 00
09 787B: 50 C3 00
...
3D 7917: 34 21 00
3E 791A: 50 46 00
3F 791D: 90 1A 00
```

この範囲では **3 byte 目が全件 `00`**。

つまり raw bytes は実質:

```ts
u16 = lo | (hi << 8)
pad = 0
```

の形に見える。

## 3. 16bit scalar としての自然さ

いくつか 16bit 化すると:

```text
00 -> 0x0032
01 -> 0x0190
02 -> 0x0578
03 -> 0x0C80
04 -> 0x1A90
05 -> 0x2AF8
06 -> 0x6590
09 -> 0xC350
```

のようになる。

これは text record や pointer pair より、
**quantity / price / magnitude / capacity**
のような scalar table としてかなり自然。

既存 report 側でも `data_prices` ラベルで拾われているため、
少なくともこの subsystem では
価格や値系 descriptor の可能性が高い。

ただしラベル名に引っ張られすぎず、
ここでは安全に
**16bit value table**
と表現するのがよい。

## 4. `C760` の意味

`65E1-65F7` では:

```text
65E1: LD DE,$C760
65E4: PUSH DE
65E5: CALL $6669
65E8: POP DE
...
6610: PUSH HL
6611: LD A,(HL+)
6612: OR (HL)
6613: INC HL
6614: OR (HL)
6615: POP HL
6616: JR NZ,$661A
6618: LD (HL),$01
```

この形から `C760..C762` は
少なくとも

- all-zero / all-FF のような「空値」判定
- その後段の表示/計算

に使われる 3byte scratch と読める。

ただし実値は `xx yy 00` なので、
意味論としては
**16bit value を 24bit scratch へ持ち上げたもの**
に近い。

## 5. `C2B9` decode への反映

従来の

```ts
descriptor3: [number, number, number]
```

は storage としては正しいが、
意味論としては

```ts
value16: number
scratch24: [lo, hi, 0x00]
```

と分けて表現するほうが実装寄り。

つまり `C2B9` decode bridge は:

```ts
sourceIndex -> value16 lookup (via 7860)
classByte   -> comparison/normalization path
```

の 2 本立てで持つのが自然。

## 6. まだ未確定な点

- `7860` が本当に価格 table か、より広い scalar table か
- `0183/0180` が `value16` 差異時に何を補正しているか
- `C760..C762` が他 subsystem でも同じ value scratch として使われるか

## 移植上の意味

TypeScript 側では `C760` を opaque 3byte descriptor として保持するより、
まず

```ts
lookupValue16BySourceIndex(index): number | null
```

を定義し、
必要なら presentation 側で 24bit scratch へ変換するほうが安全。

## 次の一手

1. `0183/0180` の contract を切って `classByte` 差異補正と `value16` 処理の関係を確認する
2. `5D84` caller 群を subsystem ごとに分けて `C2B9` producer を逆引きする
3. `7860` の caller をさらに拾って value16 table の用途範囲を切る
