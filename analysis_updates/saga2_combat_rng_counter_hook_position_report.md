# SaGa2 Combat-RNG Counter-Hook Position Report

## Summary
- `41E6-41EC` の counter consume belt も、battle-side の意味順では **counter read (`41E6`) -> sentinel gate (`41E7-41E9`) -> consume/writeback (`41EB-41EC`)** に分けるのが自然である。
- この順序で見ると、raw/small-range RNG の本命 hook は `DEC/writeback` そのものより、**counter value を読んだあと、sentinel を見て consume 可否を分ける narrow gate** に寄ると考えるのが最も整合的になる。
- したがって次に battle 本線で最優先に疑うべき位置は、`41E6-41EC` 全体ではなく **`41E7-41E9` の sentinel gate に相当する local consume decision slot** である。

## 1. Three Micro-Phases Inside `41E6-41EC`

```text
41E6: LD A,(DE)
41E7: CP $FE
41E9: JR Z,$41ED
41EB: DEC A
41EC: LD (DE),A
```

この 4 命令は battle-side の意味として、
少なくとも次の 3 相に分けられる。

1. `41E6`  
   current local counter value の read
2. `41E7-41E9`  
   special/sentinel value による consume 可否 gate
3. `41EB-41EC`  
   consume 実行 (`DEC`) と writeback

## 2. Why The Hook Is More Likely Before `DEC`

もし combat RNG がこの belt に刺さるなら、
その役割は最も自然には:

- consume するか
- reroll するか
- local candidate を採用するか

の小判定になる。

この種の小判定は、
`DEC/writeback` のあとより
**consume 実行の前**
に置くほうが battle-side の意味順としてきれいである。

したがって first-line reading は:

```ts
const counter = readCounter(localEntry)
if (counter === 0xfe) goto skipConsume

const shouldConsume = unresolvedCombatRng(...)
if (shouldConsume) {
  writeCounter(counter - 1)
}
```

である。

## 3. Why The Sentinel Gate Is A Better Anchor Than The Read

`41E6` 単独はまだ単なる read であり、
その直後の `CP $FE ; JR Z` が
「ここで local consume policy が切り替わる」
ことを明示している。

このため、RNG hook の観測点としては:

- `41E6` の read より
- `41E7-41E9` の gate

のほうが battle-side の decision point に近い。

つまり次に疑うべきのは
counter storage そのものではなく、
**sentinel gate と consume 実行の間にあるはずの local decision slot**
である。

## 4. Practical Search Consequence

次の実探索順はさらにこう縮められる。

1. `41E7-41E9` 相当の local consume decision slot
2. `41EB-41EC` の直前後
3. `41E6` read 起点
4. `41D9-41E5` entry resolution

この整理により、次の battle/RNG 解析で探すべきものは
単なる raw/small-range callsite ではなく、
**local consume policy を決める micro-branch**
へ寄せてよい。

## 5. Porting Implication

step 6 に向けた内部 API も、
次のように一段具体化できる。

```ts
function resolveCombatRngAfterLocalPath(...): {
  shouldConsumeCounter: boolean
}
```

その後段で:

```ts
if (result.shouldConsumeCounter) {
  counter--
}
```

と置けるので、
combat RNG の first recovered meaning は
damage amount そのものより
**local consume/accept policy**
である可能性を first line に置ける。

## Implication
- `41E6-41EC` の本命 hook は `DEC/writeback` そのものではなく `sentinel gate -> consume policy` にある
- 次の battle/RNG 解析は `41E7-41E9` 相当の local decision slot を最優先で疑うべきである
- core 実装でも first recovered combat RNG meaning は `shouldConsumeCounter` 的な小判定として持つのが自然
