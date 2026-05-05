# Saga2 Debug Command Matrix Report

## 要点

- current actor-local bridge では、Godot front から provisional な command matrix を直接観測できる
- 現在の matrix は少なくとも次の 4 系統を持つ
  - `ATK`
  - `DEF`
  - `PTR`
  - `ABL{index}`
- このうち `PTR` は debug 専用 probe で、slot `07/08` candidate-selection path を強制的に踏ませるための観測点である

## 観測できる値

各 preview は現時点で少なくとも次を返す。

- `branch`
- `localPath`
- `target`
- `targetSource`
- `didConsumeCandidateRng`
- `candidateOffset`
- `action`
- `combatDecision`
- `debugTrace`

特に `targetSource` は battle/RNG 仮説の切り分けに有用で、現状の matrix では次の 3 分類を front から直接確認できる。

- `explicit`
- `candidate`
- `slotIndex`

## 各 preview の役割

### `ATK`

- first-line の attack skeleton
- 現状では candidate path を踏まず、`slotIndex` fallback 系の軽い local path を観測する用途に向く

### `DEF`

- explicit target routing を持つ最小 command
- branch/path と target routing の explicit 側を観測する用途に向く

### `PTR`

- debug 専用 pointer/candidate probe
- `kindId=0x01, arg=0, target=0xFF` を使い、`pathNeedsCandidateSelection(...)` が真になる local path を選ぶ
- 現在の skeleton では、この preview が slot `07/08` を踏む経路を front と self-check の両方で固定している

### `ABL{index}`

- `arg/slotIndex` に ability index を乗せる preview
- `kindId/arg -> localPath` の差分を一覧観測する用途に向く

## self-check で固定したこと

TypeScript core 側 self-check では、少なくとも `PTR` probe について次を固定している。

- `localPath === 16`
- `didConsumeCandidateRng === true`
- `targetSource === "candidate"`
- `candidateOffset` が存在する
- `debugTrace` に `candidate rng 07/08` ステップが現れる

つまり slot `07/08` candidate-selection skeleton は、front 表示だけでなく core contract としても最低限固定された状態にある。

## 位置づけ

この debug command matrix は battle semantics の完成版ではなく、step 6 skeleton の **観測レイヤ** である。

- `ATK/DEF/ABL` は action-head to local-path の差分観測
- `PTR` は slot `07/08` candidate path の強制観測
- `combatDecision` は unresolved hook のまま保持

したがって次の本丸は、この matrix を増やすこと自体ではなく、依然 unresolved な `combatDecision` を ROM 側 evidence で押し上げることにある。

## 次の確認点

次の battle/RNG 解析で本当に重要なのは引き続き次の 2 点である。

1. `41E7-41E9` 相当の local decision slot に raw/small-range RNG が入るか
2. その返り値が `41EB-41EC` の consume/writeback 可否へつながるか

ここが取れれば、現在の debug matrix に見えている `combatDecision` を stub から first recovered combat semantics に上げられる。
