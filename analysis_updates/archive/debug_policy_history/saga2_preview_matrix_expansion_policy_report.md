# saga2 preview matrix expansion policy

## Summary

- current operational contract が固まったので、次の自然な implementation step は **preview matrix coverage expansion** である
- ただしこの拡張は semantic discovery を広げるためではなく、**deferred-binding contract を壊さずに shape/ordering をより多くの command class で検証する** ために行うのが safest である
- したがって優先すべき観測点は raw numeric binding の違いではなく、**lane / route / provenance / terminal** の flow が保たれるかどうかである

## Expansion goal

preview matrix の next goal は、

- more commands
- same 5-layer contract
- no premature numeric binding

の 3 点を同時に満たすことである。

言い換えると、今増やすべきなのは command variety であって、field semantics の再設計ではない。

## A-rank coverage targets

### 1. Ability class diversity

いまの `ABL...` preview は存在するが、次に価値が高いのは

- same `kindId` family with different `arg`
- different `kindId` families that still stay within the same actor-local bridge

を見比べることである。

**Why first**  
`branch` / `localPath` / `pointerFlavor` の shape が command class を跨いで崩れないかを、最小コストで見られる。

### 2. Target-mode diversity

- explicit target
- slotIndex fallback
- candidate target

の 3 種を matrix 上で並べ続ける。

**Why first**  
current 5-layer contract では `target` は downstream terminal なので、upstream fields が同じでも terminal だけが違うケースを見やすい。

### 3. PTR retention cases

`PTR` は current frontier で最も semantic value が高い probe なので、

- `PTR`-like candidate path
- non-`PTR` shared path

の両方を matrix 上で常に残すのが安全である。

**Why first**  
deferred-binding policy の regression は PTR path に最も出やすい。

## B-rank coverage targets

### 4. Accepted-side diversity

current snapshots は `accepted=false` bias が強いので、もし actor-local skeleton で `accepted=true` 的なケースを増やせるなら有益である。

**Why later**  
shape contract 自体は already stable なので、accepted-side diversity は expansion としては価値が高いが必須ではない。

### 5. Ability count scaling

ability 数が多い actor でも、

- matrix ordering
- debug formatting
- trace readability

が崩れないかを見る。

**Why later**  
これは semantic sharpening より operational robustness の問題だからである。

## Explicit NO-GO during expansion

preview matrix を広げるときに、次はまだ避けるのが safest である。

- raw `branchVariant 0|1` ごとに semantic labels を分ける
- matrix 表示で `0 == shared` のような binding を匂わせる
- `pointerFlavor` を raw numeric から直接説明する

つまり expansion は **coverage widening**, not **binding commitment** である。

## Practical reading

したがって current safest preview expansion policy は、

**broaden command and target coverage while keeping the same deferred-binding 5-layer contract visible and unchanged.**

である。
