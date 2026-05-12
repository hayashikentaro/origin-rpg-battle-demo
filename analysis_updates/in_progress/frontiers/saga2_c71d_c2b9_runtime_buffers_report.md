# SaGa2 C71D/C2B9 runtime buffers report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c71d_c2b9_selector_space_report.md`
- 既存 `saga2_name_table_caller_classification_report.md`

## 目的

- `C71D` / `C2B9` が static table か runtime buffer かを切り直す
- selector infrastructure 側の誤読を修正する

## 結論

`C71D` と `C2B9` は ROM 上の fixed table というより、
**WRAM 上に構築・再利用される runtime selector buffers**
とみるのが自然。

今回強く言えるのは次の 4 点。

1. `C71D` には direct write が見えている  
2. `64 93-64A8` では shop/item usage 文脈で `C71D` に 8 件の pair を構築している  
3. `C2B9` には clear / scan / read helper が複数あり、固定表というより 16 件の 2byte workspace とみるほうが自然  
4. したがって以前の「`C71D/C2B9` は fixed selector table」という整理は弱く、**shared runtime selector state** として扱うのが安全

## 1. `C71D` への direct write

最も明確なのは `3EFC` cluster。

```text
3F06: LD (HL),C
3F07: LD A,C
3F08: LD ($C71D),A
3F0B: INC HL
...
3F16: LD A,$0C
3F18: CALL $00D2
3F1B: POP HL
3F1C: LD (HL),A
```

ここでは `C71D` 先頭へ `C` を直接書き、
続けて `C71E` 相当へ banked byte を書いている。

つまり少なくとも `C71D[0]` は
**ROM 固定値ではなく実行時に構築される**
と見てよい。

## 2. `6493-64A8` は `C71D` を 8 件の pair table として構築

shop/item usage 文脈では、`79E0` 側 source から `C71D` へ明示的に 8 件の pair を作っている。

```text
6493: LD DE,$C71D
6496: LD B,$08
6498: PUSH BC
6499: LD A,(HL+)
649A: LD (DE),A
649B: INC DE
649C: PUSH HL
649D: LD HL,$7E80
64A0: RST $00
64A1: LD A,$0C
64A3: CALL $00D2
64A6: POP HL
64A7: LD (DE),A
64A8: INC DE
64A9: POP BC
64AA: DEC B
64AB: JR NZ,$6498
```

この loop から読めること:

- `C71D` は 16 byte = 8 件 * 2 byte
- 各 pair は
  - byte0: `79E0` source の先頭 byte
  - byte1: `7E80 + sourceByte` から引いた banked byte

後段 `64AD-64BB` でもこの `C71D` pair table をそのまま読んで menu/render 側へ渡している。

したがって `C71D` は
**fixed selector source** というより
**runtime-built label/selector pair table**
とみるのが自然。

## 3. `C2B9` は clear / scan / read が揃っている

`C2B9` には固定 table より workspace らしい挙動が見えている。

### read helper

```text
5D84: LD HL,$C2B9
5D87: RST $00
5D88: RET
```

これは `A*2 + C2B9` 参照 helper 風。

### scan helper

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
```

ここでは 16 件を 2byte stride で走査し、
先頭 byte が `FF` かどうかを見ている。

### clear helper

```text
678D: LD HL,$C200
...
6797: LD HL,$C2B9
679A: LD B,$20
679C: CALL $006D
```

`$006D` は `HL` から `B` byte を `A` で埋める helper だったので、
ここは `C2B9..C2D8` 32 byte を一括初期化している可能性が高い。

以上から `C2B9` は
**16 件 * 2 byte の runtime workspace**
とみるほうが自然。

## 4. selector 側 caller の再解釈

`10D4-1169` の caller では:

```text
1153: SUB $10
1155: LD HL,$C2B9
...
115A: LD HL,$C71D
115D: ADD A,A
115E: LD DE,$6640
1161: RST $00
1164: LD A,(HL)
1169: JP $1551
```

これまでは `C71D/C2B9` を fixed table と読んでいたが、
runtime buffer と読み直すと、

- `C71D` / `C2B9` はその時点で有効な selector pairs / source bytes を保持
- `10D4` 側はそれを reader として参照

という構造になる。

つまり `10CC` high-range selector dispatcher は
ROM 固定 selector というより、
**事前構築された WRAM selector buffers を読む高位 reader**
とみるほうが安全。

## 5. 修正後の暫定モデル

```ts
type SelectorPair = {
  sourceIndex: number
  aux: number
}

type RuntimeSelectorTable8 = SelectorPair[]   // C71D, 8 entries
type RuntimeSelectorTable16 = Uint16ArrayLike // C2B9, 16 entries / 32 bytes
```

厳密な field 意味はまだ未確定だが、
少なくとも storage 性質としては
ROM static table ではなく WRAM runtime buffers に寄る。

## 6. 何がまだ未確定か

- `C71D` pair の byte1 が何を表すか
  - name-class byte / category byte / price-class byte のどれか
- `C2B9` 各 2byte entry の正式意味
- `10D4` 文脈で `C71D` と `C2B9` のどちらがいつ再構築されるか
- `3F08` / `6493` / `6797` が同じ subsystem か別 subsystem か

## 移植上の意味

TypeScript 側では `C71D/C2B9` を static JSON として持つより、
**selector session / menu state が構築する runtime lookup buffers**
としてモデル化するほうが安全。

`battle` / `rng` と切り離すなら、
これは `shared-data` ではなく `selector-runtime` に寄せるべき性質。

## 次の一手

1. `C71D` を構築する caller をさらに列挙して subsystem ごとの差を切る
2. `C2B9` の writer を直接拾って 16 件の entry 意味を整理する
3. `10CC` high-range dispatcher を「WRAM reader」として読み直す
