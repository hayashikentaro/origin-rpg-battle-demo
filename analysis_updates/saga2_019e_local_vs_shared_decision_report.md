# SaGa2 `019E` Local-vs-Shared Decision Report

## Summary
- 既存 evidence を `611C`, `0198/C2F6`, 4 層モデルで突き合わせると、`019E` の **最初の commit は local hidden 側** に置くほうが整合的で、shared `C2F6` 側はその後段反映として持つのが最も安全。
- 理由は、`019E` が見えているのが `611C` inner core の中だけであり、`611C` 自体が player-local seed/selection gate だからである。
- したがって今後の探索では、`019E -> direct C2F6 write` を初手に仮定するより、**`019E -> local hidden result`、その後別 phase で `C2F6` availability/presence へ反映** の順で追うのが false positive を減らしやすい。

## 1. The Competing Reads

`019E` の writeback 候補は大きく 2 つある。

1. local hidden commit  
   `611C` の current player に属する hidden seed/selection result
2. shared backing commit  
   `0198` が読む `C2F6` 系 optional-entry presence state

両方 plausible ではあるが、
同じ重さではない。

## 2. Why Local Comes First

### A. Caller locality

`019E` が高確度で見えている caller は:

```asm
6142: CALL $01B9
6145: LDH A,($FF8C)
614A: CALL $5F07
614D: LD HL,$C73D
6151: LD A,(HL)
6152: CALL $019E
6155: SCF
6156: RET
```

この chain は:

- `C20F + 16*player`
- `C73D..C744`
- `FF8C`
- `5F07`

という **player-local gate** の素材で閉じている。

したがって `019E` の最初の副作用先も、
まずはこの local gate と同じ側にあると考えるほうが自然。

### B. Layer boundary

4 層モデルでは:

1. `5F22`
2. `5E77`
3. `611C`
4. `6157`

で、`019E` は 3 層目、
`C200/C7EE/D400/D500` は 4 層目である。

この境界の見え方からしても、
`019E` は apply/staging より前の **candidate/selection 確定層**
にいる。

### C. `0198` role difference

`0198` は:

- `E=0` 固定
- `C2F6` 系を読む
- boolean-like predicate を返す

つまり shared optional-entry presence gate である。

一方 `019E` は:

- resolved seed byte を受け取る
- `611C` 成功直前の commit frontier にある

ので、性格が一段違う。

この差から、
`019E` がいきなり shared predicate backing を直接書くより、
**まず local commit を作り、それが後段で shared presence に効く**
とみるほうが収まりがよい。

## 3. When Shared Still Matters

shared `C2F6` 側が不要になるわけではない。

むしろ現在の最も自然な橋は:

```ts
localResult = commitResolvedSeedByte(seedByte)   // 019E
sharedOptionalState = derivePresence(localResult) // later phase / helper
```

という形である。

つまり `C2F6` は依然重要だが、
**`019E` の直受け先** というより
**`019E` 後段の reflected state**
として優先づけるのが安全。

## 4. Practical Search Rule

この判断を探索順へ落とすと、次はこうなる。

1. `019E` 近傍で local hidden writeback を探す  
2. それが見えたら、その値が later phase で `0198/C2F6` predicate にどう接続するかを見る  
3. local writeback が完全に外れたときだけ direct shared write 仮説を強める  

## Implication
- `019E` の first writeback は local hidden 側とみるのが自然
- `C2F6` はなお本命だが、`019E` の immediate target より downstream reflection として持つのが安全
- 次の主戦場は `611C` 内の local commit 観測である
