# Saga2 Strict-Polarity Cross-Acceptance Report

## 要点

- current best reading では、`branchVariant` の **strict-side polarity** は `accepted=false` 側だけの性質ではなく、**`accepted=true` 側でも同じ向きのまま保たれる** とみるのが最も自然である
- 違うのは polarity の向きではなく consumer position であり、  
  - `accepted=false` では strict fallback refinement  
  - `accepted=true` では admitted-path refinement  
  と読まれる
- したがって safest reading は、`branchVariant` の 0/1 が shared な polarity value を持ち、`accepted` はその value を **fallback と activation のどちらとして読むか** を決めるだけだ、というものである

## 1. Why The Polarity Should Stay Shared Across `accepted`

既報では:

- `accepted=false`
  = current consume path denied
- `accepted=true`
  = current consume path admitted

と読んでいる。

また `branchVariant`
については、

- current best primary axis = `0E/0F` family difference
- blocked ordinal shadow = strict-side polarity へ寄る

と整理してきた。

この前提を採ると、
`accepted`
の違いは path の opening position を変えるだけで、
`branchVariant`
が持つ strict/non-fast-path 側の polarity そのものを反転させる理由は薄い。

したがって safest reading は、
**strict-side polarity is shared; consumer role changes**
である。

## 2. Why `accepted=false` And `accepted=true` Still Read Differently

shared polarity を採ることは、
true/false の意味が全く同じだという主張ではない。

current best reading は次のようになる。

- `accepted=false`
  - current consume path denied
  - strict-side polarity は fallback branch refinement として読む
- `accepted=true`
  - current consume path admitted
  - strict-side polarity は admitted-path branch refinement として読む

つまり field value と polarity direction は shared だが、
consumer が置かれている control-flow position が違うため、
reader-side meaning が変わる。

この構図は既報 `branch shared-value bias`
ともよく整合する。

## 3. Why This Fits Better Than A True/False-Specific Polarity Flip

もし `accepted=true`
になると strict-side polarity 自体が反転するなら、

- same `branchVariant` value
- same PTR-only field
- same second-line carry

を保ちながら、
reader が毎回 polarity table を裏返す必要が出る。

しかし current best evidence では、
必要なのは polarity reversal ではなく、
**same polarity, different control-flow role**
のほうで十分である。

このため safest bias は、
true/false で polarity を変えるより
consumer position だけを変えることである。

## 4. Relation To `pointerFlavor="candidate"`

既報では
`pointerFlavor="candidate"`
は strict-side aligned candidate provenance reopening
と読むのが current best である。

この前提を採ると、
もし `accepted=true`
で polarity が反転してしまうなら、
first-line と second-line の alignment が崩れる。

いっぽう shared polarity を採れば、

- false 側では strict fallback reopening
- true 側では strict admitted-path reopening

と読めるので、
`pointerFlavor="candidate"`
との接続が非常にきれいになる。

したがって safest reading は、
**strict-side polarity is preserved across acceptance states**
である。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
branchVariant?: 0 | 1
```

について、

```ts
value-level:
  one side = fast/shortcut-leaning
  other side = strict/non-fast-path-leaning

reader-level:
  if (accepted) {
    // admitted-path refinement
  } else {
    // fallback refinement
  }
```

にかなり近い。

つまり `accepted`
は polarity を変えるのではなく、
**その polarity を activation と fallback のどちらとして読むか**
を決める field だとみるのが current best である。

## implication for step 6

この整理を採ると、
step 6 の provisional API は shape を変えずに semantics を強められる。

- `branchVariant?: 0 | 1` は shared value
- strict-side polarity も shared
- `accepted` が only decides reader role

で十分だからである。

つまり next analysis / next implementation では、
`branchVariant`
を true/false で別 meaning table に分けるより、
**same polarity, different role**
として扱うほうが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `pointerFlavor="candidate"` の strict-side reopening が true/false の両側で同じ向きを保つか
2. final `target` 差分も true/false の両側で同じ polarity downstream として説明できるか
3. `branch` 自体も同じく shared polarity family として保てるか

ここが取れれば、first-line / second-line の field-level semantics はかなり recovered semantics に近づく。
