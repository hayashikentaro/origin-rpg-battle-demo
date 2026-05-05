# Saga2 Provisional API Boundary Report

## 要点

- current frontier では、battle-side 解析と TypeScript/Godot 実装の接点は **3 層の provisional API** として整理するのが最も自然である
- その 3 層は  
  1. decision layer  
  2. routing core  
  3. second-line reopening  
  であり、現在の code shape もこの分離にかなりよく一致している
- したがって step 6 の safest boundary は、raw battle work を mirror することではなく、この 3 層 API を先に固定して Godot と core をつなぐことである

## 1. Decision Layer

current best reading では、first-line の battle semantics は

```ts
type CombatDecision = {
  accepted: boolean
  branch: number
  branchVariant?: 0 | 1
}
```

へかなり狭まっている。

ここで:

- `accepted` は special-candidate family accept policy の first output
- `branch` は shared strict-fallback branch
- `branchVariant` は PTR false-side にだけ現れる optional refinement

と読むのが safest である。

つまり decision layer は、
accept/reject と local branch choice までを返す narrow API として切れる。

## 2. Routing Core

decision layer の次には、

```ts
type PostBranchRoute = number
```

に相当する shared routing core を置くのが current best reading である。

これは battle-side では

- `ATK`: `branch` だけで入る
- `PTR`: `branch + branchVariant` で refinement される

という shared core + PTR-only optional refinement
として読むのが自然である。

つまり routing core は、
decision 結果を受けて後段の reopening をどこから始めるかを決める中継層である。

## 3. Second-Line Reopening

current code frontier と battle-side reading を揃えると、
second-line reopening は次の順に置くのが自然である。

```ts
type SecondLineReopening = {
  postBranchTargetSource: "explicit" | "candidate" | "slotIndex"
  pointerFlavor: "candidate" | "shared"
  target: number
}
```

順序は:

1. `postBranchTargetSource`
2. `pointerFlavor`
3. `target`

であり、`PTR` 側だけが second-line で candidate-flavored reopening を見せる、
という current best reading に対応する。

## 4. Godot/Core Boundary

この 3 層分離を採ると、
Godot と TypeScript core の境界はかなり明快になる。

Godot が最初に渡すのは:

```ts
type BattleCommandInput = {
  actorIndex: number
  action: BattleActionHead
  outcomeLikeByte?: number
}
```

TypeScript core が first-line で返すのは:

```ts
type ActorResolveResult = {
  branch: number
  postBranchRoute: number
  postBranchTargetSource: "explicit" | "candidate" | "slotIndex"
  pointerFlavor: "candidate" | "shared"
  target: number
  combatDecision?: CombatDecision
}
```

つまり front 側は raw RAM page を知らなくても、
この actor-local resolve bridge を通して battle core を観測できる。

## implication for step 6

この整理を採ると、step 6 は

- ROM 完全解明待ち

ではなく、

- 3 層の provisional API を固定しながら
- unresolved semantics を battle-side evidence で後から強くしていく段階

だとはっきり言える。

言い換えると、
現在の safest implementation strategy は

1. decision layer を固定
2. routing core を固定
3. second-line reopening を固定
4. 各 field の意味論を後から recovered semantics に押し上げる

である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. battle-side evidence がこの 3 層 API 分離を維持できるか
2. `PTR` second-line の candidate-flavored reopening が target/pointer 層まで続くか
3. final target determination の直前に追加の hidden layer が要るか

ここが取れれば、この provisional API boundary はそのまま移植用 core interface にかなり近づく。
