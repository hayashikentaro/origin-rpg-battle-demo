# SaGa2 `C21F` Offset-Read Search Plan Report

## Summary
- ここまでの整理で、`C21F` の既知 high-confidence path はほぼすべて `block base を返す/使う` 段に留まり、`+1..+F` consumer を直接示すものはまだ出ていない。
- したがって次の実探索では、`C21F` まわりを広く読むのではなく、**after-base read の形そのもの** に search を固定するのが最も効率がよい。
- 具体的には、`CALL $5B95 / $60E2 / $10CC` の直後、または `HL=$C21F` 直後に続く `INC HL`, `LDI A,(HL)`, `ADD HL,DE`, `RST $00` 後の追加 offset 加算などを持つ path だけを候補に残す。

## 1. Keep / Drop Criteria

### Keep
次のようなパターンは `C21F + 16*n + k` (`k>0`) を読む候補として残す。

```asm
CALL $5B95
INC HL
LD A,(HL)
```

```asm
CALL $60E2
LD DE,$0003
ADD HL,DE
LD A,(HL)
```

```asm
CALL $10CC
LDI A,(HL)
LD H,(HL)
```

### Drop
次のようなパターンは当面除外してよい。

```asm
CALL ...
LD (HL),C
```

```asm
CALL ...
LD A,(HL)
CP $FF
JP $1551/$1552/$1554
```

前者は block `+0` writer、後者は selector terminal path であって、
`C21F` richer field の証拠にはなりにくい。

## 2. Known High-Confidence Non-Candidates
- `5B95` caller: `CALL ... ; LD (HL),C`
- `60E2` caller: `CALL ... ; LD (HL),C`
- `10CC` high-range dispatcher: selector source を `A=(HL); CP $FF` へ正規化する層

この 3 本は、現時点では
`C21F` richer field consumer の本命から外してよい。

## 3. Most Promising Surfaces
次に見る価値が高いのは、次の 2 面。

1. `C21F` base-return helper caller の直後  
   `CALL $5B95 / $60E2 / $10CC` 後に `HL` をどう扱うか
2. `HL=$C21F` を直接作る path  
   `CALL` を介さず `LD HL,$C21F ; ...` する断片

特に、`RST $00` のあとにさらに `INC/LDI` が続く形は、
block 内 field 読みの可能性が最も高い。

## 4. Current Safe Model

今のところ safest reading は次。

```ts
type C21fBlock = {
  sourceIndex0: number | null
  rest: Uint8Array // unknown
}

function getC21fBlockBase(index: number): number
```

ここから先は、
actual offset read が見つかった時点でだけ
field を増やすのが安全。

## 5. Implication For The Broader Search
- `C7E0` 側は shared sparse remap/list として十分進んでいる
- `C20F` 側は player-local selector work として進んでいる
- `C21F` は現状、shared block-base/index table に留まる

このため、`C21F` rich struct が見つからない限り
`60C0` を shared candidate-state builder と強く言い切るのはまだ早い。

## Next Steps
1. `C21F` path 限定で after-base read pattern を抽出する。
2. `INC HL` / `LDI A,(HL)` / `ADD HL,offset` を伴う候補だけを別レポートで列挙する。
3. 候補が出なければ、`C21F` は block-head/index table 仮説を強める。
