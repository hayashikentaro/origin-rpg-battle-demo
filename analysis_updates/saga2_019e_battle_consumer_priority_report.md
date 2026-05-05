# SaGa2 `019E` Battle-Consumer Priority Report

## Summary
- `019E` が確定する success-side local state を移植仕様へつなぐには、次に必要なのは **その local state を battle 本線のどこが読むか** である。
- 現時点の layering からすると、consumer 候補は `6157` より後の apply-side page 全体より、**`611C` 成功直後から battle action resolve へ渡る narrow bridge** にあるとみるのが自然である。
- したがって次の探索は、`019E` の direct writeback 先を単独で追うより、**`611C success -> 6157 entry -> battle-side action consumer`** の細い線を優先するのが最短である。

## 1. Why Consumer Search Is Now The Right Move

ここまででかなり固まったこと:

1. `019E` は `611C` inner core の commit frontier  
2. immediate target は success-side local meaning を持つ short state  
3. その state は post-resolve / pre-apply window にある  

この段階では、
writeback 先の完全確定だけを待つより、
**その後どこで読まれるか**
を押さえたほうが移植 API に直結する。

## 2. Consumer Candidate Layers

### High Priority

- `611C` success 直後の narrow bridge
- `6157` 入口付近の per-player apply handoff
- battle action resolve に入る直前の local-to-battle relay

### Lower Priority

- `D400/D500` page 全体
- `C200` visible record 全体
- 汎用 dispatch / UI / message 側

理由は単純で、
移植で必要なのは「どの large page に最終的に乗るか」より、
**action resolve が何の local result を入力として受けるか**
だからである。

## 3. Best Current Search Line

最も効率のよい次の探索線は:

```ts
const localSuccessState = commitResolvedSelection(seedByte) // 019E
const battleInput = handoffToActionResolve(localSuccessState)
resolveAction(battleInput)
```

この `handoffToActionResolve(...)` に相当する狭い橋を見つけるのが、
いまの最短目標になる。

## 4. Porting Implication

TypeScript core で先に必要なのは、
`019E` の exact storage address よりも、

- local success state の形
- それを action resolve がどう読むか

である。

したがって consumer 側の意味が取れれば、
アドレス完全確定前でも API 先行で切り出せる可能性が高い。

## Implication
- 次の主戦場は `019E` local state の battle-side consumer
- まず見るべきは wide page ではなく narrow bridge
- これが取れると `battle.resolveAction(...)` の中間 state がかなり固まる
