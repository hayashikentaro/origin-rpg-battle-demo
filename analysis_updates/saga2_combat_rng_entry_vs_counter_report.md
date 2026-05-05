# SaGa2 Combat-RNG Entry-vs-Counter Report

## Summary
- `41D9-41EC` も battle-side の意味では **`41D9-41E5` の local entry resolution** と **`41E6-41EC` の counter consume/writeback** に分けるのが自然である。
- この分け方を取ると、raw/small-range RNG の本命 hook は local entry を引いたあと、**counter byte を読む `41E6` 以降の直前直後** に寄るとみるのが最も整合的になる。
- したがって next pass の最優先観測点は、`41D9-41EC` 全体ではなく **`41E6-41EC` の counter consume belt** として扱うのが安全である。

## 1. `41D9-41E5` Is Entry Resolution

```text
41D9: INC E
41DA: INC E
41DB: LD A,(DE)
41DC: CP $FF
41DE: JR Z,$41F1
41E0: LD E,A
41E1: ADD A,A
41E2: ADD A,E
41E3: ADD A,$14
41E5: LD E,A
```

ここで行っているのは主に:

1. local record から index byte を引く
2. `FF` sentinel なら離脱
3. `index * 3 + 0x14` の local table entry を解決する

つまり意味としては
**local entry resolution / table addressing**
に寄る。

この段階は deterministic な address resolution と読むほうが自然で、
RNG の値を直接比較・消費する本命ポイントよりは一段手前である。

## 2. `41E6-41EC` Is Counter Consume

```text
41E6: LD A,(DE)
41E7: CP $FE
41E9: JR Z,$41ED
41EB: DEC A
41EC: LD (DE),A
```

ここは:

- local table entry の 1 byte を読む
- `FE` sentinel を特別扱い
- そうでなければ `DEC` して書き戻す

という very small consume/writeback loop である。

battle-side の意味としては、

- quota
- counter
- countdown
- remaining-use marker

のどれかにかなり近い。

もし combat RNG が

- local consume を許すか
- reroll するか
- candidate を採用するか

のような小判定に使われるなら、
entry 解決部より
**この counter consume 直前直後** に現れるほうがずっと自然である。

## 3. Best Current Hook Placement

現時点の safest pseudocode は次のように置ける。

```ts
const localEntry = resolveLocalEntry(...)
const counter = readCounter(localEntry)

const maybeCombatDecision = unresolvedCombatRng(...)

if (counter !== 0xfe) {
  writeCounter(counter - 1)
}
```

もちろん `maybeCombatDecision` の exact position はまだ未確定だが、
少なくとも battle-side の意味順としては:

1. entry 解決
2. counter read
3. local consume decision
4. decrement/writeback

のどこかに置くのが一番自然である。

## 4. Practical Priority Shift

この整理で、次の実探索順はさらに縮む。

1. `41E6-41EC`
2. `41D9-41E5`
3. `41F1-4205`
4. `41C4-41D8`

つまり今の first-line question は、
「`41D9-41EC` に RNG があるか」ではなく、
**「`41E6-41EC` の counter consume belt に raw/small-range RNG hook があるか」**
になる。

## Implication
- `41D9-41EC` も entry 解決部と counter consume 部に分けるのが自然
- combat RNG の本命 hook は `41E6-41EC` の直前直後へさらに寄る
- 次の battle/RNG 解析は `41E6-41EC` を最優先の counter consume belt として掘るべきである
