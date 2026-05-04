# SaGa2 C2B9 entry decode report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c2b9_workspace_subsystems_report.md`

## 目的

- `65C9-65E0` の read/decode 区間を切る
- `C2B9` entry の byte0 / byte1 をもう一段具体化する

## 結論

`65C9-65E0` は単なる entry 読み出しではなく、
**`C2B9[index]` を `C73B/C73C/C760` へ正規化する decode step**
とみるのが自然。

現時点で強く言えるのは次の 4 点。

1. `byte0` は `FF` sentinel を持つ primary source index  
2. `byte1` は `byte0` とは別に比較・補正対象になる aux/class byte  
3. `byte0` は `6669` へ渡され、`0F:7860 + index*2` 系の 3byte record を `C760` へ展開している可能性が高い  
4. `byte1` は `0C:7E80 + byte0` から得る byte と比較され、差異があると補正処理へ入る  

したがって `C2B9` entry は、
少なくともこの subsystem では

```ts
type C2b9Entry = {
  sourceIndex: number // 0xFF => empty
  classByte: number
}
```

程度に読むのが最も安全。

## 1. decode 本体

実バイト:

```text
65C6: LD ($C70D),A
65C9: ADD A,A
65CA: LD HL,$C2B9
65CD: RST $00
65CE: LDI A,(HL)
65CF: CP $FF
65D1: CALL Z,$5EFE
65D4: JR Z,$65B1
65D6: CALL $5F07
65D9: LDD A,(HL)
65DA: LD ($C73C),A
65DD: LD A,(HL)
65DE: LD ($C73B),A
65E1: LD DE,$C760
65E4: PUSH DE
65E5: CALL $6669
65E8: POP DE
```

`RST $00` で `HL = C2B9 + index*2`。

その後:

- `LDI A,(HL)` で byte0 を読む
- `HL` は byte1 を指す
- `LDD A,(HL)` で byte1 を読んで `HL` を byte0 側へ戻す
- `LD A,(HL)` で再度 byte0 を読む

という流れになっている。

つまり `C73C = byte1`, `C73B = byte0` と読むのが自然。

## 2. byte0 は primary source index

`65CE: CP $FF` が非常に強い。

```text
65CE: LDI A,(HL)
65CF: CP $FF
65D1: CALL Z,$5EFE
65D4: JR Z,$65B1
```

この形から、先頭 byte は
**empty / invalid sentinel を持つ primary field**
とみるのが自然。

さらに `65DD` で再読された byte0 は、
直後に `6669` へ渡される。

```text
65DD: LD A,(HL)
65DE: LD ($C73B),A
...
65E5: CALL $6669
```

`6669` は `A` を index として使う helper に見えるので、
byte0 はかなり自然に `sourceIndex` と読める。

## 3. `6669` は `sourceIndex -> 3byte descriptor` 展開候補

`6669` 実バイト:

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

ここでは `A=sourceIndex` を:

- `FF` なら `DE` に `FF,FF,FF`
- そうでなければ `0F:7860 + index*2` 相当から 3 byte を `DE` へコピー

しているように見える。

したがって `C760..C762` は
**`sourceIndex` 由来の 3byte descriptor scratch**
候補とみるのが自然。

## 4. byte1 は `7E80 + sourceIndex` と比較される aux/class byte

`6669` のあと:

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
```

ここで `B = bank0C:7E80 + sourceIndex` 由来 byte、
`A = C73C = entry byte1`。

一致しないと補正処理:

```text
65FE: LDH A,($FF92)
6600: CALL $0183
6603: LD A,($C73C)
6606: CALL $0180
6609: LD A,$02
660B: CALL $0183
```

へ入る。

よって byte1 は、
**sourceIndex から機械的に導ける標準 class byte と比較される可変/派生 byte**
と読むのが自然。

安全には:

- class byte
- category byte
- price tier / item kind byte

のいずれか候補として保留するのがよい。

## 5. `C73B/C73C/C760` の役割

この decode 区間だけ見ると:

```ts
C73B = entry.sourceIndex
C73C = entry.classByte
C760..C762 = descriptor3(sourceIndex)
```

という staging が最も自然。

つまり `65C9-65E0` は
selector workspace `C2B9` の entry を、
後段 rendering/menu 処理が使いやすい scratch へ展開する
**decode bridge**
候補である。

## 6. `C71D` との差

`C71D` も pair table ではあったが、
`65C9-65E0` の `C2B9` はさらに一段進んで、

- sourceIndex
- aux/class
- descriptor3 scratch

へ分解されている。

この点からも `C2B9` は
presentation list より stateful candidate workspace に寄っている。

## 7. 暫定 struct

```ts
type C2b9Entry = {
  sourceIndex: number // 0xFF => empty
  classByte: number   // exact semantics TBD
}

type DecodedSelectorScratch = {
  sourceIndex: number
  classByte: number
  descriptor3: [number, number, number] | null
}
```

## 8. まだ未確定な点

- `classByte` の正式意味
- `0F:7860` の 3byte record 意味
- `0183/0180` が差異補正で具体的に何をしているか
- `C73B/C73C/C760` がこの subsystem 以外でも同じ意味か

## 移植上の意味

TypeScript 側では `C2B9` を読むとき、
直接 UI へ流すより

```ts
decodeC2b9Entry(index) -> DecodedSelectorScratch
```

のような bridge を 1 段置くほうが安全。

これで selector-runtime と presentation/usage 処理を分けやすくなる。

## 次の一手

1. `0F:7860` の 3byte record を dump して `descriptor3` の意味を詰める
2. `0183/0180` の contract を切って `classByte` 差異補正の意味を確定する
3. `5D84` caller 群を subsystem ごとに分けて `C2B9` producer を逆引きする
