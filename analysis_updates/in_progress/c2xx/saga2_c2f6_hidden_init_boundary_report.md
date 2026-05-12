# SaGa2 `C2F6` hidden-init boundary report

## 1. 目的

- ここまでの `C2F6` producer 探索で、どの層を除外できたかを 1 本にまとめる
- visible/runtime 層と hidden/shared init 層の境界を明確にする
- 次の探索を `C2F6` hidden backing state の準備線へ集中させる

## 2. 結論

ここまでの解析を統合すると、
`C2F6` producer はかなり強く
**visible selector / event / mode-transition 層の外側**
にあると整理できる。

現時点で安全に言えるのは次の 6 点。

1. `0198 -> 0608 -> 0661` は `C2F6` を読む **consumer predicate** であって producer ではない  
2. `006D`, `0072`, `00B5`, `00BC` の既知高確度 caller には `C2E0-C2FF` hidden block を準備するものがまだ出ていない  
3. `C200`, `C20F`, `C2B9`, `C7E0`, `C760`, `C785`, `A600` など visible/runtime workspace 群は `C2F6` と別レイヤにある  
4. `5E0D-5F44` と `01B0/01B3/01B6`, `RST $08`, `5E65/5EFE` は visible reset / dispatch / event progression 層としてかなり閉じている  
5. したがって `C2F6` backing state は、少なくとも caller 直前 local setup や visible helper family では作られていない  
6. 次の本命は **hidden/shared init / overlay reload / banked import / larger shadow block setup**

つまり今後の探索は、
`C2F6` そのものの意味づけより先に
**「いつ、どの wider hidden state と一緒に準備されるか」**
を切るのが筋になる。

## 3. consumer 側で確定したこと

既報 `saga2_c2f6_state_gap_report.md` の通り、
`0198` の read path は:

```text
0198 -> 0608 -> 063E -> 0661
0661: LD A,E
0662: AND $1F
0664: SRL A
0667: LD HL,$C2F6
066A: RST $00
066C: LD A,(HL)
```

で、`0198` caller では `E=0` 固定だった。

ここからは:

- `C2F6` は predicate backing bytes
- `0198` は `checkOptionalEntryPresence()`
- producer は別層

という整理がかなり固い。

## 4. visible clear/copy 層から外せたもの

### 4.1 zero-fill

既報 `saga2_c2f6_zero_fill_gap_report.md` では、
高確度 `006D` caller は次の 4 系統だった。

1. `C380` clear  
2. `C7E0..C7ED` fill  
3. `C20F + 16*player` fill  
4. `C2B9..C2D8` clear

このどれも `C2E0-C2FF` には届いていない。

### 4.2 bulk/small copy

既報 `saga2_c2f6_copy_wrapper_gap_report.md` では:

- `0072` = `HL` base `BC` byte zero-fill
- `00B5` = banked small record copy
- `00BC` = banked bulk copy wrapper
- `0067` = address math helper

という契約まで整理できた。

しかも高確度 caller は主に:

- `C200`
- `C760`
- `C785`
- `A600`

周辺に偏っている。

したがって helper 契約面からも、
`C2F6` hidden block 準備線はまだ visible/runtime caller 群に出ていない。

## 5. visible selector/event/mode-transition 層から外せたもの

ここ数本で切れた helper family は、かなり一貫して visible side に寄っている。

### 5.1 mode-transition family

- `5E31/5E35/5E40`: `C797/C798`, `C7A6`, `CC00`, `C796`, `C7DA` reset
- `5E0D`: `RST $10`, `RST $18`, `5F2B/5F44/5F0E` を含む visible mode transition

### 5.2 dispatch family

- `01B0/01B3/01B6`: reset / finalize / dispatch-prepare
- `RST $08`: `E` code つき visible dispatch primitive

### 5.3 event family

- `5E65(DE=$1C1B)`: success-side event 準備
- `5EFE`: fail-side event 準備

これらはすべて caller 文脈上、
**すでに用意された visible/local state を表示・進行・イベントへ流す層**
として整合している。

ここでも `C2F6` direct write は出ていない。

## 6. いま除外できる探索線

したがって、いまかなり安全に外せるのは次の線である。

1. caller 直前の local scratch clear/setup  
2. visible selector dispatch (`01B6 -> RST $08`)  
3. success/fail event helper (`5E65/5EFE`)  
4. visible mode transition / refresh (`5E0D-5F44`)  
5. 既知の `006D/0072/00B5/00BC` visible-runtime caller 群

もちろん「絶対に無関係」とまでは言わないが、
`C2F6` producer の主戦場として優先度はかなり落とせる。

## 7. 次の本命

この境界整理から、次に見るべき本命は次の 4 つになる。

1. `C2E0-C2FF` を含む **larger hidden shadow block** をまとめて準備する init path  
2. overlay reload や subsystem 切替時の **banked import/export**  
3. visible helper のさらに前段で走る **shared hidden-state init**  
4. `0198` caller 以前に一度だけ実行される **mode-entry bulk setup**

特に、
「point write がない」
「caller 直前に見えない」
「visible helper 群からも出ない」
という 3 条件がそろっているので、
`C2F6` は単独 byte state より
**大きい hidden block の一部**
とみるのがいちばん自然である。

## 8. 実装上の意味

移植観点では、この段階でもなお
`0198` を抽象 API として切り出す方針は正しい。

```ts
function checkOptionalEntryPresence(): boolean
```

の背後状態は未確定でも、
少なくともそれが:

- battle core RNG
- visible selector dispatch
- success/fail event message

そのものではないことはかなりはっきりしている。

## 9. 次の一手

1. `C2E0-C2FF` をまたぐ hidden/shared block init 候補を優先して抽出する  
2. overlay reload / banked import / subsystem entry の wider setup を探す  
3. visible helper family は原則いったん固定し、`C2F6` producer 探索の主戦場から外す
