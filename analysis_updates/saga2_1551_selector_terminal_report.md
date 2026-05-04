# SaGa2 1551 selector terminal report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_10cc_selector_contract_report.md`
- 既存 `saga2_c7e0_selector_semantics_report.md`

## 目的

- `1551/1552/1554` の contract を切る
- `10CC` / `C7E0` selector 系が最終的に何を返しているかをもう一段具体化する

## 結論

`1551/1552/1554` は selector resolver 本体ではなく、
**selector で得た 1byte/16bit 値を bank `0F` の 8byte record table に通し、
`C785` 表示バッファへ展開して共通 UI ループへ渡す terminal helper 群**
とみるのが自然。

今回かなり強く言えるのは次の 4 点。

1. `1551/1552/1554` は同じ本体の alias entry で、入力の持ち方だけが違う  
2. 本体は `DE + index*8` を bank `0F` から引き、`15B1` で `C785` へ 0-terminated buffer 化する  
3. invalid path の `1562` も最終的には同じ `C785` / `070C` UI 側へ流れる  
4. したがって `10CC` や `C7E0` が返している 1byte 値は、少なくともこの caller 群では **name/source index 系の値** とみるのが自然

## 1. entry alias の形

`1551` 先頭:

```text
1551: LD L,(HL)
1552: LD H,$00
1554: CALL $0067
1557: LD A,$0F
1559: RST $28
155A: PUSH AF
155B: CALL $15B1
155E: POP AF
155F: RST $28
1560: JR $1570
```

この並びから、3 本は別 helper ではなく同一本体への alias entry と読むのが自然。

- `1551`: `HL` が指す 1byte 値を index として使う
- `1552`: `L` にすでに 1byte index が入っている
- `1554`: `HL` がすでに index 値になっている

`CALL $0067` は `HL = HL*8 + DE` と読めるので、
ここで `DE` base の 8byte record table を引く準備をしている。

## 2. caller との対応

`10CC` 系 caller:

```text
1060: RST $30
1061: LD L,A
1062: LD B,$08
1064: LD DE,$6EC0
1067: JP $1552

1080: JP $1551

110D: LD DE,$6640
1110: JP $1554

115E: LD DE,$6640
1161: RST $00
1162: LD B,$08
1164: LD A,(HL)
1165: INC A
1166: JP Z,$1562
1169: JP $1551
```

ここで `DE=$6640` と `DE=$6EC0` の 2 系統が見えており、
どちらも 8byte 固定長 record を `1551/1552/1554` へ渡している。

bank `0F:6640` と `0F:6EC0` の dump も、
`FF` padding を含む 8byte text-like record とかなり自然に見える。

```text
0F:6640: 71 CF E4 D5 E9 DA F2 FF
0F:6648: E6 E9 64 CA F2 70 FF FF
...

0F:6EC0: 8D A2 90 AC 5C 90 FF FF
0F:6EC8: 95 8B 99 92 AC 5C 90 FF
...
```

したがって caller 側の selector byte は、
この table を引く **source/name index** とみるのが最も整合する。

## 3. `15B1` の役割

`15B1` は実質 `record -> C785 buffer` helper と読める。

```text
15B1: LD DE,$C785
15B4: LD A,($C77B)
15B7: AND A
15B8: JR NZ,$15BF
15BA: CALL $0080
15BD: JR $15CB

15BF: LD C,E
15C0: LD A,(HL+)
15C1: LD (DE),A
15C2: INC DE
15C3: INC A
15C4: JR Z,$15C7
15C6: LD C,E
15C7: DEC B
15C8: JR NZ,$15C0
15CA: LD E,C
15CB: XOR A
15CC: LD (DE),A
15CD: RET
```

`C77B==0` のときは単純に `B` byte copy して末尾に `00`。
`C77B!=0` のときは、最後の non-`FF` byte 位置を `C` へ覚え、
trailing `FF` を落として `00` terminator を打つ。

