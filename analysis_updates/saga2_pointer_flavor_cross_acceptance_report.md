# Saga2 PointerFlavor Cross-Acceptance Report

## 要点

- current best reading では、`pointerFlavor="candidate"` の **strict-side alignment** は `accepted=false` 側だけの性質ではなく、**`accepted=true` 側でも同じ向きのまま保たれる** とみるのが最も自然である
- したがって `pointerFlavor="candidate"` は false 側では strict fallback provenance reopening、true 側では admitted-path provenance reopening と読まれるが、**strict-leaning direction 自体は shared** とみるのが safest である
- このため `branchVariant` と `pointerFlavor="candidate"` の接続も、`accepted` によって向きが変わるのではなく、**same polarity, different control-flow role** として持つのが battle-side evidence に最も合う

## 1. Why The Alignment Should Survive `accepted`

既報では:

- `accepted=false`
  = current consume path denied
- `accepted=true`
  = current consume path admitted
- `branchVariant`
  = strict-side polarity を shared に持つ

と整理している。

この前提を second-line の
`pointerFlavor="candidate"`
へ延長すると、
`accepted`
が変えるのは reopening の control-flow role であって、
candidate provenance が持つ strict-side alignment そのものではない
と読むのが最も自然になる。

つまり safest reading は:

- false 側: strict fallback provenance reopening
- true 側: strict admitted-path provenance reopening

である。

## 2. Why A Polarity Flip Would Be Unnatural

もし `accepted=true`
になると
`pointerFlavor="candidate"`
の alignment 自体が反転するなら、

- first-line `branchVariant`
- second-line `pointerFlavor`

の接続を同じ field shape のまま保つのが難しくなる。

また既報では
`target`
は `pointerFlavor`
の downstream result として読むのが current best であるため、
second-line の中心 field が true/false で polarity reversal を起こすと
downstream semantics まで不必要に不安定になる。

したがって safest bias は、
**alignment is preserved; role changes**
である。

## 3. Relation To `branchVariant`

既報 `strict-polarity cross-acceptance`
では、
`branchVariant`
自体も

- false 側では fallback refinement
- true 側では activation refinement

と読みつつ、
strict-side polarity は shared で保つ、
と整理している。

この前提をそのまま second-line へ延長すると、
`pointerFlavor="candidate"`
も

- false 側では fallback-side provenance reopening
- true 側では admitted-path provenance reopening

と読める一方、
strict-side alignment 自体は shared でよい。

つまり first-line / second-line ともに
**same polarity, different role**
でそろうのが current best reading である。

## 4. Relation To `target`

既報では `target`
は `pointerFlavor`
の downstream result と読むのが safest である。

このため `pointerFlavor="candidate"`
の alignment が true/false で共有されるなら、
final `target`
差分も

- false 側では fallback downstream
- true 側では admitted downstream

として読み分ければ足り、
target 側に別の polarity system を導入する必要がない。

この点でも shared alignment 読みのほうが自然である。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
pointerFlavor === "candidate"
```

は:

```ts
strict-leaning candidate provenance reopening
```

であり、

```ts
if (accepted) {
  // admitted-path reopening
} else {
  // fallback-side reopening
}
```

という reader-side role だけが変わる、
とみるのが current best である。

## implication for step 6

この整理を採ると、
step 6 の provisional API は second-line でも field を増やさずに semantics を強められる。

- `pointerFlavor` は `"shared" | "candidate"` のまま
- `accepted` は second-line でも role を分ける
- strict-side alignment は shared に保つ

で十分だからである。

つまり next analysis / next implementation でも、
`pointerFlavor="candidate"`
を true/false で別 class に分けるより、
**same alignment, different role**
として扱うのが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `pointerFlavor="shared"` 側も true/false をまたいで fast/default alignment を保つか
2. final `target` 差分が true/false の両側で同じ alignment downstream として説明できるか
3. `branch` 自体も same polarity family として first-line / second-line をまたいで保てるか

ここが取れれば、first-line と second-line の field-level semantics はかなり recovered semantics に近づく。
