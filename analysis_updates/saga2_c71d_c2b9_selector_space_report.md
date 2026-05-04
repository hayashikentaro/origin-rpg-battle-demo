# SaGa2 C71D/C2B9 selector space report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_10cc_selector_contract_report.md`
- 既存 `saga2_1551_selector_terminal_report.md`

## 目的

- `C71D` と `C2B9` の table 経路を `C7E0` と並べる
- shared selector family が返す 1byte 値の意味をもう一段具体化する

## 結論

`C71D`, `C2B9`, `C7E0` は別々の selector source だが、
**返り値の値空間は同じ “resolved source index”**
とみるのがかなり自然。

今回の強い根拠は 3 つある。

1. `10CC` / `1237` の low-range / high-range どちらも最終的に `A=(HL); CP $FF` で 1byte 値を得る  
2. `1237` 後段では、その 1byte 値を **`C2DA + index*2`** へ通して low nibble を使っている  
3. `109F/10D4` 側では、同じ 1byte 値を `1552/1554` へ渡して bank `0F` table 名称解決に使っている  

したがって `C71D` / `C2B9` / `C7E0` の各 entry は、
候補ID一般ではなく
**`C2DA` entry 番号と name table index を兼ねる shared source index**
とみるのが安全。

## 1. `10CC` の range dispatch

既報どおり、`10CC` 本体は range ごとに別 table/source を選ぶ。

```text
10DB: CP $10
10DD: JP C,$115A
10E0: CP $20
10E2: JP C,$1153
...
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

ここでは:

- `0x00..0x0F` -> `C71D`
- `0x10..0x1F` -> `C2B9`

の 2byte stride table から 1byte 値を取り、
それを `1551` へ渡して `6640` name table を引いている。

この時点で `C71D` / `C2B9` の entry は、
少なくとも `6640` table の **name/source index** と読める。

## 2. `C7E0` low-range path との接続

`1237` 側では low-range と high-range が合流したあと、
返り値 1byte をさらに `C2DA` に通している。

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
124D: JP Z,$1562
1250: ADD A,A
1251: LD HL,$C2DA
1254: RST $00
1255: LD A,(HL)
1256: AND $0F
1258: LD L,A
1259: LD H,$00
125A: CALL $15CE
125D: LD HL,$C789
1260: JP $1593
```

ここがかなり重要で、
low-range (`C7E0`) でも high-range (`10CC -> C71D/C2B9/...`) でも
最終的に得た 1byte 値 `A` を

```ts
entry = C2DA[A]
```

ではなく正確には

```ts
entry0 = C2DA[A * 2]
```

として参照している。

つまり selector family の返り値は、
**`C2DA` 14件 table の entry index**
として使える共通空間にあるとみるのが自然。

## 3. `C2DA` low nibble との関係

`1255: LD A,(HL)` のあと `AND $0F` して `15CE` に渡しているため、
ここで表示しているのは selector byte 自体ではなく、
**`C2DA[resolvedIndex].head & 0x0F`**
である。

既報どおり `C2DA` entry byte0 は:

- high nibble = page selector / block selector 候補
- low nibble = kind/slot id 候補

と読むのが自然だった。

したがって `1237` は

1. selector family から `resolved source index`
2. その index で `C2DA` entry を引く
3. low nibble を数値表示/個数表示へ回す

という 2 段構造の可能性が高い。

この点は、`C7E0` 各 entry が単なる「論理ID」ではなく、
`C2DA` と接続する実 index だという強い裏づけになる。

## 4. `109F/10D4` 側との整合

一方 `109F/10D4` 側では、
同じ selector family の返り値を `1552/1554` へ流し、
`6EC0` や `6640` の 8byte record table を引いている。

```text
10B7: LD A,($C709)
10BA: CALL $10CC
10BD: LD B,$08
10BF: LD A,(HL)
10C0: CP $FF
10C2: JP Z,$1562
10C5: LD L,A
10C6: LD DE,$6EC0
10C9: JP $1552
```

ここでも `A` は
直接テキスト table index として消費されている。

つまり shared selector family の返り値は、

- `1237` では `C2DA` entry index
- `109F/10D4` では `6640/6EC0` name table index

としてそのまま使われている。

この二重の使われ方から、
`C2DA` と `6640/6EC0` は同じ source index 空間上で対応づいている可能性が高い。

## 5. `C71D` / `C2B9` の役割差

現時点で table 内容そのものは未 dump だが、
役割差はかなり見えている。

- `C71D`: `0x00..0x0F` range の fixed selector source
- `C2B9`: `0x10..0x1F` range の fixed selector source
- `C7E0`: 実行時に構築される dynamic sparse remap source

つまり `C71D` と `C2B9` は static/fixed table、
`C7E0` は runtime-built sparse remap という差はあるが、
**返り値の意味はそろっている**
とみるのが自然。

## 6. 暫定 contract

```ts
type ResolvedSourceIndex = number // 0xFF => none

resolveLowRangeSelector(logicalIndex): ResolvedSourceIndex
resolveFixedSelectorRange00_0F(logicalIndex): ResolvedSourceIndex
resolveFixedSelectorRange10_1F(logicalIndex): ResolvedSourceIndex

lookupPackedSeedEntry(index: ResolvedSourceIndex): C2daEntry
lookupName6640(index: ResolvedSourceIndex): TextRecord8
lookupName6ec0(index: ResolvedSourceIndex): TextRecord8
```

移植上は、
selector 解決の返り値型を `ResolvedSourceIndex` として共通化し、
その後段で `C2DA` lookup と name lookup を分けるのが安全。

## 移植上の意味

- `C71D/C2B9/C7E0` は別モジュールの state ではなく shared selector sources
- 返り値は battle 専用値でも script 専用値でもなく shared source index
- `battle` / `rng` からは一段離れた shared selection infrastructure として切り出せる

## 次の一手

1. `C71D` と `C2B9` の writer/初期化元を追って static table 内容を切る
2. `6640` と `6EC0` の record を index ごとに dump して `C2DA` entry との対応を取る
3. `125A: CALL $15CE` の caller 文脈を追って、`C2DA` low nibble 表示の意味を確定する
