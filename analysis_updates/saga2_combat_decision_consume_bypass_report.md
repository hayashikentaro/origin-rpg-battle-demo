# Saga2 Combat Decision Consume-Bypass Report

## 要点

- current best reading では、`accepted=false` のときは **`41D9-41EC` の deterministic consume belt をかなり高い確率で回避する** とみるのが最も自然である
- 理由は、current `combatDecision` が「consume path そのもの」ではなく **その path へ入る gate** に対応づけられており、false 側は strict/alternate local fallback を開くと読むほうが既報と整合するからである
- したがって safest provisional reading は、`accepted=false` を **consume-bypass + local fallback** として持つことである

## 1. Why Bypass Gets Priority

既報 `41D9-41EC` microflow は:

1. entry / record pointer resolution
2. counter read + sentinel gate
3. deterministic `DEC/writeback`

に分かれていた。

しかも `combatDecision` は current best reading では、
この belt の内部ではなく
**そこへ入る pre-gate**
に対応づけられている。

このため `accepted=false` を読む first consumer は、
まず

- consume belt に入らない

とみるのが自然である。

## 2. Why This Fits Strict Fallback

既報 fallback ranking では、false 側の first line は

- strict-path fallback

だった。

strict path に残る読みと
consume belt 回避は矛盾しない。

むしろ、

- privileged / shortcut consume を行わない
- stricter local path へ戻る

という組として持つと、
`0F` zero-fast-path privilege と `0E` strict path の非対称性を
かなり自然に説明できる。

## 3. Why Not “Still Consume Anyway”

second line としては、
false 側でも別 belt や別 counter を使う可能性は残る。

ただし現時点の evidence では、
同じ `41D9-41EC` consume belt にそのまま入るなら
`accepted=false` の意味が薄くなる。

したがって safest reading は、

- `accepted=true`  
  current candidate / current special path の consume belt へ進む
- `accepted=false`  
  その belt は回避し、strict/alternate local path へ落ちる

である。

## provisional API reading

現時点では次のような shape を first line に置くのが安全である。

```ts
type CombatDecisionConsumerResult = {
  accepted: boolean
  branch: number
  fallbackKind?: "strict-path" | "alternate-candidate-path"
  bypassesCurrentConsumeBelt?: boolean
}
```

そして current best bias は:

```ts
accepted === false
bypassesCurrentConsumeBelt === true
fallbackKind === "strict-path"
```

である。

## implication for `combatDecision`

この整理を採ると、`combatDecision` は

- accept / reject
- fallback kind
- consume-belt bypass

を背後に持つ local opener policy としてかなり具体化できる。

つまり `combatDecision` の first consumer は、
単なる boolean reader ではなく
**current candidate consume path を開くか回避するかを決める branch opener**
とみるのが最も自然になる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. false 側が strict path fallback のときに別 counter path を持つか
2. blocked ordinal (`qualifier==1`) と nonzero class が同じ bypass/fallback を共有するか
3. `07/08` candidate-selection path の false 側も同じ consume-bypass 形に乗るか

ここが取れれば、`combatDecision` は
**accepted + branch + fallbackKind + consumeBypass**
までかなり実装寄りに持っていける。
