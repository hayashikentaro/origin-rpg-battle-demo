# SaGa2 `611C` -> `6157` Handoff Boundary Report

## Summary
- `019E` 後段 local state の battle-side consumer を探すうえで、最も重要なのは `6157` 全体ではなく、**`60F3-60F8` で成立している `611C success -> 6157 entry` の handoff 境界** である。
- ここでは `611C` が local success-side state を確定し、`6157` がそれを battle-side apply/staging へ渡す、という責務分離がかなり自然に読める。
- したがって次の consumer 探索は、`6157` の page-wide side effect 全体より、**entry 時点で何が「すでに決まっている入力」なのか** に絞るのが最短になる。

## 1. The Narrow Bridge

親ループ上の最小橋はここにある。

```asm
60F3: CALL $611C
60F6: JR NC,$610F
60F8: CALL $6157
```

この 3 命令だけでも、
かなり大きいことが言える。

1. `611C` は carry を success/fail 境界として返す  
2. `6157` は success path でだけ呼ばれる  
3. したがって `6157` は candidate 選択そのものではなく、**成功済み local result の後段 consumer**

である。

## 2. Why This Matters More Than Page-Wide Effects

`6157` の中では:

- `C200 <-> C7EE`
- `RST $08(E=$2C/$2D)`
- `D400/D500` init

など大きい副作用が見える。

しかし移植に必要なのは、
それら全部より先に
**`6157` が何を入力として受けているか**
である。

つまり重要なのは:

- `611C` 成功時点で確定済みの local state
- それを `6157` が battle-side に橋渡しする入口契約

であって、
wide page side effect の完全再現ではない。

## 3. Best Current Reading

高位では次の形に置ける。

```ts
const localSuccessState = commitResolvedSelection(seedByte) // 019E inside 611C
if (!localSuccessState) return fail
handoffToBattleApply(localSuccessState) // 6157 entry
```

この `handoffToBattleApply(...)` が今の最短観測点である。

## 4. Practical Search Focus

次に battle-side consumer を取るときは、
まず次の順で見るのが自然。

1. `611C` 成功条件そのもの  
2. `6157` entry が前提にしている local success state  
3. その state が `C200/C7EE/D400/D500` へどう落ちるか  

要するに、
**entry contract -> propagation**
の順で見るべきである。

## Implication
- battle-side consumer 探索の本命は `6157` の entry boundary
- `019E` の local state はまずこの境界で battle 側へ引き渡されるとみるのが自然
- 次の主戦場は `611C success -> 6157 entry` の handoff 契約である
