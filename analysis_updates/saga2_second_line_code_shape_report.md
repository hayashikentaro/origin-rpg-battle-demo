# Saga2 Second-Line Code-Shape Report

## 要点

- current implementation frontier では、routing layer の second-line reopening は **`postBranchTargetSource -> pointerFlavor -> final target`** の順に provisional にコードへ反映できる段階まで来ている
- これは battle-side の current best reading、すなわち  
  - `postBranchRoute` のあとに  
  - candidate-flavored target/source reopening  
  - candidate-flavored pointer/materialization reopening  
  - final target determination  
  が続く、という整理とかなり整合する
- したがって現在の safest code shape は、`combatDecision` と `postBranchRoute` のあとに second-line reopening を明示的に並べる 3 層構造である

## 1. Current Second-Line Shape In Code

current frontier の `ActorResolveResult` では、
first-line の decision/routing skeleton のあとに
次の second-line fields を持つのが自然になっている。

```ts
type ActorResolveResult = {
  branch: number
  postBranchRoute: number
  postBranchTargetSource: "explicit" | "candidate" | "slotIndex"
  pointerFlavor: "candidate" | "shared"
  target: number
}
```

ここで:

- `postBranchTargetSource` は second-line reopening の入口
- `pointerFlavor` は pointer/materialization の reopening
- `target` は final target determination

という並びで読むのが safest である。

## 2. How PTR Maps Into This Shape

`PTR` 側の current best bias は次の通りである。

- first-line では `branchVariant` を持つ
- second-line では `postBranchTargetSource="candidate"`
- さらに `pointerFlavor="candidate"`
- そのあと final `target`

つまり `PTR` の candidate 由来差分は

- first-line では `branchVariant`
- second-line では `postBranchTargetSource / pointerFlavor`

へ段階的に reopen するとみるのが自然である。

## 3. How ATK Maps Into This Shape

`ATK` 側は current best reading では:

- first-line では `branchVariant` を持たない
- second-line でも `postBranchTargetSource` は shared path (`slotIndex` など)
- `pointerFlavor="shared"`

となる。

したがって `ATK/PTR` の差分は、
完全に別 layer を持つことではなく、
shared shape の中で PTR 側だけが candidate-flavored reopening を見せる、
という構図になる。

## implication for step 6

この整理により、step 6 の current code frontier はかなり明確である。

1. `combatDecision`
2. `postBranchRoute`
3. `postBranchTargetSource`
4. `pointerFlavor`
5. `target`

の順で provisional skeleton を積めばよい。

つまり current code shape は、
decision layer / routing core / second-line reopening
の 3 層として battle-side reading とかなりよく噛み合っている。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. battle-side evidence が `postBranchTargetSource -> pointerFlavor -> target` の順序を支持するか
2. `PTR` 側だけが second-line で candidate-flavored reopening を見せる current bias を維持できるか
3. pointer/materialization と final target の間に追加の hidden layer が要るか

ここが取れれば、current second-line code shape は recovered decomposition にかなり近づく。
