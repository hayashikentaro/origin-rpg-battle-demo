# SaGa2 `C200` export/import cluster report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_c2xx_destination_scan_report.md`

## 目的

- `01C8/01CB/000B` 周辺を切る
- `C200` export/import cluster を `C2F6` 探索線から分離する

## 結論

`6748-6803` 周辺は、
**`A600 <-> C200` の large block import/export cluster**
とみるのが最も自然で、
現時点では `C2F6` producer 探索からは外してよい。

今回強く言えるのは次の 4 点。

1. `674B-6754` は `HL=$A600`, `DE=$C200`, `BC=$0180`, `CALL $0089` なので **A600 -> C200 import**  
2. `67FA-6803` は `HL=$C200`, `DE=$A600`, `BC=$0180`, `CALL $0089` なので **C200 -> A600 export**  
3. `01C8 -> 091A` と `01CB -> 04F4` はこの import/export の前後で使われる cluster-local helper 群  
4. この cluster は visible `C200` block と `A600` side storage の往復で完結しており、`C2E0-C2FF` を hidden state として準備する線とは切り分けるほうが安全

## 1. import path

`6748-675B`:

```text
6748: CALL $01CB
674B: LD HL,$A600
674E: LD DE,$C200
6751: LD BC,$0180
6754: CALL $0089
6757: JP $01C8
```

ここでは `0089` が `HL -> DE` の `BC` byte copy なので、

```ts
copyBytesBC(src=A600, dst=C200, len=0x0180)
```

と読める。

つまりこの path は
**persistent/storage side から visible `C200` block へ戻す import**
である可能性が高い。

## 2. export path

`67F8-6803`:

```text
67F8: LD H,D
67F9: LD L,E
67FA: LD HL,$C200
67FD: CALL $0089
6800: CALL $01C8
6803: JP $000B
```

この直前で:

```text
67F7: LD DE,$A600
67FA: LD HL,$C200
67FD: CALL $0089
```

なので、

```ts
copyBytesBC(src=C200, dst=A600, len=0x0180)
```

となる。

つまりこちらは
**visible `C200` block を A600 side へ退避する export**
に見える。

## 3. `01C8` / `01CB`

wrapper 対応:

```text
01C8: JP $04F4
01CB: JP $04FB
```

この段階では `04F4` / `04FB` の厳密契約までは切っていないが、
少なくとも import/export の前後でしか現れていないため、
cluster-local setup/teardown/helper とみるのが安全。

重要なのは、
この 2 本が `C2F6` hidden-state 準備線でなく、
**`C200` block transport cluster**
の一部だという点である。

## 4. `000B`

`6803: JP $000B` の landing は:

```text
000B: POP HL
000C: POP DE
000D: POP BC
000E: POP AF
000F: RET
```

なので、ここは単なる stack unwind / helper epilogue とみるのが自然。

これも `C2F6` producer とは無関係な transport-side control だと考えてよい。

## 5. なぜ `C2F6` 探索から外してよいか

この cluster で visible に触っている WRAM は:

- `C200` block

だけで、
`C2E0-C2FF` を destination/source にする様子は見えていない。

また copy 幅 `0x0180` は `C200` block 全体 transport としてかなり自然で、
`C2F6` のような hidden optional-entry state を局所的に準備する線とは別物に見える。

したがって次の探索では、
この cluster を `C2F6` producer 候補から外してよい。

## 6. 移植上の意味

TypeScript 側では、これは selector-runtime ではなく
**snapshot/import-export layer**
として分けて持つのが安全。

```ts
saveC200Block()
loadC200Block()
```

のような補助 API として隔離できる。

## 7. 次の一手

1. `01C8 -> 091A` と `01CB -> 04F4` の契約を必要なら切って `C200` transport cluster を閉じる  
2. `C2F6` producer 探索はこの cluster を除外して hidden/shared state init 側に集中する  
3. `006D` caller から `C2E0-C2FF` を zero-fill する path をさらに抽出する
