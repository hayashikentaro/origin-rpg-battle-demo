# SaGa2 selector name-table correspondence report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c71d_c2b9_selector_space_report.md`
- 既存 `saga2_c2da_producers_report.md`
- 既存 `saga2_1551_selector_terminal_report.md`

## 目的

- `6640` / `6EC0` の 8byte record table と shared selector index の関係を整理する
- `C2DA` entry と name table が同じ index 空間上にあるかを確認する

## 結論

完全な文字コード解読まではまだだが、
現時点では
**shared selector family の返り値 1byte は、`C2DA` entry index と `6640/6EC0` name record index を兼ねる**
とみるのがかなり自然。

今回の強い根拠は次の 3 点。

1. `109F/10D4` は selector 返り値をそのまま `1552/1554` に渡して `6640/6EC0` の 8byte record を引く  
2. `1237` は同じ selector 返り値を `ADD A,A ; HL=$C2DA ; RST $00` で `C2DA[index*2]` へ通す  
3. `1255: A=(HL); AND $0F` で `C2DA` head byte の low nibble を取り、`15CE` numeric formatter へ渡している  

したがって selector 層の返り値は、
少なくとも script/item selector 文脈では
**「名前テーブルにも packed seed table にも通せる source index」**
と読むのが最も整合する。

## 1. `6640` / `6EC0` は 8byte record table

`1551/1552/1554` の共通本体は:

```text
1554: CALL $0067
1557: LD A,$0F
1559: RST $28
155B: CALL $15B1
```

で、`CALL $0067` は `HL = DE + index*8` と読むのが自然だった。

caller 例:

```text
1061: LD L,A
1062: LD B,$08
1064: LD DE,$6EC0
1067: JP $1552

110D: LD DE,$6640
1110: JP $1554

115E: LD DE,$6640
1169: JP $1551
```

このため `6640` と `6EC0` は、
shared selector index を key に引く **8byte fixed-length record table** とみてよい。

dump を見ると、どちらも `FF` padding を含む 8byte 区切りで並んでいる。

### `0F:6640` 先頭 8 件

```text
00 6640: 71 CF E4 D5 E9 DA F2 FF
01 6648: E6 E9 64 CA F2 70 FF FF
02 6650: 71 CF E4 BC C3 C8 FF FF
03 6658: 97 8B B1 BA 8C 9D 8C FF
04 6660: 8F 99 9E FF FF FF FF FF
05 6668: DB C8 E3 E4 CA F2 70 FF
06 6670: 94 B7 52 A2 9B B2 4F FF
07 6678: C0 F2 62 C2 E2 F2 FF FF
```

### `0F:6EC0` 先頭 8 件

```text
00 6EC0: 8D A2 90 AC 5C 90 FF FF
01 6EC8: 95 8B 99 92 AC 5C 90 FF
02 6ED0: 95 AB 54 AC 5C 90 FF FF
03 6ED8: A8 8B 99 92 AC 5C 90 FF
04 6EE0: A8 9B 99 92 AC 5C 90 FF
05 6EE8: 54 B7 AB B7 8F FF FF FF
06 6EF0: 5C 91 A2 A3 9E FF FF FF
07 6EF8: D7 EA BD BC D7 E2 E7 F2
```

文字コード未解読でも、record table 構造自体はかなり強い。

## 2. 同じ index が `C2DA` にも入る

`1237` 後段:

```text
1248: LD B,$01
124A: LD A,(HL)
124B: CP $FF
124D: JP Z,$1562
1250: ADD A,A
1251: LD HL,$C2DA
1254: RST $00
1255: LD A,(HL)
1256: AND $0F
1258: LD L,A
1259: LD H,$00
125A: CALL $15CE
```

ここでは `A=(HL)` の selector 返り値を `A*2` して `C2DA` に通している。

これは、

```ts
const resolvedIndex = selector(...)
const c2daHead = C2DA[resolvedIndex * 2]
const lowNibble = c2daHead & 0x0f
```

というかなり素直な形になる。

つまり selector family の返り値は、
`C2DA` 14件 packed table の entry 番号として
そのまま使える可能性が高い。

## 3. `C2DA` low nibble は別表示系へ流れる

`125A: CALL $15CE` は numeric formatter だった。

したがって `1237` 経路では、
name table そのものではなく
**`C2DA[resolvedIndex]` の low nibble**
を数値表示/数量表示へ回している可能性が高い。

この点は、
selector 返り値が単なる名前 ID ではなく、
**packed entry を指す source index**
であることをさらに補強する。

## 4. `634A-6365` との整合

`C2DA` producer 候補 `634A-6365` は:

```text
634A: LD HL,$C2DA
634E: LDI A,(HL)
634F: AND $0F
6351: JR Z,$6360
6355: LD HL,$7F80
6358: LD A,C
6359: RST $00
635A: LD A,$0C
635C: CALL $00D2
635F: LD (DE),A
```

と読め、low nibble 非 0 entry について
index `C` を使って別表から byte を補う。

ここでも `C2DA` は index ベースに扱われているため、
selector -> resolvedIndex -> `C2DA[index]`
という流れとよく整合する。

## 5. 暫定対応モデル

現時点では次のモデルが最も安全。

```ts
type ResolvedSourceIndex = number // 0xFF => invalid

type C2daEntry = {
  head: number   // high nibble: page/block selector, low nibble: kind/count/slot id
  payload: number
}

type TextRecord8 = Uint8Array // FF padded

resolveSelector(arg): ResolvedSourceIndex
lookupC2da(index): C2daEntry
lookupName6640(index): TextRecord8
lookupName6ec0(index): TextRecord8
```

このとき `ResolvedSourceIndex` は、
少なくとも script/item selector 文脈では
shared key として再利用されている。

## 6. まだ未確定な点

- `6640` と `6EC0` の役割差
  - item 名 vs 条件名 / 種別名 / inventory class 名のどれか
- `C2DA` low nibble の厳密な意味
  - 数量上限 / kind / slot class / category のどれに寄るか
- `C71D` / `C2B9` 各 entry の実値
- `7F80` 側補助 table の意味

## 移植上の意味

TypeScript 側では selector 解決の返り値を、
UI 用の名前 lookup にも battle/item setup 用の packed entry lookup にも使える
**shared source index**
として切り出すのが安全。

つまりここは `rng` や `battle` の private state ではなく、
`shared-data` または selector/lookup 層に寄せるのがよい。

## 次の一手

1. `6640` と `6EC0` の caller を分類して table の役割差を切る
2. `C71D` / `C2B9` の static entry 値を実行時生成なし table として確定する
3. `125A: CALL $15CE` の周辺を追って `C2DA` low nibble 表示の意味を詰める
