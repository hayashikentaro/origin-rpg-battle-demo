# SaGa2 Combat-RNG Search Targets Report

## Summary
- 既報の battle-side 時系列を前提にすると、次に探すべき `combat RNG frontier` は **`6157` より後・`443B-4499` より別・`damage writeback` より前** の狭い帯にある。
- その観測点として最も有力なのは、**`actors` queue を 1 actor ずつ処理する local opener のうち、`kindId/arg` で path を開いたあと、`target/slotIndex` routing や final writeback に落ちる前の小分岐帯** である。
- したがって next pass では、`07/08` の続きを掘るより、**actor-local opener 内で raw/small-range RNG (`FF00`, `0300`, `0F00`, `0100`) を要求する別 callsite** を本命にして探すのが筋がよい。

## 1. What Is Already Excluded

現時点で除外度が高い場所は次の通り。

1. `6157` 以前  
   ここは `019E -> branch` の handoff 層
2. `443B-4499`  
   candidate-selection 専用の slot `07/08`
3. particle 側 slot `33`
4. pass21-23 の final damage/writeback 側

したがって combat RNG は、
**branch/handoff と final writeback の中間**
にあるはずだと見るのが自然である。

## 2. Best Current Search Window

battle-side の safest high-level flow は次の形で持てる。

```ts
const branch = decodeResolvedOutcome(player, outcomeLikeByte)
const localPath = selectLocalActionPath(kindId, arg)
const candidate = maybeBuildCandidateWithRng07_08(localPath)
const routedTarget = routeTarget(target, slotIndex, candidate)
const combatOutcome = resolveCombatRng(...) // next frontier
```

この `resolveCombatRng(...)` に相当する narrow window は、
いまのところ次の条件を満たす箇所として探すのがよい。

1. actor-local opener の内側  
2. `kindId/arg` 解釈のあと  
3. `07/08` candidate-selection とは別  
4. `target/slotIndex` または writeback の直前  

## 3. What Sort Of RNG Calls To Prioritize

既報 `043E` callsite 契約から、
combat RNG の候補として優先して見るべきなのは
次のレンジ要求を持つ callsite である。

- `DE=$FF00`  
  raw 0..255
- `DE=$0300`  
  0..3
- `DE=$0F00`  
  0..15
- `DE=$0100`  
  0..1

理由:

- hit / miss なら binary (`0100`) や raw compare (`FF00`) が自然
- damage spread / nibble variation なら `0300` や `0F00` が自然
- 既知の `07/08` は upper-bound-by-record 型で形が違う

したがって次の search target は、
**battle local opener 近傍で `07/08` 以外の small-range/raw RNG call を持つ帯**
に絞るのが安全である。

## 4. Best Battle-Side Anchors

既報から、観測の anchor として優先すべき帯は次の順になる。

1. `0D:4178+` actors queue loop の各分岐先  
2. `4361` で state `04/05/06/07` を出した直後の local path  
3. `41BC-41EC` の pointer/record 検証後に続く actor-local branch  
4. `01E3` / `dispatch` の後段で action meaning が固まる帯  

逆に、

- `40E6` の round-level 初期化
- `6157` の page-wide staging
- `443B-4499` の candidate builder

は search anchor として一段優先度を下げてよい。

## 5. Practical Search Rule

次の解析では、`CALL $016B` を見つけたら全部拾うのではなく、
まず次の rule でふるいにかけるのがよい。

```ts
isCombatRngCandidate(callsite) =
  isInsideActorLocalOpener(callsite) &&
  !isSlot07or08CandidateBuilder(callsite) &&
  !isParticleCallsite(callsite) &&
  requestsRawOrSmallRange(callsite)
```

この rule なら false positive をかなり減らせる。

## 6. Porting Implication

step 6 に向けた意味は明快で、
first-version core に置く placeholder は
単なる TODO ではなく、

```ts
resolveCombatRng(localPath, routedTarget, ...)
```

という **actor-local post-candidate / pre-writeback hook**
としてかなり具体化できる。

つまり次に必要なのは、
この hook の中身を battle 本線から 1 本見つけることである。

## Implication
- combat RNG frontier は `6157` 後段の actor-local opener 内にあるとみるのが最も自然
- 優先して探すべきは `07/08` ではない raw/small-range RNG callsite
- 次の battle/RNG 解析は `actors` loop 分岐先を anchor にして combat RNG hook を探すべきである
