# SaGa2 `6157` First-Branch Decision Report

## Summary
- `6157` を player-scoped outcome relay とみるなら、battle 側で最初に必要なのは page 全体の構築より **`outcomeLikeByte` がどの局所分岐を開くか** である。
- 現時点では、その最初の分岐は `wide battle page selection` より **1 player 分の local action resolve / next phase decision** とみるのが最も自然。
- したがって次の解析では、`6157` 後段の大きな staging そのものより、**その staging を呼び出す前に決まっている最初の branch decision** を本命にするのが安全である。

## 1. Why A First Branch Matters More Than Full Staging

`6157` には:

- `C200 <-> C7EE`
- `RST $08(E=$2C/$2D)`
- `D400/D500`

といった大きい副作用が見えている。

しかし移植で先に必要なのは、
それらを全部再現することではなく、

```ts
const branch = decodeOutcomeLikeByte(player, outcomeLikeByte)
advanceLocalActionResolve(branch)
```

の `branch` に相当する意味である。

## 2. Best Current Reading

いまの safest reading は次のようになる。

1. `611C` が player-local success-side state を確定する  
2. `6157` entry が `(player, outcomeLikeByte)` を受け取る  
3. battle 側の最初の consumer は、それを使って **この player をどの局所 phase / action branch へ進めるか** を決める  
4. そのあとに staging/page side effect が続く  

## 3. What This Excludes

この整理で優先度を下げられるもの:

- いきなり `D400/D500` field 全解読へ行くこと
- `C200` 全体を consumer とみなすこと
- `C7EE` scratch header の全意味を先に詰めること

これらは後段で必要になるが、
最初の branch decision より一段後ろでよい。

## 4. Porting Implication

TypeScript 側では、先に次のような中間 API を立てやすくなる。

```ts
const branch = battle.decodeResolvedOutcome(playerIndex, outcomeLikeByte)
battle.advanceActionPhase(playerIndex, branch)
```

ここまで切れれば、
ROM の page 配置をまだ完全確定していなくても
core の責務分離はかなり進められる。

## Implication
- `6157` 後段で最初に必要なのは staging 全体ではなく first branch decision
- `outcomeLikeByte` はその branch を選ぶ 1byte code とみるのが自然
- 次の主戦場は `next local phase / action branch` の consumer 確認である
