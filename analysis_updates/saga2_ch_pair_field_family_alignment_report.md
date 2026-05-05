# Saga2 C/H Pair Field Family Alignment Report

## 要点

- `41BC-41C3` で読まれる `C/H` pair は、現時点では `D?43-46` compact action head より **`D?12..` inventory/candidate-like entry family** に寄せて読むほうが自然である
- 理由は 3 つある
  1. `actors` loop 自身が「actor page のさらに後ろから 2 byte を読む」と見えていること
  2. `D?43/44` は既報 `437E` で compact work へ直接 mirror される status 直下 pair として見えていること
  3. `D?12..` は既報 prepass/normalizer で 8〜9件の slot/candidate entry 群として扱われていること
- したがって current best reading では、`combatDecision` の source 候補は action head (`D?43-46`) 直下より、**`D?12..` 側の candidate entry pair** にある可能性が高い

## `D?43-46` 側の既報

既報では `D?43-46` は次のようにかなり安定している。

- `D?43` = `itemId / kindId` 候補
- `D?44` = `arg / param` 候補
- `D?45` = `target` 候補
- `D?46` = `slotIndex` 候補

また `437E` では

- `D?43/44` を `C206` 側 compact work へ mirror

しているため、これは battle command head / compact descriptor としてかなり自然である。

## `D?12..` 側の既報

いっぽう `D?12..` については、既に複数の既報がある。

- `437E` は `D?12..` から 8 要素を mirror
- `43FA` / `43FB-443A` は `D?12..` 起点の 9件 list を fold
- prepass seed 側でも `D?12..` を slot/candidate list として読むのが自然

つまり `D?12..` は inventory そのものか action candidate list かは未確定でも、
少なくとも **複数件の candidate entry を持つ帯** としてかなり安定している。

## `41BC-41C3` との整合

`41BC-41C3` の relevant flow は:

```text
41B9: INC E
41BA: INC E
41BB: INC E
41BC: LD A,(DE)
41BE: LD C,A
41BF: INC E
41C0: LD A,(DE)
41C2: LD H,A
41C3: LD L,C
```

この setup で重要なのは、

- actor page の現在位置から **さらに後ろの 2byte pair**
- その pair を `C/H/HL` として使う

という点である。

これを field family と照合すると、

- `D?43/44` のような compact head 直下 pair

より、

- `D?12..` のような repeated slot/candidate entry 群の 1 件

として読むほうがかなり自然である。

## なぜ `D?43-46` より `D?12..` なのか

### 1. offset の性質

既報 `actors` loop 自体が

- `+1` active/zero 判定
- そのさらに後ろから 2byte pair

という読みを示している。

これは status 直下 compact head (`+43..46`) をそのまま読む像より、
list/entry 帯の 1 件を選ぶ像に近い。

### 2. special values

`41C4-41D8` は

- `FF`
- `0E`
- `0F`

を primary code 側 special value として扱う。

この種の sentinel/type code は、
単一 command head より **candidate entry / slot entry** のほうが素直に乗る。

### 3. 後段の `index * 3 + $14`

`41D9-41E5` では primary code から `index * 3 + $14` を作っている。

これは

- command head の item id を直接使う

像より、

- candidate code から local 3byte record table を引く

像に近い。

## implication for `combatDecision`

この alignment を採ると、current `combatDecision` の unresolved source は

- `BattleActionHead(kindId, arg, target, slotIndex)` の直下

ではなく、

- **branch/path が開いたあとの candidate-entry consumption**

にさらに寄る。

つまり current skeleton で

- `action head`
- `localPath`
- optional `07/08` candidate RNG
- `combatDecision`

を分けて持っている cut は、今の evidence とかなり整合する。

## まとめ

- `D?43-46` は compact action head 側として依然有力
- `41BC-41C3` の `C/H` pair はそこより `D?12..` repeated candidate entry family に寄る
- したがって `combatDecision` の source は action head より candidate consumption 側にある可能性が高い
