# SaGa2 10CC selector contract report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `reports/saga2_script_opcode_analysis.csv`
- 既存 `saga2_c7e0_selector_semantics_report.md`

## 目的

- `00:10CC` の契約を切る
- `C7E0` low-range selector と high-range selector が同じ返り値形式かを整理する

## 結論

`10CC` は単発 helper というより、
**script 引数の range-dispatch に応じて `HL` を “候補 1byte へのポインタ” に正規化する selector dispatcher**
とみるのが自然。

今回かなり強く言えるのは次の 3 点。

1. low-range (`A < 0x10`) は caller 側で `C7E0 + index` を直接使う  
2. `10CC` に入る high-range は、`C71D`, `C2B9`, `player inventory` など複数の table/page へ振り分ける  
3. caller は最終的にどの経路でも **`A=(HL); CP $FF`** している

したがって `C7E0` の low-range path も `10CC` の high-range path も、
返しているのは抽象IDではなく
**“存在すれば 1byte 値が置かれている実スロット/候補 byte への参照”**
とみるのが安全。

## 1. `10CC` 実バイト

```text
10CC: CALL $004C
10CF: LD HL,$C21F
10D2: RET

10D4: LD HL,$C20F
10D7: LD DE,$0020
10DA: RST $30
10DB: CP $10
10DD: JP C,$115A
10E0: CP $20
10E2: JP C,$1153
10E5: CP $28
10E7: JR C,$1129
10E9: CP $30
10EB: JR C,$1126
10ED: CP $38
10EF: JR C,$1123
10F1: CP $40
10F3: JR C,$1120
10F5: CP $48
10F7: JR C,$111D
10F9: CP $51
10FB: JR C,$112C
10FD: CP $63
10FF: JR NC,$1113
1101: SUB $60
1103: LD HL,$D906
1106: ADD A,A
1107: RST $00
1108: LDI A,(HL)
1109: LD H,(HL)
110A: LD L,A
110B: LD B,$08
110D: LD DE,$6640
1110: JP $1554
1113: RST $30
1114: LD B,$08
1116: LD L,A
1117: LD DE,$6640
111A: JP $1552
...
1130: LDH A,($8B)
1132: AND A
1133: JR Z,$1146
1135: CALL $163B
1138: LD B,$08
113A: JP NC,$1562
113D: LDI A,(HL)
113E: LD H,(HL)
113F: LD L,A
1140: LD DE,$6640
1143: JP $1554
1146: LD A,($C709)
1149: LD HL,$C20F
114C: CALL $05D9
114F: LD A,B
1150: JR $115C
1153: SUB $10
1155: LD HL,$C2B9
1158: JR $115D
115A: LD HL,$C71D
115D: ADD A,A
115E: LD DE,$6640
1161: RST $00
1162: LD B,$08
1164: LD A,(HL)
1165: INC A
1166: JP Z,$1562
1169: JP $1551
```

`10CC` というラベルで既報に載っている範囲は、
実際には `10D4+` を含む大きい selector 本体として読むほうが自然。

## 2. caller 観点

`script opcode 0x1C`:

```text
109F: RST $30
10A0: CP $10
10A2: JR C,$10B1
...
10B7: LD A,($C709)
10BA: CALL $10CC
10BD: LD B,$08
10BF: LD A,(HL)
10C0: CP $FF
```

`script opcode 0x1D`:

```text
1237: RST $30
1238: CP $10
123A: JR C,$1244
123C: LD A,($C709)
123F: CALL $10CC
1242: JR $1248
1244: LD HL,$C7E0
1247: RST $00
1248: LD B,$01
124A: LD A,(HL)
124B: CP $FF
```

両方とも終点は
`LD A,(HL); CP $FF`
で揃っている。

このため `10CC` の contract は:

```ts
resolveSelectorRef(...) -> HL points to one-byte candidate value
```

とみるのが自然。

## 3. low-range と high-range の関係

`0x1C/0x1D` low-range:

- `HL = C7E0 + index`
- `A = (HL)`
- `CP $FF`

`10CC` high-range:

- range ごとに `HL = C71D / C2B9 / player inventory-derived / D906 pointer table ...`
- 最終的に `A = (HL)`
- `CP $FF`

つまり low-range `C7E0` path は、
high-range selector と同じく
**“最終 1byte candidate value を返す経路のひとつ”**
としてかなり自然に並ぶ。

## 4. `C7E0` entry の意味

今回の `10CC` 側整理を踏まえると、
`C7E0` は「候補そのもののID」でも大きくは外れないが、
より安全には

**caller が最終的に `A=(HL); CP $FF` する 1byte 値を格納した sparse remap table**

と表現するのがよい。

`5B64-5B90` で `sourceIndex C` を詰めている点から、
その 1byte 値は実装上
**physical slot / source index 系**
である可能性が依然として高い。

## 5. 暫定 contract

```ts
type SelectorByte = number | null // null <=> 0xFF

resolveSharedSelectorByte(logicalIndex): SelectorByte
resolveHighRangeSelectorRef(playerIndex, encodedArg): SelectorByte
```

low-range と high-range で実装経路は違っても、
返り値の意味は揃っているとみるのが安全。

## 次の一手

1. `1551/1552/1554` の contract を切って `10CC` の返り値をもう一段具体化する
2. `C71D` と `C2B9` の table 意味を `C7E0` と比較する
3. `5B64-5B90` caller 文脈で `sourceIndex C` がどの selector space に属するかを切る
