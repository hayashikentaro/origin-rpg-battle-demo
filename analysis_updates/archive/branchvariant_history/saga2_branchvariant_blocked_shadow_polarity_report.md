# Saga2 BranchVariant Blocked-Shadow Polarity Report

## 要点

- current best reading では、qualifier `1` blocked ordinal の shadow は `branchVariant 0/1` の primary split を決める軸ではなく、**strict-side polarity へ寄る secondary shadow** とみるのが最も自然である
- したがって `branchVariant` の 2 値は first-line では引き続き **`0E/0F` family difference を主軸** として読み、blocked ordinal はそのどちらか一方に少し重みを与える **polarity bias** として持つのが safest である
- current frontier では、その bias は fast-path privilege 側より **strict / non-fast-path 側** に片寄るとみるのが最も自然である

## 1. Why Blocked Ordinal Is Better Read As A Polarity Bias

既報では:

- `branchVariant`
  = code-led compressed split
- primary axis
  = `0E/0F` family difference
- qualifier `1`
  = blocked ordinal

という整理まで来ている。

この時点で qualifier `1`
が `branchVariant 0/1`
のどちらに寄るかを考えると、
binary split そのものを作る主軸として扱うより、
**既にある split のうち strict 側を少し強める polarity bias**
として扱うほうが自然である。

理由は、
blocked ordinal 自体が

- fast-path を開く
- shortcut を許す

よりも、

- reject
- strict path 残留
- consume bypass

と相性のよい profile を持つからである。

## 2. Why The Bias Should Lean Toward The Strict Side

既報の qualifier semantics では、
`qualifier == 1`
は

- allowed zero ではない
- blocked ordinal
- fast-path privilege を持たない

と narrowed されている。

また `0F + qualifier==0`
だけが zero-fast-path privilege を持つ、
という非対称性も既報でかなり強い。

この 2 本を合わせると、
qualifier `1`
の shadow が片寄る先は
fast/shortcut 側より
**strict / non-fast-path 側**
だとみるのが最も自然になる。

つまり safest bias は:

- blocked ordinal shadow
  -> strict polarity

である。

## 3. Why This Does Not Overrule The Code-Led Primary Axis

この整理は、
qualifier `1`
が `branchVariant`
の主軸になると言っているわけではない。

current best reading では依然として:

- primary = `0E/0F` family difference
- secondary = qualifier class contribution

である。

ここで blocked ordinal が担うのは、
binary split の意味を作り直すことではなく、
**どちらの side が strict-polarity を帯びるかを少し強めること**
である。

つまり:

- split の骨格は code-led
- blocked ordinal は strict-side bias を加える

という layered reading が safest になる。

## 4. Relation To `pointerFlavor="candidate"`

既報では
`pointerFlavor="candidate"`
も
code-led carry with blocked-ordinal shadow
と読むのが current best である。

この前提を採ると、
first-line の `branchVariant`
に残る blocked shadow も、
second-line の `pointerFlavor="candidate"`
に残る blocked shadow も、
どちらも
**strict-polarity bias**
として見るのが最もよく整合する。

つまり current best role split は:

- `branchVariant`
  = first-line strict-polarity bias を含む compressed split
- `pointerFlavor="candidate"`
  = second-line strict-polarity shadow を含む provenance carry

である。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
branchVariant?: 0 | 1
```

の exact semantics は:

```ts
code-led binary refinement
// primary axis: 0E/0F family difference
// secondary polarity bias: qualifier==1 pushes toward strict side
```

にかなり近い。

つまり qualifier `1`
の shadow は
`branchVariant`
のどちらか一方を pure blocked bucket にするのではなく、
**strict-side polarity を強める weak directional bias**
として持つのが current best である。

## implication for step 6

この整理を採ると、
step 6 の provisional API は shape を変えずに semantics だけを強められる。

- `branchVariant?: 0 | 1` はそのまま
- blocked ordinal は新 field にしない
- meaning layer で strict-side bias として読む

で十分だからである。

つまり next analysis は、
`branchVariant`
の one-side meaning を pure qualifier bucket に決め打ちするより、
**strict-polarity bias**
として sharpen するほうが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. strict-side polarity が `branchVariant=0` と `1` のどちらにより自然に対応するか
2. `accepted=true` と `accepted=false` の両側でこの strict-polarity bias が同じ向きで保たれるか
3. second-line の `pointerFlavor="candidate"` 側でも同じ polarity bias が downstream に残るか

ここが取れれば、`branchVariant` の exact semantics はかなり recovered semantics に近づく。
