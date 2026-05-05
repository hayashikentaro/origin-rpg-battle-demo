# Saga2 Combat Decision Fallback Ranking Report

## 要点

- current best reading では、`accepted=false` の fallback は **alternate candidate path** より **strict path 残留** に一段重みを置くのが最も自然である
- 理由は、`0F + qualifier==0` だけが zero-fast-path privilege を持ち、`0E` や `0F + nonzero` は strict 側を通るという family 非対称性がすでに見えているからである
- したがって safest provisional ranking は  
  1. strict-path fallback  
  2. alternate-candidate fallback  
  となる

## 1. Why Strict Path Gets Priority

現在の family semantics では:

- `0F + 0` = fast-path
- `0E + 0` = strict allowed zero
- `0F + nonzero` = strict / slow-path 側
- `1` = blocked ordinal

という構造が見えている。

この構造は、
`accepted=false` が完全な別 candidate へ飛ぶというより
まず

- fast-path を取れない
- strict 側へ残る

と読むほうが自然である。

特に `0E` が常に strict path を通ることは、
fallback の first-line を strict 側に置く根拠として強い。

## 2. Why Alternate Candidate Still Remains

second line として alternate candidate path は残る。

理由は、
`D?12..` repeated candidate entry family 全体が
candidate list 的に見えており、
blocked current candidate のときに
別 entry を見る可能性がまだ十分残るからである。

ただし現時点の evidence では、
それを strict-path fallback より上に置くほどの直接証拠はない。

## 3. Safe Provisional Ranking

現時点の safest ranking は次の通り。

1. strict-path fallback  
   zero-fast-path を閉じて strict/slow path に残る
2. alternate-candidate fallback  
   current candidate を捨てて別 local candidate を試す

この順に置くと、
`0E/0F` family の非対称性を最小仮説で説明しやすい。

## provisional API reading

現時点では次のような fallback flavor を持つのが安全である。

```ts
type CombatDecisionConsumerResult = {
  accepted: boolean
  branch: number
  fallbackKind?: "strict-path" | "alternate-candidate-path"
}
```

そして current best bias は:

```ts
fallbackKind = "strict-path"
```

を first line、
`"alternate-candidate-path"` を second line に置く形である。

## implication for `combatDecision`

この整理を採ると、`combatDecision` の false 側は
単なる reject ではなく、

- shortcut denied
- strict path retained

という local opener 内の path refinement として扱える。

つまり `combatDecision` は
**accept/fallback branch opener**
である、という既報ともかなりよく噛み合う。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `accepted=false` のとき consume belt (`41D9-41EC`) を完全に回避するか
2. `0E + 0` と `0F + nonzero` が同じ strict-path fallback に流れるか
3. blocked ordinal (`qualifier==1`) が strict-path fallback ではなく alternate-candidate fallback を開く場合があるか

ここが取れれば、`combatDecision` は
**accepted + branch + fallbackKind**
としてかなり実装寄りに固められる。
