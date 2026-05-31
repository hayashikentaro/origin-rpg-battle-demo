# SaGa2 name table caller classification report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- `reports/saga2_script_opcode_analysis.csv`
- 既存 `saga2_selector_name_table_correspondence_report.md`

## 目的

- `0F:6640` と `0F:6EC0` の caller を分類する
- 2 つの table の役割差を、言い切りすぎない形で整理する

## 結論

現時点では、

- `6EC0` は **inventory / script-arg / dynamic slot 解決寄り**
- `6640` は **high-range selector / fixed selector table / entity-class 解決寄り**

と分類するのが最も安全。

完全に「item 名 table」「種別名 table」と断定する材料はまだないが、
caller 文脈はかなりきれいに分かれている。

## 1. `6EC0` caller 群

高確度 caller は `104B-10C9` cluster に集中している。

### opcode `0x21 @ 104B`

```text
104B: RST $30
104C: CP $05
1050: CP $0D
1054: CP $10
...
1060: RST $30
1061: LD L,A
1062: LD B,$08
1064: LD DE,$6EC0
1067: JP $1552
...
1072: LD A,($C709)
1075: LD HL,$C204
1078: CALL $05D9
107B: LD B,$08
107D: LD DE,$6EC0
1080: JP $1551
...
10C5: LD L,A
10C6: LD DE,$6EC0
10C9: JP $1552
```

この cluster は `saga2_script_opcode_analysis.csv` では
`opcode 0x21` / `opcode 0x1C` 周辺に対応しており、
inventory / magi / script-arg selector をかなり強く含む。

ここでの `6EC0` は:

- script 直引数
- `C204 + player` 系の player-local slot
- `C7E0` / `10CC` 由来の resolved source index

を受けて引かれている。

したがって `6EC0` は、
**runtime に選ばれた slot/source を表示する table**
とみるのが自然。

## 2. `6640` caller 群

一方 `6640` caller は `10D4-1169` cluster にまとまっている。

### opcode `0x22 @ 10D4`

```text
10DB: CP $10
10DD: JP C,$115A
10E0: CP $20
10E2: JP C,$1153
...
110D: LD DE,$6640
1110: JP $1554
1117: LD DE,$6640
111A: JP $1552
...
113D: LDI A,(HL)
113E: LD H,(HL)
113F: LD L,A
1140: LD DE,$6640
1143: JP $1554
...
115A: LD HL,$C71D
115D: ADD A,A
115E: LD DE,$6640
1161: RST $00
1164: LD A,(HL)
1169: JP $1551
```

ここでは:

- fixed table `C71D`
- fixed table `C2B9`
- `D906` pointer table
- `163B` を通る indirect path

など、low-range sparse remap より
**高位 selector / fixed classification table**
が前面に出ている。

したがって `6640` は、
inventory の実 slot 名というより
**fixed selector class / entity-side label**
に寄った table とみるのが自然。

## 3. 2 table の共通点

ただし差がある一方で、
両者は同じ terminal family `1551/1552/1554` で扱われる。

```text
LD B,$08
LD DE,$6EC0 or $6640
JP $1551/$1552/$1554
```

なので構造上はどちらも

```ts
ResolvedSourceIndex -> TextRecord8
```

という同型 lookup table である。

違うのは返り値形式ではなく、
**どの selector 文脈から呼ばれるか**
だと見るのが安全。

## 4. 現時点での最も安全な役割差

### `6EC0`

- dynamic slot / runtime-resolved source を引く文脈に集中
- `opcode 0x1C` / `0x21` 周辺と強く結びつく
- item / inventory / magi / current slot 表示に近い可能性が高い

### `6640`

- high-range selector / fixed table / indirect pointer table を引く文脈に集中
- `opcode 0x22` / `10CC` 高位 dispatcher と強く結びつく
- class / category / entity-side label に近い可能性が高い

## 5. まだ断定しないほうがよい点

- `6EC0 = item name 専用` とまではまだ言わない
- `6640 = condition label 専用` とまではまだ言わない
- どちらも script VM 側では inventory/save-data class として混在的に使われている可能性がある

現段階では「caller cluster の違い」までを確定点とするのが安全。

## 6. 移植上の意味

TypeScript 側では、
1 本の巨大 text table として潰すより

```ts
lookupDynamicSourceLabel(index)   // 6EC0 side
lookupFixedSelectorLabel(index)   // 6640 side
```

のように presentation lookup を 2 本に分けるほうが安全。

ただし upstream の返り値型 `ResolvedSourceIndex` 自体は共通で持てる。

## 次の一手

1. `6640` / `6EC0` の caller を script opcode 単位でさらに列挙する
2. `15B1` で作られた `C785` buffer の実表示内容を実機/トレースで確認する
3. `C71D` / `C2B9` の static entry 値を追って fixed selector range の意味を詰める
