# Saga2 D?12 Entry Semantics Report

## 要点

- current best reading では、`D?12..` に並ぶ 2byte entry は  
  **`low byte = candidate/type code`**  
  **`high byte = qualifier / owner / count-like byte`**  
  と置くのが最も自然である
- これは `41BC-41C3` で `C/H` に展開される pair、`43FA-443A` で 9件 fold される list、`437E` で 8要素 mirror される帯、の 3 本を一緒に見たときに最も整合する
- したがって `combatDecision` の unresolved source も、`BattleActionHead` の compact head そのものではなく、**`D?12..` candidate entry の code/qualifier pair** に寄るとみるのが安全である

## 既報の土台

### `43FA-443A`

既報では `43FA-443A` は

- `HL=$D?12`
- 9件の 2byte entry
- `0D:6F82 + entry*8` を引く

という prepass helper とみている。

ここで low byte `FF` が空 slot sentinel として使われているのはかなり強い。

### `41BC-41C3`

`actors` loop では、同じ帯から 2byte pair を取り出し、

- `C = first byte`
- `H = second byte`

として pre-gate に渡している。

### `437E`

`437E` は `D?12..` から 8要素を mirror しているため、
この帯が page-local repeated slot/candidate family であることを補強している。

## 低 byte の意味

low byte 側は、既報 evidence だけでも次の特徴を持つ。

- `FF` sentinel がある
- `0E / 0F` の special code がある
- `41D9-41E5` では `index * 3 + $14` に使われる
- `43FA-443A` では `entry * 8` の table index に使われる

この profile は、

- item id / command id のような compact value

より、

- **candidate/type code**
- **slot-local action selector**

にかなり近い。

## 高 byte の意味

high byte 側はまだ未確定だが、既報 evidence からは次が言える。

- `41C4-41D8` では `H == 0` / `H == 1` 相当で further gate を形成する
- `C == 0F` と組み合わさると `H` の値で進路が変わる
- したがって low byte の単なる上位バイトというより、**entry に付随する secondary qualifier** とみるほうが自然

現時点の安全な呼び方は次のいずれかである。

- qualifier
- owner byte
- count-like byte

いずれにせよ、battle-side の local gate を追加で切るための second field である可能性が高い。

## current best provisional shape

いま最も安全な provisional shape はこう置ける。

```ts
type BattlePageCandidateEntry = {
  code: number       // low byte, FF/0E/0F aware
  qualifier: number  // high byte, secondary gate field
}
```

`inventory entry` と断定するより、
`candidate entry` として持つほうが battle / prepass / selector の全 evidence に整合しやすい。

## implication for `combatDecision`

この shape を採ると、
current `combatDecision` の source はさらに明確になる。

- `BattleActionHead(kindId, arg, target, slotIndex)`
  が local path を開く
- その後 `D?12..` entry の `code/qualifier` pair を読む
- その pair に対する special/sentinel gate が `41C4-41D8`
- その先に `41D9-41EC` consume belt がある

つまり `combatDecision` は、
**action head の直後** ではなく、
**candidate entry の code/qualifier pair に対する local gate**
に対応づけるのが最も自然である。

## 次の確認点

次に本当に見たいのは次の 3 点である。

1. `code == 0E / 0F` の実意味
2. `qualifier == 0 / 1+` の実意味
3. `D?12..` entry の生成元が inventory 由来か action candidate 由来か

ここが取れれば、`combatDecision` は
`candidate-entry special gate`
としてかなり具体化できる。
