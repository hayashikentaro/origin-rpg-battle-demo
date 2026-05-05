# SaGa2 Local-Action Opener Frontier Report

## Summary
- 既報の `611C -> 6157` handoff、`actors` queue loop、`D?43-46` action head、`443B-4499` RNG bridge を battle-side の時系列に並べ直すと、次に見るべき opener は **`6157` そのものではなく、その後に current player の local action resolve を開く actor-local queue/record consumer** にあるとみるのが最も自然である。
- この opener の中で最初に見える RNG は、今のところ **slot `07/08` を使う pointer-candidate builder (`443B-4499`)** であり、これは hit/damage の最終値より **candidate / pointer selection** に寄る。
- 同じ opener に対して `BattleActionHead(kindId, arg, target, slotIndex)` を重ねると、最初に効くのは page-wide field 全体より **`kindId/arg` による local path/class 選択**、`target/slotIndex` はその後段 routing として読むのが safest first line になる。

## 1. Where The Opener Should Sit

既報から battle-side の narrow flow は次のように置ける。

```ts
const outcomeLikeByte = commitResolvedSelection(seedByte) // 019E
const branch = decodeResolvedOutcome(playerIndex, outcomeLikeByte)
handoffToBattleApply(playerIndex, branch)                // 6157 boundary
openLocalActionResolve(playerIndex, branch, actionHead)  // next frontier
```

ここで `6157` は:

- `C200 <-> C7EE`
- `RST $08(E=$2C/$2D)`
- `D400/D500`

の大きい staging を含むが、
entry 契約として安全に前提できるのは
`player + local success-side state` までだった。

したがって、実際に `branch` と action meaning が初めて交わる frontier は、
`6157` 本体全体より
**その後に current player の local action path を開く actor-local consumer**
に置くほうが自然である。

## 2. Best Current Battle-Side Anchor

この consumer 候補として現在いちばん強いのは、
既報の `0D:4178` 以降の `actors ($D803)` queue loop である。

この loop では:

- `actors` を 2byte entry queue として走査する
- entry byte1 から `D0xx` actor page を選ぶ
- `D84D + 2*n` 系 controller work を引く
- `4361` state helper と `435A` aggregate gate を挟む
- 特別値 / pointer-like record を見ながら各 actor の local path を進める

したがって high level では、
`6157` 後段の branch/opener は
**round-global manager** より
**`actors` queue に乗った current actor の local resolve 開始点**
に吸収されるとみるほうが整合する。

## 3. First RNG Use Inside The Opener

この actor-local opener 帯で、
現時点の high-confidence RNG bridge は `443B-4499` だけである。

ここで見えているのは:

```ts
const basePointer = readPointerFromWorkRecord()
const hi = rng.next(0x07, 0x00, upperHi)
const lo = rng.next(0x08, 0x00, upperLo)
const offset = toSigned16(hi, lo)
const source = basePointer + offset
writePointerRecord(source)
```

重要なのは、
この RNG が今のところ

- final hit/miss
- final damage amount

ではなく、

- pointer candidate
- variant candidate
- source record candidate

の selection に寄っていることである。

したがって step 2 の「RNG slot 消費順」を今の evidence で押し上げるなら、
first-line conclusion は
**battle local opener の早い段で slot `07/08` が candidate-selection 系に消費される**
までに留めるのが安全である。

## 4. First ActionHead Use Inside The Opener

既報 `D?43-46` / `C1A5-C1AC` の暫定 struct:

```ts
type BattleActionHead = {
  kindId: number
  arg: number
  target: number
  slotIndex: number
}
```

をこの opener に重ねると、
最初に効く field の優先度は次のように置くのが自然。

1. `kindId`
2. `arg`
3. `target`
4. `slotIndex`

理由:

- `43FB-443A` prepass は 8byte action-class record の class bits を畳み込む
- `443B-4499` bridge は work record / pointer candidate を組む
- どちらもまず **action kind / class / parameter 側** の解釈を要する
- `target/slotIndex` は local path が開いた後の routing として一段後ろへ置ける

したがって step 3 を battle-side で詰める次の問いは、
`target` そのものより
**`kindId/arg` がどの local path/class 選択を開くか**
に置くのが安全である。

## 5. Practical Porting Boundary

ここまでを移植 API へ落とすと、
次の境界がかなり自然になる。

```ts
type BattleActionHead = {
  kindId: number
  arg: number
  target: number
  slotIndex: number
}

type ActionPhaseBranch = number

function openLocalActionResolve(
  playerIndex: number,
  branch: ActionPhaseBranch,
  action: BattleActionHead
): void
```

そしてこの `openLocalActionResolve(...)` の中で先に確定すべきなのは:

1. local path/class 選択 (`kindId`, `arg`)
2. candidate-selection RNG (`slot 07/08`)
3. 後段 routing (`target`, `slotIndex`)

という順になる。

## Implication
- `6157` 後段の本命 frontier は actor-local queue/record consumer にある
- first RNG use はいまのところ slot `07/08` の candidate-selection 系
- first ActionHead use は `target/slotIndex` より `kindId/arg` を優先して見るのが安全
