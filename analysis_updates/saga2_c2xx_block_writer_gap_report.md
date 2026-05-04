# SaGa2 `C2xx` block writer gap report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c2f6_state_gap_report.md`
- 既存 `saga2_bulk_copy_fill_helpers_report.md`

## 目的

- `C2F6` producer 探索を block-writer 観点で一段整理する
- `C2E0-C2FF` を含む WRAM block 初期化パスの候補を絞る

## 結論

今回の探索では、
**`C2F6` を直接 base にした bulk writer はまだ見つからなかった**。

ただし代わりに 2 つの重要な整理ができた。

1. `0080/0089` caller のうち `C2xx` を直接触る高確度 cluster は、いま見えている範囲では主に `C200/C20F` 近辺に集中している  
2. したがって `C2F6` は `C200` 系の visible/local record とは別の shared shadow state で、point write でも `C200` 直系 copy でもなく、**さらに別の bulk init path** で準備される可能性が高い

つまり次の探索線は、
`C2F6` 単体ではなく
**`C2E0-C2FF` をまたぐ larger WRAM block を誰が準備するか**
に絞るのが自然。

## 1. 今回確認したこと

### `C2F6` direct base

見つかった direct base は引き続き:

```text
0667: LD HL,$C2F6
```

のみで、

- `DE=$C2F6`
- `BC=$C2F6`
- `LD (C2F6..),A`

は見えていない。

### `0080/0089` caller の `C2xx` 近傍

`0080` / `0089` caller のうち、
window 内に `C2xx` 即値が見えるものを拾うと、
高確度なのは:

- `6157/61F1` の `C200 <-> C7EE` 4byte copy
- `611C` の `C20F + 16*player` 初期化系
- `67F8-6803` の `HL=$C200`, `DE=$A600`, `BC=$0180` block copy

などで、
`C2F6` を含む `C2E0-C2FF` 近辺に直接届くものはまだ見えていない。

## 2. 何が分かったか

この偏りから、`C2F6` は:

- `C200/C204/C206/C20F` の player-local 16byte record 直系
- `C2A2/C2B9/C2DA` の selector-budget visible workspace 直系

ではない可能性が高い。

むしろ、
`0198` の predicate 専用に読む
**別レイヤの optional-entry state**
とみるほうが整合する。

## 3. `67F8-6803` の意味

`67F8-6803`:

```text
67F8: LD H,D
67F9: LD L,E
67FA: LD HL,$C200
67FD: CALL $0089
6800: CALL $01C8
6803: JP $000B
```

ここでは `C200` block が `A600` 側へ `BC=0x0180` copy されている。

これは大きな WRAM block copy の存在を補強するが、
source は `C200` であり `C2E0` ではない。

したがって current evidence では、
`C2F6` を含む block writer は
この cluster ではないとみるのが自然。

## 4. 今後の安全な仮説

現時点では、
`C2F6` は

```ts
type OptionalEntryStateTable = Uint8Array
```

のような hidden/shared state として持ち、
producer は未確定のままにしておくのが安全。

TypeScript 側の仮 API も引き続き

```ts
checkOptionalEntryPresence()
```

のままでよい。

## 5. 次の一手

1. `C2E0-C2FF` を丸ごと含む長さの `0089` / `006D` caller をさらに抽出する  
2. `C2xx` を source ではなく **destination** にする block copy caller を重点的に見る  
3. `01C8/000B` まわりを切って `67F8-6803` cluster の larger state export/import を整理する
