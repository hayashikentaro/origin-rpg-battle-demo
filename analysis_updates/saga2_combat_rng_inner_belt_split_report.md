# SaGa2 Combat-RNG Inner-Belt Split Report

## Summary
- first-line priority block として残った `41C4-41EC` も、意味的には **`41C4-41D8` の pre-filter** と **`41D9-41EC` の consume/update belt** に分けるのが自然である。
- この 2 分割を採ると、raw/small-range RNG が最も刺さりやすいのは前半の sentinel 判定群より、**後半 `41D9-41EC` の local table consume/update 帯** とみるほうが整合する。
- したがって next pass の最優先観測点は、`41C4-41EC` 全体ではなく **`41D9-41EC`** にさらに寄せてよい。

## 1. `41C4-41D8` Is Mostly A Pre-Filter

前半は次の形。

```text
41C4: LD A,C
41C5: CP $FF
41C7: JR Z,$41F1
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

ここで行っているのは主に:

- sentinel / special code (`FF`, `0E`, `0F`) の判定
- pointer high byte の簡易検証
- local block 継続か離脱かの前処理

である。

この帯は battle-side の意味としては
**filter / reject / early-exit**
に寄っていて、
RNG の値を直接比較・消費するより前段の deterministic gate に見える。

## 2. `41D9-41EC` Is A Better RNG Hook Candidate

後半は次の形。

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
41E6: LD A,(DE)
41E7: CP $FE
41E9: JR Z,$41ED
41EB: DEC A
41EC: LD (DE),A
```

ここで見えているのは:

1. local entry から別 index を引く
2. `index * 3 + 0x14` の 3byte-stride table へ飛ぶ
3. table byte を読む
4. `FE` sentinel でなければ減算して書き戻す

つまりこれは
**local candidate / local quota / local countdown の consume/update**
にかなり近い。

もし raw/small-range RNG が

- consume する candidate を選ぶ
- reroll するかを決める
- local accept/reject を分ける

のような役割を持つなら、
この帯のほうが前半よりずっと刺さりやすい。

## 3. Best Current Reading

現時点の safest reading は次のように置ける。

```ts
if (!passesLocalPreFilter(pointerOrCode)) {
  goto postLocalGate
}

const localEntry = resolveLocalTableEntry(...)
const localCounter = readCounter(localEntry)

// likely best place to search for unresolved combat RNG hook
const maybeCombatDecision = unresolvedCombatRng(...)

if (localCounter !== 0xfe) {
  localCounter--
  writeBack(localCounter)
}
```

もちろん `unresolvedCombatRng(...)` の位置はまだ仮説だが、
少なくとも battle-side の意味域としては
`41D9-41EC` のほうが first-line hook に近い。

## 4. Search Consequence

次の実探索順はさらにこう縮められる。

1. `41D9-41EC`
2. `41F1-4205`
3. `41C4-41D8`
4. `41A4-41B4`

特に `41D9-41EC` では、

- raw compare (`FF00`)
- binary gate (`0100`)
- small spread (`0300`, `0F00`)

のどれが来ても battle-side 意味として接続しやすい。

## Implication
- `41C4-41EC` はさらに `pre-filter` と `consume/update` に分けて考えるべき
- raw/small-range RNG の本命 hook は `41D9-41EC` に一段寄る
- 次の battle/RNG 解析は `41D9-41EC` を最優先の local consume/update belt として掘るのが安全
