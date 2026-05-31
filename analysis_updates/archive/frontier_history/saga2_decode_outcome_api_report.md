# SaGa2 `decodeResolvedOutcome -> advanceActionPhase` API Report

## Summary
- 現在の解析線を移植 API に最短で写すなら、`6157` 後段の最初の consumer は **`decodeResolvedOutcome(player, outcomeLikeByte)`** と **`advanceActionPhase(player, branch)`** の 2 段に分けて持つのが最も自然である。
- この切り方なら、ROM 上の staging page 全体を未確定のままでも、`611C -> 019E -> 6157` の意味論を TypeScript core へ先に移せる。
- したがって次の解析目標も、`outcomeLikeByte` の storage address より、**branch へ decode される契約** と **その branch が開く local phase** の確認に置くのが安全である。

## 1. Proposed Narrow Core Boundary

現時点の最小境界は次のように表せる。

```ts
const outcomeLikeByte = commitResolvedSelection(seedByte) // 019E
const branch = decodeResolvedOutcome(playerIndex, outcomeLikeByte)
advanceActionPhase(playerIndex, branch)
```

ここで:

- `commitResolvedSelection` は `611C` inner core
- `decodeResolvedOutcome` は `6157` entry 直後の最初の consumer 意味
- `advanceActionPhase` は battle-side local branch/phase 遷移

として持てる。

## 2. Why This Split Helps

この 2 段に分ける利点は 3 つある。

1. `outcomeLikeByte` の意味を page 配置から切り離せる  
2. `branch` を battle 本線の中間表現として先に立てられる  
3. `D400/D500` などの staging は後段 implementation detail に下げられる  

つまり、移植の blocker を
「RAM 配置の完全再現」から
**「branch 意味の確定」**
へ縮められる。

## 3. Safe Current API Shapes

現段階で安全な抽象は次の程度。

```ts
type OutcomeLikeByte = number
type ActionPhaseBranch = number

function decodeResolvedOutcome(
  playerIndex: number,
  outcomeLikeByte: OutcomeLikeByte
): ActionPhaseBranch

function advanceActionPhase(
  playerIndex: number,
  branch: ActionPhaseBranch
): void
```

将来的に `branch` が enum 的に解ければ、
ここをもっと高水準にできる。

## 4. What To Confirm Next

次の解析で本当に確認したいことは次の 2 点。

1. `outcomeLikeByte` が branch/input meaning を持つか  
2. その branch が `6157` 後段のどの local phase を開くか  

逆に、今はまだ急がなくてよいもの:

- staging page の全 field
- scratch header 全意味
- particle/effect 側の副次処理

## Implication
- `decodeResolvedOutcome -> advanceActionPhase` は今の解析線に最も合う移植用の narrow API
- 次の主戦場は `branch` の意味確定
- これが取れると `battle` 側 core の責務分離がかなり前へ進む
