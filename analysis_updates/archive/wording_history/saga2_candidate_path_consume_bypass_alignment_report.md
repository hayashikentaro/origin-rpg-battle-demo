# Saga2 Candidate-Path Consume-Bypass Alignment Report

## 要点

- current best reading では、`07/08` candidate-selection path (`PTR` 側) の false 側も、**通常 local path と同じく current consume belt を回避する** とみるのが最も自然である
- 理由は、`combatDecision` の current shape がすでに path 別の細部より **special-candidate family の accept policy** に寄っており、`PTR` はその policy を踏む前段 candidate source が違うだけ、とみるほうが整合するからである
- したがって safest provisional reading は、`ATK` 系と `PTR` 系は `accepted=false -> consume-bypass` を共有し、その違いは **candidate source / fallback entry** に主にある、という形である

## 1. Why Alignment Is Natural

current skeleton では:

- `ATK` は local path 側
- `PTR` は slot `07/08` candidate-selection 側

を観測している。

しかし current `combatDecision` の unresolved source は、
どちらも最終的には

- `D?12..` candidate entry family
- `0E/0F` special-candidate family
- qualifier-based accept policy

へ寄っている。

このため、`PTR` だけ false 側で別の consume logic を持つとみるより、
まずは **同じ consume-bypass rule を共有する**
と置くほうが safest である。

## 2. What Actually Differs

現時点で違いとして強く見えているのは、

1. candidate source  
   `PTR` は `07/08` で pointer/candidate source を組む
2. target routing  
   `candidateOffset` と `targetSource="candidate"` を持つ
3. fallback entry  
   false 側で strict-path へ戻るときの entry point が local path と少し違う可能性

つまり current best reading では、
差が大きいのは **candidate の作り方**
であって、
**accepted=false のとき current consume belt を開かない**
という policy 自体は共有するほうが自然である。

## 3. Provisional Consumer Shape

現時点では、`ATK` と `PTR` の両方を次のように読むのが安全である。

```ts
type CombatDecisionConsumerResult = {
  accepted: boolean
  branch: number
  fallbackKind?: "strict-path" | "alternate-candidate-path"
  bypassesCurrentConsumeBelt?: boolean
}
```

そして current best bias は:

- `accepted=false`
- `bypassesCurrentConsumeBelt=true`

を両者で共有し、
差分は

- `candidateSource`
- `fallback entry flavor`

に置くことである。

## 4. Why This Helps Step 6

この alignment を採ると、step 6 の unresolved hook は

- local path ごとに別々の combat policy

として増やす必要がなくなる。

まずは

- shared accept policy
- path-specific candidate source

という 2 層で実装できるため、
`resolveActorCommand(...)` の provisional shape とかなり噛み合う。

## implication for `combatDecision`

この整理を採ると、current `combatDecision` は

- path-specific gate

より、

- **shared special-candidate accept policy**
- plus path-specific candidate source

として持つのが最も自然になる。

つまり false 側については、
`ATK` と `PTR` を分けるより
まず **consume-bypass を共有する accept/fallback branch opener**
として扱うのが safest である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `PTR` false 側が strict-path fallback と alternate-candidate fallback のどちらに近いか
2. `ATK` false 側と `PTR` false 側で `branch` の生成規則が同じか
3. true 側では `PTR` だけ current consume belt へ shortcut 的に入りやすいか

ここが取れれば、`combatDecision` は
**shared consume-bypass policy + path-specific source**
としてかなり安定する。
