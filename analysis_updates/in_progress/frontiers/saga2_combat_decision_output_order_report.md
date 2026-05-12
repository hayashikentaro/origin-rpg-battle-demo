# Saga2 Combat Decision Output Order Report

## 要点

- current best reading では、`combatDecision` の first consumer は **`accepted` を first output、`branch` を second output** とするのが最も自然である
- 理由は、`combatDecision` の source semantics がすでに phase 名より
  - blocked / allowed
  - strict / shortcut
  - consumable / non-consumable
  という accept-policy 語彙に強く寄っているからである
- したがって safest provisional API は、`branch` を直接 first output にするより、**accept/reject を先に確定し、その結果を local branch へ写す** 形で持つことである

## 1. Why `accepted` Comes First

current `combatDecision` は:

- special-candidate family
- blocked ordinal
- zero-fast-path privilege
- nonzero consumable class

まで押さえられている。

この時点で battle-side が最初に知りたいのは、

- この candidate を通すか
- blocked とみなすか
- strict path に残すか / shortcut に進めるか

であって、
まだ wide phase 名そのものではない。

したがって first output は
**`accepted: boolean`**
に寄るのが自然になる。

## 2. Why `branch` Still Follows Immediately

second output としては、
その accept-policy がすぐ

- next local phase
- local sub-path
- apply-side narrow branch

へ投影される可能性が高い。

つまり safest ordering は:

1. accept/reject policy を確定
2. その結果から branch を得る

である。

## 3. Provisional API Shape

現時点で最も安全な抽象は次の形である。

```ts
type CombatDecisionConsumerResult = {
  accepted: boolean
  branch: number
}
```

あるいは battle core の narrow API としては:

```ts
function consumeCombatDecisionInLocalOpener(
  playerIndex: number,
  localPath: number,
  candidate: Candidate | null,
  combatDecision: CombatDecision
): CombatDecisionConsumerResult
```

と持つのが current best reading に合う。

## 4. Relation To Existing `branch` API

既報の

```ts
const branch = decodeResolvedOutcome(player, outcomeLikeByte)
advanceActionPhase(player, branch)
```

という narrow API とは競合しない。

むしろ `combatDecision` は、
その `branch` を局所的に refine / gate する
さらに後段の accept-policy layer とみるほうが自然である。

つまり:

```ts
const branch = decodeResolvedOutcome(player, outcomeLikeByte)
const { accepted, branch: localBranch } =
  consumeCombatDecisionInLocalOpener(player, localPath, candidate, combatDecision)
```

のように、`combatDecision` は branch を上書きするというより
**accept-policy を経て local branch を具体化する layer**
に置くのが safest である。

## implication for step 6

この整理を採ると、step 6 で次に battle 本線から確認したいものは:

1. `combatDecision` first consumer が accept/reject を first output に持つか
2. その結果がどの local branch へ写るか

の順になる。

つまり current frontier は、
`branch first`
より
**`accepted first, branch second`**
にかなり寄っている。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. first consumer が boolean accepted に近い state を持つか
2. `07/08` candidate-selection path と special-candidate family gate が同じ accepted/branch consumer に流れ込むか
3. accepted=false が即 reject なのか、別の retry/alternate path を持つのか

ここが取れれば、`combatDecision` は
**accepted + branch**
という battle-core 実装にかなり近い形まで持っていける。
