# SaGa2 Branch-to-State04/05 Alignment Report

## Summary
- 既報の `selected branch code = next local phase selector` 仮説と、`actors` loop の `04/05` priority window を重ねると、`decodeResolvedOutcome(...)` の返す branch は **actor-local state `04/05` 帯へ入る前段選択子** とみるのがかなり自然になる。
- この読みでは、`04/05` 自体が combat RNG の本体ではなく、**branch で開かれた actor-local phase の中で combat RNG が初めて要求される帯** になる。
- したがって TypeScript core でも、`decodeResolvedOutcome -> openLocalActionResolve -> resolveCombatRngAfterLocalPath` の 3 段を battle state machine に沿って素直に分離できる。

## 1. Why `04/05` Fits The Branch Hypothesis

既報では `selected branch code` に対して、
次の優先順位を置いていた。

1. next local phase selector
2. immediate result branch
3. adopted-result classifier

この仮説を battle 側へ戻すと、
branch が開く先として一番自然なのは

- round aggregate (`06/07`)
- global queue rebuild

ではなく、

- current actor page を見て
- local pointer/record candidate を触り
- actor-local path を進める

`04/05` 帯になる。

つまり `04/05` は、
branch 仮説と battle state machine の接続点として
かなり都合がよい。

## 2. Safe Current Reading

現時点の safest battle-side flow は次のように置ける。

```ts
const outcomeLikeByte = commitResolvedSelection(seedByte) // 019E
const branch = decodeResolvedOutcome(playerIndex, outcomeLikeByte)
const localPath = openLocalActionResolve(playerIndex, branch, actionHead)
const combatOutcome = resolveCombatRngAfterLocalPath(localPath, ...)
```

ここで:

- `branch` は `04/05` 相当の actor-local phase を開く前段 selector
- `04/05` 帯は local path / pointer / candidate handling
- combat RNG はその帯の内側か直後で初めて要求される

と読むのが一番整合する。

## 3. Why This Helps Search

この読みを採ると、
次に探すべき RNG callsite もかなり具体化する。

それは:

1. `decodeResolvedOutcome` より後
2. `04/05` local path に入ったあと
3. `07/08` candidate-selection builder ではなく
4. final writeback や aggregate gate より前

という narrow slot に置ける。

つまり search の焦点は
`branch` の storage ではなく、
**branch が開いた `04/05` local phase の内側**
へさらに寄せてよい。

## 4. Porting Implication

step 6 に向けては、
core 内部 API の責務分離もさらに自然になる。

```ts
function decodeResolvedOutcome(...): ActionPhaseBranch
function openLocalActionResolve(...): LocalActionPath
function resolveCombatRngAfterLocalPath(...): CombatOutcome
```

この分け方なら:

- branch decode
- local path open
- combat RNG

が battle state machine 上の順序に沿って並ぶため、
未確定部分を implementation detail 側へ押し込めやすい。

## Implication
- `branch` は first line で `04/05` 相当の actor-local phase を開く selector とみるのが自然
- combat RNG の本命探索点は `04/05` local phase の内側へさらに寄る
- 次の battle/RNG 解析は `04/05` 帯を branch-opened local phase として掘るのが安全
