# SaGa2 Step4/Step5 API Frontier Report

## Summary
- `019E -> 6157 -> branch` の narrow bridge と、既報の `D?43-46` / `C1A5-C1AC` descriptor 線を重ねると、移植に必要な **step 4 (RNG slot order)** と **step 5 (action descriptor struct)** はかなりきれいに分離して持てる。
- 具体的には、step 5 側は **`BattleActionHead` を先に固定** し、step 4 側は **その head と `branch` を最初に同時に読む actor-local consumer の中で RNG slot 消費順を確定する**、という順に置くのが最も安全である。
- したがって現在の frontier は「descriptor の完全確定待ち」ではなく、**`player + branch + actionHead` を受ける local action resolve opener** にかなり狭まっている。

## 1. What Step 5 Is Stable Enough To Hold Now

既報 `saga2_battle_descriptor_field_mapping_report.md` から、
`D?43/44/45/46` は現時点でも移植用の暫定 struct として十分持てる。

最も安全な形は:

```ts
type BattleActionHead = {
  kindId: number
  arg: number
  target: number
  slotIndex: number
}
```

対応は次の読みを first line に置ける。

- `kindId`   <- `D?43` / `C1A5`
- `arg`      <- `D?44` / `C1A6`
- `target`   <- `D?45` / `C1A7` 寄り
- `slotIndex`<- `D?46`

ここで `arg` だけは rename 余地を残すが、
**battle core に渡す head struct としてはすでに十分実用的** である。

## 2. What Step 4 Still Needs

いっぽう RNG slot 消費順は、
prepass / selector / visible staging を広く見るより、
次の狭い場所で確定すべきである。

1. `019E` が success-side local outcomeLikeByte を確定する
2. `6157` がそれを player-scoped に relay する
3. local consumer が `branch` を開く
4. **その consumer が `actionHead` と `branch` を見て初めて RNG slot を消費する**

つまり step 4 の主戦場は、
`043E` caller を battle 全域で再探索することではなく、
**`player + branch + actionHead` の narrow consumer 内で slot usage を拾うこと**
へかなり絞れている。

## 3. Combined Porting Boundary

現在の safest porting boundary は次のように書ける。

```ts
type OutcomeLikeByte = number
type ActionPhaseBranch = number

function decodeResolvedOutcome(
  playerIndex: number,
  outcomeLikeByte: OutcomeLikeByte
): ActionPhaseBranch

function openLocalActionResolve(
  playerIndex: number,
  branch: ActionPhaseBranch,
  action: BattleActionHead
): void
```

この `openLocalActionResolve(...)` の内側が、
RNG slot 消費順を確定すべき最小領域である。

## 4. Why This Helps

この切り方の利点は 3 つある。

1. `descriptor struct` を今の evidence で先に API 化できる  
2. `RNG slot order` を battle 全域ではなく local opener に閉じ込められる  
3. Godot 側から渡す入力形を、RAM page 完全再現前に先に固定できる  

つまり step 4 と step 5 を同時に進めるときも、
「全部を一度に確定する」必要がなくなる。

## 5. Best Current Search Target

次に本命として追うべきものは:

1. `6157` 後段で `branch` を最初に読む actor-local opener
2. その opener が `D?43-46` / `C1A5-C1AC` 相当の head をどう使うか
3. その内部で最初に `043E` slot 消費が現れるか

この順に取れれば、
step 4 と step 5 はほぼ同じ観測点で前進できる。

## Implication
- step 5 側は `BattleActionHead(kindId, arg, target, slotIndex)` を first-line struct として先に持てる
- step 4 側は RNG slot 消費順を actor-local opener 内へ狭めて探索できる
- 次の主戦場は `player + branch + actionHead` を受ける local action resolve opener である
