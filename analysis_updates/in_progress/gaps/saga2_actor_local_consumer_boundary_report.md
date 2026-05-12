# SaGa2 `advanceActionPhase(player, branch)` Consumer Boundary Report

## Summary
- `branch` を per-actor local resolve step とみるなら、次の本命は **その branch を最初に読む actor-local consumer 境界** を固定することである。
- 現時点では、この consumer は battle round 全体を制御する大域ループより、**current player に束縛された局所 action resolve の入口** にあるとみるのが最も自然である。
- したがって次の解析では、wide page 更新より先に、**`player + branch` を受けて 1 actor 分の local step を進める narrow consumer** を探すのが安全である。

## 1. Current Narrow Model

ここまでの safest model は次の形。

```ts
const outcomeLikeByte = commitResolvedSelection(seedByte) // 019E
const branch = decodeResolvedOutcome(playerIndex, outcomeLikeByte)
advanceActionPhase(playerIndex, branch)
```

このとき未確定なのは、
`advanceActionPhase(...)` に相当する実 consumer が
battle 本線のどこにあるかである。

## 2. Why The Consumer Should Be Actor-Local

親ループは:

- `C709` に current player を入れる
- `611C` を回す
- success のときだけ `6157` へ渡す

という形で 1 player ずつ進む。

この構造から、
`branch` の最初の consumer もまずは
**その current player の局所処理**
として読むほうが自然である。

つまり最初に探すべきなのは:

- global turn controller
- UI state machine
- page-wide staging dispatcher

ではなく、

- actor-local action branch opener
- per-actor local resolve step consumer

である。

## 3. What This Narrows Down

次の観測対象として優先すべきもの:

1. `playerIndex` を明示/暗黙に前提にする consumer
2. small branch code を入力に取る consumer
3. その直後に larger staging/page effect を起こす consumer

逆に、今は優先度を下げてよいもの:

1. page 全体を直接読む大きな routine
2. battle round 全体の phase manager
3. UI/dispatch helper 群

## 4. Porting Implication

移植ではこの境界が見えると、
先に次の中間 API を置ける。

```ts
type ActionPhaseBranch = number

function advanceActionPhase(
  playerIndex: number,
  branch: ActionPhaseBranch
): void
```

これにより、
ROM 上の staging レイアウト確定前でも
`battle` 側の責務分離を前へ進められる。

## Implication
- 次の本命は `player + branch` を読む actor-local consumer 境界
- `branch` の最初の読み手は global ではなく per-actor local resolve 側にあるとみるのが自然
- 次の主戦場は actor-local branch opener の確認である
