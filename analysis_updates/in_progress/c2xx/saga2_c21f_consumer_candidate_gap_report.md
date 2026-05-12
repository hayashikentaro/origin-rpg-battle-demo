# SaGa2 `C21F` Consumer Candidate Gap Report

## Summary
- `C21F` の既知参照を `5B95`, `60E2`, `10CC` 周辺で見直すと、現時点で強く見えているのは **“16byte block base を返す/使う”** ところまでで、`+1..+F` の richer field consumer はまだ直接取れていない。
- 特に `10CC` は `LD HL,$C21F` を持つが、契約としては block 内容を解釈する reader というより、**selector dispatcher の一部として block-base/reference を正規化する層** と見るほうが自然。
- したがって次に探すべきなのは `C21F` base-return helper の再読ではなく、**その返り値のあとで block 内 offset を実際に読む caller** である。

## 1. What We Actually Have

### `5B95`
```asm
5B95: CALL $004C
5B98: LD HL,$C21F
5B9B: RST $00
5B9C: RET
```

- `A * 16 + C21F`
- 返るのは block base

### `60E2`
```asm
60E2: LD HL,$C21F
60E5: JP $019B
```

- battle flag off 通常経路ではやはり `A * 16 + C21F`
- ここでも返るのは block base

### `10CC`
既報では:

```asm
10CC: CALL $004C
10CF: LD HL,$C21F
10D2: RET
```

を含みつつ、その後段 `10D4+` では
`C71D`, `C2B9`, `C20F`, `D906` など複数 selector source を切り替えている。

このため `10CC` は:

- `C21F` block を中身まで解釈する consumer

というより

- **selector space を block base / candidate byte 参照へ正規化する dispatcher**

として読むほうが安全。

## 2. Why `+1..+F` Is Still Open
`C21F` について高確度で見えているのは:

- block `+0` へ `sourceIndex`
- packed head normalize
- block head clear
- block base address helper

までである。

いっぽう、まだ見えていないのは:

- `LD A,(HL+1)` 相当
- `INC HL` / `LDI A,(HL)` を block base から複数 byte 読む path
- `C21F + 16*n + k` (`k>0`) を意味づけできる caller

であり、これがない限り `C21F` を rich struct と断定するのは危険。

## 3. What `10CC` Does And Does Not Tell Us

`10CC` 周辺の重要点は:

1. low-range `C7E0` も high-range selector も最終的には `A=(HL); CP $FF` へ正規化される  
2. `C21F` はその高-range selector family の一部に見える  
3. しかし `10CC` report の時点では、`C21F` block base の先で `+1..+F` を読む証拠は強くない

つまり `10CC` は
`C21F` が shared selector infrastructure に属する可能性を補強するが、
**block struct の field 解読にはまだ直接つながらない**。

## 4. Safe Reading
現時点で最も安全なのは、
`C21F` を次のように保つこと。

```ts
type C21fBlock = {
  sourceIndex0: number | null
  rest: Uint8Array // unknown
}
```

そして helper 側は:

```ts
function getC21fBlockBase(index: number): number
```

程度に分ける。

## 5. Best Next Search
したがって最も効く次の探索は:

1. `5B95/60E2/10CC` 自体ではなく、その **caller の直後** を重点的に見る  
2. `HL` が `C21F + 16*n` になったあと `INC/LDI` で block 内複数 byte を読む path を探す  
3. `C21F` block が selector ref だけで終わるのか、shared candidate-state struct なのかをそこで切る

## Implication For Current Architecture
- `C7E0` は shared sparse remap/list としてかなり強い
- `C21F` は shared builder の片側出力として残る
- ただし richer field が出るまでは、`C21F` を shared candidate-state builder と強く言い切らず、
  **shared block-base/index table**
  として一段弱く持つのが安全

## Next Steps
1. `C21F` base-return helper caller の「直後」を逆引きして、block 内 offset read を探す。
2. `10CC` high-range path のうち `C21F` を返したあと `A=(HL)` 以外の使い方があるかを確認する。
3. 見つからなければ、`C21F` は rich struct ではなく block-head/index table に留まる可能性を上げる。
