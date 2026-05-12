# Saga2 Qualifier-Zero Variant Asymmetry Report

## 要点

- current best reading では、`qualifier == 0` は `0E` と `0F` の両方で最終的には **許可側** に属するが、**同じ意味で許可されるわけではない** とみるのが最も自然である
- `0E` は `qualifier == 0` でも必ず `41D5-41D7` を通る
- `0F` は `qualifier == 0` のときだけ `41D9` へ直進できる
- したがって safest provisional reading は、`qualifier == 0` を family-common permissive state としつつ、**`0F` だけが zero-fast-path という variant privilege を持つ** ことである

## relevant flow

```text
41C9: CP $0E
41CB: JR Z,$41D5
41CD: CP $0F
41CF: JR NZ,$41D9
41D1: LD A,H
41D2: OR A
41D3: JR Z,$41D9
41D5: LD A,H
41D6: DEC A
41D7: JR Z,$41F1
```

この flow から直接言えるのは:

- `0E + qualifier==0` は `41D5` を通る
- `0F + qualifier==0` は `41D9` へ直進する
- どちらも reject にはならない

ということである。

## 1. 同じ「許可」ではない

`qualifier == 0` を単に

- usable
- available

とだけ読むと、`0E` と `0F` の差が消えてしまう。

しかし実際には、

- `0E` は strict path
- `0F` は shortcut path

という entry-side 非対称性がある。

したがって safest reading は、

- **family-common には「blocked ではない」**
- その上で `0F` だけが **zero-fast-path privilege** を持つ

という 2 層構造である。

## 2. `0E` 側の zero

`0E` は `qualifier == 0` でも `41D5-41D7` を経由するため、
`0E` における zero は

- blocked ではない
- ただし fast ではない

という意味に留まる。

したがって `0E` の zero は
**strict-allowed zero**
とでも呼ぶのが安全である。

## 3. `0F` 側の zero

`0F` は `qualifier == 0` で only fast-path を開く。

したがって `0F` の zero は

- blocked ではない
- strict path を省略できる
- local consume belt に shortcut 進入する

という **variant-specific privilege** を持つとみるのが最も自然である。

## provisional semantics

現時点では次のように持つのが安全である。

```ts
type SpecialCandidateZeroMeaning =
  | { code: 0x0e; qualifier: 0; meaning: "strict-allowed-zero" }
  | { code: 0x0f; qualifier: 0; meaning: "fast-path-zero" }
```

もっと高位では:

```ts
type SpecialCandidateFamilyRule =
  | { qualifier: 1; meaning: "blocked-ordinal" }
  | { qualifier: 0; meaning: "allowed"; variantPrivilege?: "zero-fast-path" }
  | { qualifier: number; meaning: "allowed-nonzero" } // 2+
```

のように、family-common rule と variant privilege を分けて持つのが safest である。

## implication for `combatDecision`

この整理を採ると、current `combatDecision` は

- `special-candidate family gate`
- `blocked-ordinal rule`
- `0F` zero-fast-path privilege

の 3 層構造にかなり自然に落ちる。

つまり unresolved source を battle API 寄りに言い換えるなら、
`combatDecision` は単なる yes/no gate というより
**family-common local accept/reject の上に variant-specific shortcut が乗る branch source**
に近い。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `qualifier >= 2` が `0E/0F` の両方で truly 同一意味か
2. `41D5-41D7` を通った `0E zero` と `0F nonzero` が後段で同じ consume semantics を持つか
3. `0E/0F` family entry の生成元が inventory 由来か action-path 由来か

ここが取れれば、`combatDecision` は
**family rule + variant privilege**
としてかなり実装寄りに固定できる。
