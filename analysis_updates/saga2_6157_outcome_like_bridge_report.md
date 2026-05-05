# SaGa2 `6157` Outcome-Like Bridge Report

## Summary
- `6157` entry の minimal handoff を `playerIndex + 1byte outcome-like state` とみるなら、次の最小 bridge は **その 1 byte を battle-side apply の入力意味へ昇格させる narrow relay** として持つのが自然である。
- ここで重要なのは、その byte が page-wide record 全体ではなく、**1 player 分の局所 outcome を指す入力値** だという点である。
- したがって次の consumer 探索は、`6157` を「大きな staging routine」としてではなく、**player-scoped outcome relay** として見るのが最も効率的である。

## 1. Minimal Handoff Restated

既報から、`6157` entry 直前に安全に仮定できるのは次の最小形。

```ts
type MinimalPlayerScopedHandoff = {
  playerIndex: number
  outcomeLikeByte: number
}
```

ここで `outcomeLikeByte` は:

- `019E` が確定した success-side local meaning
- raw seed cache より outcome semantics 側に寄る 1 byte

として持つのが自然である。

## 2. Why This Is A Bridge, Not Yet Final Battle State

`6157` は entry 後に:

- `C200 + 16*player`
- `C7EE`
- `D400/D500`

を触り始める。

しかしこれは「入力」ではなく、
**入力の outcomeLikeByte を battle-side state へ展開する過程**
として見るほうが自然である。

つまり高位では:

```ts
applyPlayerOutcome(playerIndex, outcomeLikeByte)
```

にかなり近い。

## 3. Porting Value

移植ではこの読みがかなり有用で、
先に必要なのは

- `playerIndex`
- `outcomeLikeByte`

の 2 本を受ける bridge 契約であって、
ROM 上の `D400/D500` staging layout を最初から完全再現することではない。

これが見えると TypeScript core 側では:

```ts
battle.applyResolvedOutcome(playerIndex, outcomeLikeByte)
```

のような中間 API を先に立てられる。

## Implication
- `6157` は page-wide staging 本体というより player-scoped outcome relay とみるのが自然
- 次の主戦場は `outcomeLikeByte` が battle 側で最初にどの意味で読まれるかの確認である
