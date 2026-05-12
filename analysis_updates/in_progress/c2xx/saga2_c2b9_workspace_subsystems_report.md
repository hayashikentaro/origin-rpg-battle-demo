# SaGa2 C2B9 workspace subsystems report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c71d_c2b9_runtime_buffers_report.md`

## 目的

- `C2B9` の writer / mutator を subsystem ごとに分ける
- `C71D` との役割差を整理する

## 結論

`C2B9` は単純な selector table というより、
**16 件 * 2 byte の menu/session workspace**
として運用されている可能性が高い。

今回の高確度な点は次の 4 つ。

1. `6797-679C` に全体 clear がある  
2. `663F-6646` に単一 entry の tombstone write (`FFFF`) がある  
3. `6657-6663` に active entry scan がある  
4. `5D84` / `65CA` / `1155` など複数 subsystem が reader として共有している  

したがって `C2B9` は、
`C71D` のような表示用 8-entry pair list より一段低い、
**候補集合/状態管理寄りの runtime workspace**
とみるのが自然。

## 1. 全体 clear subsystem

最も明確なのは `678D` cluster。

```text
678D: LD HL,$C200
6790: LD BC,$017C
6793: CALL $0072
6796: DEC A
6797: LD HL,$C2B9
679A: LD B,$20
679C: CALL $006D
```

`006D` は `HL` から `B` byte を `A` で埋める helper なので、
ここは

```ts
fill(C2B9, 0x20, A)
```

に相当する可能性が高い。

この cluster は menu/rendering 側に見えており、
`C2B9` を **session 開始時に一括初期化** していると読むのが自然。

## 2. 単一 entry invalidate subsystem

`661A-6647` には個別 entry を `FFFF` 化する pass がある。

```text
663B: LD A,($C70D)
663E: ADD A,A
663F: LD HL,$C2B9
6642: RST $00
6643: LD A,$FF
6645: LD (HL+),A
6646: LD (HL),A
6647: JP $65A3
```

ここでは `C70D` で選ばれた index の entry だけを tombstone 化している。

したがって `C2B9` entry は
**存在/無効化の状態を持つ mutable slot**
である可能性が高い。

これは fixed table 解釈とかなり相性が悪い。

## 3. active scan subsystem

`6657-6668` は active entry 検索 helper と読める。

```text
6657: LD B,$10
6659: LD HL,$C2B9
665C: LD A,(HL)
665D: INC A
665E: JR Z,$6667
6660: INC HL
6661: INC HL
6662: DEC B
6663: JR NZ,$665C
6665: SCF
6666: RET
6667: AND A
6668: RET
```

先頭 byte が `FF` の entry を探しているか、
少なくとも `FF` を sentinel としてスキャンしている。

この helper は shop / item usage / rendering menu cluster から複数回呼ばれている。

よって `C2B9` は
**空き/有効 slot を持つ可変集合**
として使われている可能性が高い。

## 4. read subsystem

`C2B9` の read は少なくとも 3 系統ある。

### direct indexed read

```text
5D84: LD HL,$C2B9
5D87: RST $00
5D88: RET
```

`A*2` 前提の entry pointer helper 風。

### high-range selector reader

```text
1153: SUB $10
1155: LD HL,$C2B9
1158: JR $115D
...
1161: RST $00
1164: LD A,(HL)
```

`10CC` high-range reader で byte0 を selector source index として読んでいる。

### price/item usage reader

```text
65C9: ADD A,A
65CA: LD HL,$C2B9
65CD: RST $00
65CE: LD A,(HL+)
65CF: CP $FF
...
65D9: LD A,(HL-)
65DA: LD ($C73C),A
65DD: LD A,(HL)
65DE: LD ($C73B),A
```

こちらは byte0 / byte1 の両方を読む。

この差から、
`C2B9` entry は少なくとも

```ts
type C2b9Entry = {
  sourceIndex: number
  aux: number
}
```

程度の 2byte struct を持つ可能性が高い。

## 5. `C71D` との役割差

### `C71D`

- 8 件 * 2 byte
- single-entry writer と bulk builder がある
- 主に表示候補 list / pair table に見える

### `C2B9`

- 16 件 * 2 byte
- clear / invalidate / scan / read がはっきりある
- 候補 list というより mutable workspace / slot set に見える

つまり両者は同じ “selector buffer” でも、

- `C71D`: presentation-oriented pair list
- `C2B9`: stateful candidate workspace

という役割差を仮置きするのが自然。

## 6. 暫定モデル

```ts
type C2b9Entry = {
  sourceIndex: number // 0xFF => empty / invalid
  auxByte: number
}

type C2b9Workspace = C2b9Entry[] // 16 entries
```

さらに API レベルでは:

```ts
clearC2b9(fillByte)
invalidateC2b9Entry(index)
findActiveOrFreeC2b9Entry()
readC2b9Entry(index)
```

のように分けて持つほうが安全。

## 7. まだ未確定な点

- `clearC2b9` が `FF` 埋め固定か、呼び出し側の `A` 依存か
- byte1 の厳密な意味
- `65C9` 系が item/price 文脈で `C2B9` をどう構築しているか
- `10CC` high-range が読むときに、どの subsystem が事前構築した内容を前提にしているか

## 移植上の意味

TypeScript 側では `C2B9` を static lookup data に置かず、
**selector-runtime の mutable workspace**
として持つのが自然。

`battle` や `rng` からはさらに一段離して、
menu / item / script selector session が所有する state とみなすほうが安全。

## 次の一手

1. `65C9-65E0` を writer/reader混在部として切って `C2B9` entry の byte0/byte1 を具体化する
2. `5D84` caller 群を subsystem ごとに分けて `C2B9` の producer を逆引きする
3. `10CC` high-range reader を `C2B9` runtime 前提で読み直す
