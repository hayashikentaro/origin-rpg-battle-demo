# SaGa2 Combat-RNG Extension Frontier Report

## Summary
- 現時点の evidence をそのまま TypeScript core へ落とすなら、`resolveActorCommand(input)` の内部で確定している RNG は **slot `07/08` の candidate-selection 系だけ** と扱い、hit/damage/order 系は **別 frontier の extension point** として残すのが最も正確である。
- これは「未解析だから後回し」という弱い意味ではなく、既報の static evidence が **`07/08 != damage core`**, **`33 != damage core`**, **pass21-23 に `016B/043E` 未検出** をはっきり示しているためである。
- したがって step 6 に向けた first-version core は、candidate-selection RNG を実装しつつ、combat RNG 本体は `resolveCombatRng(...)` などの未確定 hook として分離しておくのが安全になる。

## 1. What Is Already Separated

既報から high-confidence に分けられるもの:

1. slot `33`  
   particle/effect 側
2. slot `07/08`  
   pointer / candidate / variant selection 側
3. damage core RNG  
   まだ別 frontier

この 3 分離は、
単なる「仮の整理」ではなく
既知 callsite の用途差に基づく battle-side separation である。

## 2. Why `07/08` Should Not Be Promoted Further Yet

slot `07/08` については、
既報 `443B-4499` がかなり具体的だった。

```ts
const hi = rng.next(0x07, 0x00, upperHi)
const lo = rng.next(0x08, 0x00, upperLo)
const candidateOffset = toSigned16(hi, lo)
```

ここで作っているのは:

- final hit chance
- final damage spread

ではなく、

- candidate pointer
- source/variant record

の selection である。

したがって first-version core では、
これを **candidate-selection RNG**
として限定して実装するのが安全である。

## 3. Why Combat RNG Must Stay Open

既報 `saga2_rng_damage_core_gap_report.md` から、
pass21-23 の damage 主線候補には `016B/043E` が出ていない。

これはつまり:

- final writeback chain
- expanded upstream block

のどちらからも
**known RNG bridge が damage 本体へつながっていない**
ことを意味する。

この状況では、
`07/08` の直後に hit/damage RNG を置くのは evidence overreach になる。

よって safer reading は:

```ts
const candidate = maybeBuildCandidateWithRng07_08(...)
const combatRng = unresolvedCombatRngFrontier(...)
```

である。

## 4. Safe First-Version Internal Shape

step 6 に向けて、TypeScript 側の first version は
次の internal shape で持つのが自然。

```ts
function resolveActorCommand(
  input: BattleCommandInput
): ActorResolveResult {
  const branch = decodeResolvedOutcome(input.actorIndex, input.outcomeLikeByte)

  const localPath = selectLocalActionPath(
    input.action.kindId,
    input.action.arg
  )

  const candidate =
    pathNeedsCandidateSelection(localPath)
      ? buildPointerCandidateWithRng07_08(...)
      : null

  const routedTarget = routeTarget(
    input.action.target,
    input.action.slotIndex,
    candidate
  )

  // unresolved frontier:
  // const combatOutcome = resolveCombatRng(localPath, candidate, ...)

  return {
    actorIndex: input.actorIndex,
    branch,
    target: routedTarget,
    didConsumeCandidateRng: candidate !== null,
  }
}
```

この段階では、
`resolveCombatRng(...)` を placeholder にしておくのが
いちばん正確である。

## 5. What To Search Next

この整理で、次の解析 target はさらに明確になる。

1. `kindId/arg` が開く `localPath` の類型化  
2. `localPath` ごとに `07/08` candidate-selection を使うかどうか  
3. その後段で初めて現れる **combat RNG 本体の別 slot/frontier**  

つまり battle/RNG 解析の次の本丸は、
**candidate-selection RNG の精密化** ではなく
**combat RNG frontier の新規発見**
である。

## Implication
- first-version core は `07/08` を candidate-selection 専用で実装してよい
- hit/damage/order 系 RNG は別 frontier として extension point に落とすのが安全
- 次の battle/RNG 解析は `07/08` の続きを追うより `combat RNG` の新しい入口を探すべきである
