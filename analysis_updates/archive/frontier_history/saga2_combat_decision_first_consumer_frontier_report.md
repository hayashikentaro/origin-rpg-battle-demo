# Saga2 Combat Decision First-Consumer Frontier Report

## 要点

- current best reading では、`combatDecision` の first consumer は `D400/D500` の wide page staging 全体ではなく、**actor-local opener 内の pre-candidate gate** にあるとみるのが最も自然である
- 具体的には、`6157` 後段で current player の local action resolve を開く consumer のうち、`kindId/arg` で local path を選んだあと、slot `07/08` candidate-selection や special-candidate accept policy に入る直前の narrow branch が first-line frontier になる
- したがって next battle/RNG pass では、`combatDecision` を page-wide effect へ直接結び付けるより、**actor-local opener の branch opener / accept-policy consumer** を first consumer とみるのが safest である

## 1. Why Not Wide Staging

既報では `6157` は

- `C200 <-> C7EE`
- `D400/D500`
- dispatch / staging

を含む大きい helper に見える。

しかし current shape の `combatDecision` は既に

- special-candidate family
- blocked ordinal
- zero-fast-path privilege
- nonzero consumable class

という **local accept policy**
にかなり寄っている。

この粒度の state を、いきなり wide page effect が読むとみるより、
まずは **current actor の局所 branch opener**
が読むとみるほうが整合する。

## 2. Where The Consumer Should Sit

いまの safest time order は次の形で置ける。

```ts
const branch = decodeResolvedOutcome(player, outcomeLikeByte)
const localPath = selectLocalActionPath(action.kindId, action.arg)
const candidate = maybeBuildCandidateWith07_08(localPath)
const combatDecision = resolveCombatRngAfterLocalPath(...)
consumeCombatDecisionInLocalOpener(player, localPath, candidate, combatDecision)
```

この最後の consumer は、

- page 全体を作る routine

より、

- actor-local queue/record consumer
- local branch opener
- candidate accept/reject gate

に置くほうが自然である。

## 3. Relation To Existing Frontiers

既報の local-action opener では、
first-line frontier は

- `kindId/arg` による local path/class 選択
- slot `07/08` の candidate-selection RNG
- `target/slotIndex` の routing

という順で見ている。

ここへ current `combatDecision` を重ねると、
その first consumer は

- `target` の最終適用
- `D400/D500` の広い staging

より前にある、

- **candidate entry が accept されるか**
- **next local phase へ進むか**

を決める narrow branch とみるのが最も自然になる。

## 4. Best Current Frontier

現時点で safest に言える frontier は次のように書ける。

```ts
function consumeCombatDecisionInLocalOpener(
  playerIndex: number,
  localPath: number,
  candidate: Candidate | null,
  combatDecision: CombatDecision
): ActionPhaseBranch
```

この consumer が何を返すかはまだ未確定だが、
少なくとも今の evidence では

- immediate page mutation

より、

- next local branch / accept policy result

を first output に持つほうが自然である。

## implication for step 6

この整理を採ると、step 6 で次に見るべきものは

- `combatDecision` の source をこれ以上細かくすること

だけではなく、

- その current shape が **actor-local opener のどの narrow branch に読まれるか**

を battle 本線側で押さえることになる。

つまり unresolved hook の次の frontier は、
`source refinement` より
**first consumer refinement**
にかなり移っている。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `combatDecision` が actor-local opener のどの branch opener に最初に読まれるか
2. その読みが `next local phase selector` に近いか、`candidate accept/reject` に近いか
3. `07/08` candidate-selection path と `special-candidate family` accept policy が同じ narrow consumer に流れ込むか

ここが取れれば、`combatDecision` は
source semantics だけでなく
**battle-side first consumer**
までかなり具体化できる。
