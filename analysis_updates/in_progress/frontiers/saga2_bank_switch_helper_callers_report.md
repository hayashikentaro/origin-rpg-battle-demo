# SaGa2 bank switch helper callers report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_043e_contract_report.md`
- 既存 `saga2_mbc1_writepoints_report.md`
- 既存 `saga2_usage_handlers_pass27.csv`
- 既存 `saga2_usage_handler_names_pass28.md`

## 目的

- `04B1/04B9` bank switch helper の実 caller 構造を整理する
- `SaGa2` の実際の banked ROM access 主線が direct call か wrapper 経由かを切り分ける

## 結論

今回の整理で見えた大事な点は、
`SaGa2` の bank 切替主線は
**`04B1` 直CALLより、`RST $28` と `00D2` を中心とする wrapper 群**
にあること。

つまり構造はおおむね:

1. `04B1/04B9` が実際の `LD ($2100),A`
2. `RST $28` がその薄い公開入口
3. `00D2` が `banked read byte`
4. `00B5/00BC/00C3/00CA` が `banked copy/read` wrapper

という 4 段構えになっている。

なので `SaGa2` の bank 切替 usage を追うなら、
**`04B1` の direct xref より、`00D2` と `RST $28` caller cluster の分類**
を優先するのが効率的。

## 1. 実体

既知の本体:

```text
04B1: PUSH BC
04B2: LD C,A
04B3: LDH A,($FF88)
04B5: LD B,A
04B6: LD A,C
04B7: LDH ($FF88),A
04B9: LD ($2100),A
04BC: LD A,B
04BD: POP BC
04BE: RET
```

役割:

- 入力 `A = new bank`
- 保存 `FF88 = current bank`
- 実 write `($2100) = A`
- 返り値 `A = old bank`

## 2. 公開入口

`usage_handler_names_pass28.md` では:

```text
01AA: JP $04B1
```

となっている。

つまり `01AA` は bank switch helper の公開 jump entry。
ただし既存 report 群を見ても、
ROM 全体の高位ロジックが `CALL $01AA` を多用している形ではなく、
より下の wrapper を通している箇所が多い。

## 3. `RST $28` が実質的な薄い前段

`00D2` の実体:

```text
00D2: PUSH BC
00D3: RST $28
00D4: LD C,(HL)
00D5: RST $28
00D6: LD A,C
00D7: POP BC
00D8: RET
```

ここから読めること:

- `RST $28` は bank switch helper を叩く薄い入口
- `00D2` は `A=bank, HL=ROM addr` を受ける 1 byte banked read helper
- 前後 2 回 `RST $28` を使って bank swap / restore をしている

したがって `00D2` caller は
そのまま `banked table / banked data read` の caller 群と見なせる。

## 4. `00D2` caller 列挙

ROM 全体の `CALL $00D2` 静的列挙では、
少なくとも次の 43 箇所が見えている。

```text
00:073E 00:0D6F 00:0D78 00:0DBA 00:0FDA
00:162B 00:1658 00:1F7D 00:2B2D 00:2B3F
00:2B67 00:3237 00:323E 00:3F18 00:3F56
01:5789 01:584A 01:5BEE 01:5CFA 01:5DE6
01:635C 01:63EC 01:63F5 01:63FC 01:6442
01:64A3 01:65F2 01:6D0D
0D:42D4 0D:42E4 0D:42ED 0D:42FE 0D:4309
0D:4310 0D:4329 0D:4341 0D:436C 0D:4373
0D:4417 0D:442A 0D:4552 0D:523B 0D:5F7D
```

この分布から、
`00D2` は局所 special case ではなく
**全 ROM にまたがる汎用 banked-read primitive**
だとはっきり言える。

## 5. caller cluster の大まかな分類

### A. item/data 読み出し cluster

既存 `usage_handlers_pass27.csv` では:

- `00:073E`
- `01:63EC`
- `01:63F5`
- `01:63FC`
- `01:6442`

などが `item_usage_reader` / `shop_handler` 文脈に現れる。

これは `00D2` の主用途のひとつが
**banked item/data table の 1 byte read**
であることを示す。

### B. battle queue / state cluster

bank `0D` では:

- `42D4/42E4/42ED/42FE/4309/4310`
- `4329/4341`
- `436C/4373`
- `4417/442A`
- `4552`

が集中している。

これは既報の `actors` queue / `437E` state staging / `4361` dispatch 周辺と重なるため、
battle runtime でも
**banked descriptor / data table read**
に `00D2` を使っていることを示す。

### C. graphics / script / UI cluster

- `00:1F7D`
- `00:3F18`
- `01:5BEE`
- `01:5CFA`

などは既存 report 上で
VRAM/UI/script 近傍に出る。

つまり `00D2` は
logic 専用ではなく
**graphics/script 側の banked asset read**
にも使われている。

## 6. `00B5/00BC/00C3/00CA` との関係

`usage_handlers_pass27.csv` では
`00B5/00BC/00C3/00CA` も以下の形で並んでいる。

```text
00B5: RST $28 ; PUSH AF ; CALL $0080 ; ...
00BC: RST $28 ; PUSH AF ; CALL $0089 ; ...
00C3: RST $28 ; PUSH AF ; CALL $00A4 ; ...
00CA: RST $28 ; PUSH AF ; CALL $00AC ; ...
00CF: POP AF
00D0: RST $28
00D1: RET
```

これらは `00D2` と同系統の
**banked bulk read/copy wrapper**
として見るのが自然。

したがって `SaGa2` の bank 切替 caller を分類するときは、
`00D2` だけでなくこの兄弟 wrapper 群も追うべき。

## 7. `04B1` direct caller を優先しない理由

`04B1` の本体は重要だが、
ROM 全体のロジックがこれを直接叩いているわけではない。

実際には:

- direct helper body `04B1`
- jump entry `01AA`
- thin swap `RST $28`
- typed wrappers `00D2`, `00B5`, `00BC`, `00C3`, `00CA`

という階層がある。

なので `04B1` だけを xref しても
`SaGa2` の「何のための bank switch か」は見えにくい。

逆に `00D2` caller を cluster 化すると、

- item table
- shop table
- battle descriptor
- UI/script asset

のように用途差が見えてくる。

## 現時点の整理

### 確度が高いこと

- `04B1/04B9` が実 bank switch 本体
- `01AA` はその jump entry
- `RST $28` は薄い bank swap/restore 前段
- `00D2` は 1 byte banked read の汎用 primitive
- `SaGa2` の実 usage 主線は wrapper 群側にある

### まだ未確定なこと

- `RST $28` そのものの完全契約
- `00B5/00BC/00C3/00CA` の各 wrapper の正確な copy 幅
- `00D2` caller の全用途分類

## 次の一手

1. `00D2` caller を item / battle / script / gfx に分類する
2. bank `0D` caller 群だけ抽出して battle descriptor read を深掘りする
3. `RST $28` の最小契約を単独で report 化する