つまり `15B1` は selector byte 自体を返す helper ではなく、
**banked text record を表示用の 0-terminated buffer に整形する helper**
とみるのが自然。

## 4. `1562` の invalid path

`1166: JP Z,$1562`
`10C2: JP Z,$1562`
のように、`A==(FF)` 相当の invalid selector でも `1562` へ入る。

`1562` 冒頭:

```text
1562: LD A,($C77B)
1565: AND A
1566: RET NZ
1567: DEC A
1568: LD HL,$C785
156B: CALL $006D
156E: XOR A
156F: LD (HL),A
```

ここは `A=$FF` を使って `C785` へ `FF` を並べ、
先頭に `00` を置く empty buffer path と読むのが自然。

つまり invalid selector でも、
「何もない/空」の表示バッファへ落として同じ UI path へ流している可能性が高い。

## 5. 共通 UI tail

`1570+` は `C785` を一時的に `FFA2` pointer へ差し替え、
`070C` 共通 UI ループへ入る処理に見える。

```text
1570: LD DE,$C785
1573: LD HL,$FFA2
1576: LD C,(HL)
1577: INC HL
1578: LD B,(HL)
1579: LD (HL),D
157A: DEC HL
157B: LD (HL),E
157C: PUSH BC
157D: PUSH HL
157E: LD HL,$C77C
1581: LD A,(HL)
1582: LD (HL),$01
1584: PUSH AF
1585: CALL $070C
1588: JR $1585
158A: POP AF
158B: LD ($C77C),A
158E: POP HL
158F: POP DE
1590: JP $07D7
```

`07D7` は `DE -> FFA2/FFA3` setter と読めるため、
ここで旧 pointer を復元している可能性が高い。

この構造からも、`1551/1552/1554` は
「selector byte を返す」のではなく
**selector byte で名前/候補表示を起動する終端 helper**
とみるほうが自然。

## 6. `15CE-15F1` は sibling numeric formatter

同じ塊にある `15CE-15F1` は別 helper と見たほうがよい。

```text
15CE: CALL $15F2
15D1: LD B,$05
15D3: LD HL,$C785
...
15EA: ADD A,$80
15EC: LD (HL+),A
15F0: LD (HL),B
15F1: RET
```

`15F2` は `2710/03E8/0064/000A` を順に使う decimal extractor で、
`15CE-15F1` 全体は numeric value を `C785` 文字列表現へ変換する sibling formatter と読むのが自然。

したがって `1551/1552/1554` と `15CE-15F1` は
どちらも `C785` 表示バッファを作るが、

- 前者は banked 8byte record から文字列を取る
- 後者は数値を decimal 文字列へ変換する

という責務分離で並ぶ可能性が高い。

## 7. selector contract への反映

今回の整理で、
`10CC` / `C7E0` selector family が返す 1byte 値は
少なくともこの caller 群では

```ts
type SourceIndex = number // 0xFF means invalid / none
```

とみるのがかなり自然になった。

その後段は:

```ts
resolveSelectorByte(...) -> sourceIndex | 0xFF
lookupNameRecord(sourceIndex, tableBase6640or6EC0) -> C785-style display buffer
```

という 2 段構造で持つのが安全。

## 移植上の意味

- `C7E0` / `10CC` は shared selector workspace
- `1551/1552/1554` は selector resolver ではなく presentation terminal
- したがって Godot/TypeScript 側では
  selector 解決と名前表示 lookup を分離して持つほうがよい

特に `battle` / `rng` の本線から見ると、
ここは RNG bridge ではなく shared selection / UI terminal 側に寄っている。

## 次の一手

1. `C71D` と `C2B9` の entry 内容を `C7E0` と並べて source index 空間を切る
2. `070C` / `07D7` の UI contract を整理して `C785` buffer の消費側を確定する
3. `15CE-15F1` の numeric formatter caller を拾って text terminal family をまとめる
