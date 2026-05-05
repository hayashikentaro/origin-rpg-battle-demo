# SaGa2 Combat-RNG Priority-Window Report

## Summary
- `actors` loop と state helper 群を battle-side の時系列で重ねると、次に `combat RNG` を探す優先 window は **round-level state `06/07` より、actor-local processing 中の state `04/05` 周辺** に置くのが最も自然である。
- 理由は、`06/07` が queue 全体走査後の aggregate gate に見えるのに対し、`04/05` は current actor page / pointer candidate / local path 検証の直前直後に出ているため、hit/target/damage のような per-actor combat RNG と近いからである。
- したがって next pass では、`actors` loop の **`41A4-41F1` 帯** を combat-RNG priority window として扱い、その近傍で `07/08` 以外の raw/small-range RNG callsite を探すのが安全になる。

## 1. Why `06/07` Is Lower Priority

既報 `actors` loop では、
`06/07` は queue 全走査後に:

- `HL=$D001`
- `B=5`, `B=3` の page-aggregate
- `CALL $435A`
- `CALL $4361`

という流れで使われていた。

これは high level では:

- round aggregate
- actor-side summary gate
- queue-level transition

に近く、
per-actor hit/damage RNG より一段外側に見える。

したがって `06/07` 周辺は
combat RNG の first search target としては優先度を下げてよい。

## 2. Why `04/05` Is Closer

いっぽう `04/05` は、
`actors` loop 中盤で current actor page を読んだ直後に現れる。

```text
419A: LD A,(DE)
...
41A4: BIT 3,C
41A6: JR Z,$41B0
41A8: ... LD A,$04 ; CALL $4361
41B0: ... LD A,$05 ; CALL $4361
41B9: INC E
41BC: LD A,(DE)   ; pointer-like pair read
...
41C4-41EC: sentinel / record / countdown-like checks
```

この位置関係から、
`04/05` は:

- current actor / current action
- local pointer/record candidate
- actor-local next path

にかなり近い。

つまり `resolveCombatRng(...)` に相当する hook を探すなら、
`06/07` より
**`04/05` の後段 local branch**
を first line に置くのが自然である。

## 3. Best Priority Window

現時点で最も有力な search window は次の帯。

```text
41A4-41B4  state 04/05 dispatch
41B9-41C3  pointer-like pair read
41C4-41EC  sentinel / candidate / countdown-like handling
41F1-4205  post-local gate
```

この帯は:

1. actor-local である  
2. queue entry をすでに current actor に解決済み  
3. `443B-4499` の candidate-selection と近い意味域にある  
4. `06/07` aggregate gate より前にある  

ので、combat RNG を探す最初の narrow window としてかなり整合的である。

## 4. Search Rule Refinement

前回の rule をもう一段絞ると、
次に優先する callsite は次を満たすものになる。

```ts
isPriorityCombatRngCandidate(callsite) =
  isNearActorsLoopState04or05(callsite) &&
  isAfterActorPageResolution(callsite) &&
  !isSlot07or08CandidateBuilder(callsite) &&
  requestsRawOrSmallRange(callsite)
```

ここで `requestsRawOrSmallRange` は:

- `DE=$FF00`
- `DE=$0300`
- `DE=$0F00`
- `DE=$0100`

を first line に見る。

## 5. Porting Implication

step 6 に向けては、
`resolveCombatRng(...)` placeholder も battle-side の位置づけを
もう少し具体化できる。

```ts
function resolveCombatRngAfterLocalPath(
  playerIndex: number,
  localPath: number,
  candidate: unknown,
  routedTarget: number
): unknown
```

つまり、
これは `branch decode` 直後ではなく
**state `04/05` 相当の actor-local processing 後段**
に置くのが自然、ということになる。

## Implication
- combat RNG の次の本命観測点は state `06/07` ではなく actor-local state `04/05` 周辺
- 優先 window は `41A4-41F1` 帯の local pointer/record handling
- 次の battle/RNG 解析はこの narrow window で raw/small-range RNG callsite を探すべきである
