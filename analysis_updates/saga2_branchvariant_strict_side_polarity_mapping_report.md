# Saga2 BranchVariant Strict-Side Polarity Mapping Report

## 要点

- current best reading では、qualifier `1` blocked ordinal の shadow が片寄る先は **zero-fast-path privilege の反対側**、すなわち **strict / non-fast-path branchVariant side** とみるのが最も自然である
- したがって `branchVariant 0/1` の exact value mapping はまだ fully recovered ではないものの、current best bias では **片方が fast-side、もう片方が strict-side** を表し、blocked-ordinal shadow は後者へ寄るとみるのが safest である
- この時点では `0` と `1` の数値名付けまで確定し切らず、まず **strict-side polarity mapping** を先に固定するのが battle-side evidence に最も合う

## 1. Why The Shadow Must Lean Away From Fast-Path

既報では:

- `0F + qualifier==0`
  = zero-fast-path privilege
- `qualifier==1`
  = blocked ordinal
- `branchVariant`
  = `0E/0F` family difference を主軸にした code-led compressed split

と整理している。

この 3 本を合わせると、
blocked ordinal shadow が寄る先は
fast-path privilege を表す side ではなく、
その反対側にある
**strict / non-fast-path side**
とみるのが最も自然になる。

なぜなら blocked ordinal は

- shortcut を開かない
- strict path を省略しない
- reject / fallback / consume-bypass と相性がよい

profile を持つからである。

## 2. Why This Still Stops Short Of Naming `0` Or `1`

current frontier では
`branchVariant?: 0 | 1`
の shape 自体はかなり stable だが、
その **numeric polarity**

- `0 = fast, 1 = strict`
or
- `0 = strict, 1 = fast`

まではまだ direct evidence が弱い。

このため safest reading は、
値の数値名付けを急ぐより先に

- one side = fast/shortcut-leaning
- the other side = strict/non-fast-path-leaning

という **semantic polarity** を固定することである。

つまり current best bias は:

```ts
branchVariant in {0, 1}
```

について、

```ts
one side = fast-side
one side = strict-side
blocked-ordinal shadow -> strict-side
```

を先に固める、という形になる。

## 3. Why This Fits Better Than Picking A Numeric Side Now

既報 `branchVariant direct mapping`
では
`candidateOffset bucket 0/1 -> branchVariant 0/1`
の direct mapping bias まで来ている。

しかしこれは
**offset bucket と branchVariant value**
の対応を示すだけで、
その数値が battle-side で
strict/fast のどちらを意味するかまでは保証しない。

ここで数値名付けを急ぐと、
offset bucket の実装都合を
battle semantics へそのまま写してしまう危険がある。

したがって safest reading は、
まず
**blocked shadow は strict-side polarity へ寄る**
ことだけを fixed point にし、
`0/1` の数値対応は second-line evidence が増えるまで保留することである。

## 4. Relation To `pointerFlavor="candidate"`

既報では
`pointerFlavor="candidate"`
も
code-led carry with blocked-ordinal shadow
と読むのが current best である。

この前提を採ると、
`branchVariant`
の strict-side polarity も、
second-line の `pointerFlavor="candidate"`
で reopening する strict-leaning provenance とかなり自然に整合する。

つまり:

- first-line `branchVariant`
  = one side is strict-leaning
- second-line `pointerFlavor="candidate"`
  = strict-leaning shadow を保った candidate provenance reopening

という layered reading が safest になる。

## 5. Safest Current Reading

現時点の safest reading は次のように書ける。

```ts
branchVariant?: 0 | 1
```

の exact semantics は:

```ts
binary refinement with unresolved numeric polarity
// one side = fast/shortcut-leaning
// other side = strict/non-fast-path-leaning
// qualifier==1 blocked shadow leans toward the strict side
```

にかなり近い。

つまり current best bias は、
**strict-side polarity mapping is known before 0/1 naming**
である。

## implication for step 6

この整理を採ると、
step 6 の provisional code は shape を一切変えずに semantics だけを強められる。

- `branchVariant?: 0 | 1` は据え置き
- debug / docs では strict-side bias を明記
- `0` と `1` の exact naming は recovered evidence が増えるまで保留

で十分だからである。

つまり next analysis は、
値を 0/1 で断言するより
**strict-side polarity**
を second-line reopening と突き合わせて sharpen するほうが安全である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. second-line `pointerFlavor="candidate"` 側の strict-leaning reopening が `branchVariant` の片側と自然に対応するか
2. final `target` 差分が strict-side polarity の downstream result としてどこまで説明できるか
3. admitted-path (`accepted=true`) と fallback (`accepted=false`) の両側で strict-side polarity が同じ向きで保たれるか

ここが取れれば、`branchVariant 0/1` の exact semantics はかなり recovered semantics に近づく。
