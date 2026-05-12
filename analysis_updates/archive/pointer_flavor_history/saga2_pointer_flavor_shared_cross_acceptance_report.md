# Saga2 PointerFlavor Shared Cross-Acceptance Report

## 要点

- current best reading では、`pointerFlavor="shared"` も `accepted=false` / `accepted=true` をまたいで **same fast/default alignment** を保つとみるのが最も自然である
- したがって `"shared"` は false 側では default fallback provenance reopening、true 側では default admitted-path provenance reopening と読まれるが、**fast/default direction 自体は shared** とみるのが safest である
- このため second-line の 2 値は current best reading ではかなり対称であり、  
  - `"candidate"` = strict-side aligned provenance reopening  
  - `"shared"` = fast/default aligned provenance reopening  
  と読むのが battle-side evidence に最もよく合う

## 1. Why `"shared"` Should Also Survive `accepted`

既報では:

- `"candidate"` 側は strict-side alignment を `accepted` をまたいで保つ
- `branchVariant` 自体も same polarity, different role と読む

まで整理している。

この前提を second-line 2 値全体に拡張すると、
対になる `"shared"` 側も同様に
`accepted`
をまたいで alignment を保つとみるのが最も軽い。

つまり safest reading は:

- false 側: default fallback provenance reopening
- true 側: default admitted-path provenance reopening

である。

## 2. Why This Is Better Than Making `"shared"` A Role-Only Bucket

もし `"shared"`
を true/false で毎回別 meaning に作り替えるなら、
second-line の 2 値は

- `"candidate"` = stable class
- `"shared"` = unstable residual role bucket

となってしまい、
既報の provenance-class reading と噛み合いにくい。

いっぽう shared alignment を採ると、
`pointerFlavor`
全体を
**provenance class pair**
としてかなり綺麗に保てる。

このため safest bias は、
`"shared"` も
true/false で role は変わっても alignment は保つ、
というものである。

## 3. Symmetry With `"candidate"`

既報では `"candidate"` 側を

- false 側: strict fallback provenance reopening
- true 側: admitted-path provenance reopening

と読みつつ、
strict-side alignment は shared に保つ、
と整理している。

この対称として `"shared"` 側も:

- false 側: default fallback provenance reopening
- true 側: default admitted-path provenance reopening

と読める。

すると current best 2 値対称性は:

```ts
"candidate" => strict-side aligned provenance
"shared"    => fast/default aligned provenance
```

となり、
shape と semantics の両方が非常に軽くなる。

## 4. Relation To `target`

既報では final `target`
は `pointerFlavor`
の downstream result と読むのが safest である。

このため `"shared"`
側が cross-acceptance でも same alignment を保つなら、
target 側も

- false 側では default fallback downstream
- true 側では default admitted downstream

として読めば足りる。

つまり final target 差分に別の polarity system を作らず、
`pointerFlavor`
の class downstream としてまとめられるのが利点である。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
pointerFlavor === "shared"
```

は:

```ts
fast/default aligned provenance reopening
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
step 6 の provisional API では second-line の 2 値を非常に対称に保てる。

- `"candidate"` = strict-side aligned
- `"shared"` = fast/default aligned
- `accepted` = role only

で十分だからである。

つまり next analysis / next implementation でも、
`pointerFlavor`
を true/false ごとに別 enum に分ける必要はなく、
**same alignment, different role**
の原則でかなり先まで進められる。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. final `target` 差分が `"shared"` / `"candidate"` の alignment pair だけでどこまで説明できるか
2. `branch` 自体も同じく shared family / strict family の対として読めるか
3. `postBranchRoute` が true/false をまたいでこの pair alignment を保つか

ここが取れれば、second-line の 2 値 semantics はかなり recovered semantics に近づく。
