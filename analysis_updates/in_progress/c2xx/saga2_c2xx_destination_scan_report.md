# SaGa2 `C2xx` destination scan report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c2xx_block_writer_gap_report.md`

## 目的

- `C2xx` を destination にする block copy caller を洗う
- `C2F6` を含む hidden state がどの cluster に属しそうかを絞る

## 結論

今回の destination 側探索でも、
**`C2F6` を直接含む block copy/fill caller は見つからなかった**。

代わりにかなり強く言えるのは次の 3 点。

1. `C2xx` を destination にする高確度 bulk copy caller は、今見えている範囲では主に `C200` block へ集中している  
2. `C2B9/C2DA/C2A2` は point access や small-struct update で見え、bulk destination としては前面に出てこない  
3. したがって `C2F6` は visible/local records や selector-budget visible work とは別の、**さらに隠れた shadow state** である可能性が上がった

## 1. 今回見えた `C2xx` destination caller

### `67F8-6803`

```text
67F8: LD H,D
67F9: LD L,E
67FA: LD HL,$C200
67FD: CALL $0089
6800: CALL $01C8
6803: JP $000B
```

ここは `HL=$C200`, `DE=$A600`, `BC=$0180` で、
`C200` block の large copy/export と読むのが自然。

### `6748-675B`

```text
6748: CALL $01CB
674B: LD HL,$A600
674E: LD DE,$C200
6751: LD BC,$0180
6754: CALL $0089
```

こちらは逆向きで、
`A600 -> C200` の import/restore 風 block copy。

つまり bulk destination として高確度なのは、
少なくともこの cluster では `C200` block である。

## 2. 何が見えなかったか

今回も引き続き:

- `DE=$C2F6`
- `HL=$C2E0/C2F0` を base にした copy
- `BC` 幅 copy で `C2E0-C2FF` を覆う visible cluster

は見えていない。

したがって `C2F6` は、
`C200` block の export/import cluster とは別物として扱うほうが安全。

## 3. 意味すること

これで `C2F6` の候補はさらに絞られる。

### 可能性が低くなったもの

- player-local visible record
- `C200` family の export/import shadow
- `C2A2/C2B9/C2DA` と同相の visible selector workspace

### 相対的に上がったもの

- hidden optional-entry shadow state
- compact mode/state table
- overlap reused WRAM tail region

## 4. 次の一手

1. `01C8/01CB/000B` 周辺を切って `C200` export/import cluster と `C2F6` 系を完全に分離する  
2. `C2E0-C2FF` を含む larger WRAM block を memset する caller を `006D` 側からさらに掘る  
3. `C2F6` producer 探索は、以後 `point writer` ではなく `hidden/shared state init` として進める
