# SaGa2 Combat-RNG Subblock Ranking Report

## Summary
- `41A4-41F1` をさらに sub-block に分けると、`combat RNG` の first-line 候補は **`41C4-41EC` の pointer/record validation 帯**、second line は **`41F1-4205` の post-local gate**、third line は **`41A4-41B4` の state `04/05` dispatch 自体** と置くのが最も自然である。
- 理由は、`41A4-41B4` が phase opener、`41B9-41C3` が pointer materialization、`41C4-41EC` が sentinel/branch/countdown 風の local resolution、`41F1-4205` がその後の accept/reject gate に見えるからである。
- したがって next pass では、まず `41C4-41EC` を **raw/small-range RNG が最も刺さりやすい local resolution belt** として扱うのが安全になる。

## 1. Sub-block Split

`41A4-41F1` は battle-side の意味で少なくとも 4 つに分けて読める。

1. `41A4-41B4`  
   state `04/05` dispatch opener
2. `41B9-41C3`  
   pointer-like pair materialization
3. `41C4-41EC`  
   sentinel / special value / 3byte-table local handling
4. `41F1-4205`  
   post-local gate and queue advance test

この分け方を取ると、
`combat RNG` がどこで必要になるかをかなり具体的に考えられる。

## 2. Why `41A4-41B4` Is Third-Line

```text
41A4: BIT 3,C
41A6: JR Z,$41B0
41A8: ... LD A,$04 ; CALL $4361
41B0: ... LD A,$05 ; CALL $4361
```

ここは current actor の local phase を開く
**branch opener / state dispatch**
に見える。

しかしこの帯そのものは:

- range compare
- random compare
- final branch polarity

より、
「どの local phase に入るか」を決める層に留まる。

したがって RNG が直に刺さる first-line 観測点としては一段手前。

## 3. Why `41B9-41C3` Is Still Preparatory

```text
41B9: INC E
41BA: INC E
41BB: INC E
41BC: LD A,(DE)
41BD: LD (HL+),A
41BE: LD C,A
41BF: INC E
41C0: LD A,(DE)
41C1: LD (HL),A
41C2: LD H,A
41C3: LD L,C
```

ここは pointer-like pair を `HL` に materialize している帯に見える。

意味としては:

- local candidate base の解決
- record pointer の確定

にかなり近いが、
ここ自体はまだ deterministic な materialization と読むほうが自然。

したがって RNG の刺さり先というより、
**RNG が次に参照しそうな local object を作る段**
として second/third line に置くのが安全。

## 4. Why `41C4-41EC` Is First-Line

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

この帯は:

- sentinel / special code (`FF`, `0E`, `0F`, `FE`)
- pointer/record validity
- 3byte stride table
- decrement / consume-like update

を含んでいる。

これは battle-side 意味として、
最も **local resolution / local accept-reject / local consumption**
に近い。

もし raw/small-range RNG が

- hit/miss polarity
- reroll/no-reroll
- local candidate accept

のような小さい判定に使われるなら、
この帯に一番刺さりやすい。

したがって `41C4-41EC` を first-line priority block と置くのが自然。

## 5. Why `41F1-4205` Is Second-Line

```text
41F1: CALL $01E3
41F4: LD HL,$D001
41F7: LD B,$05
41F9: CALL $435A
41FC: OR A
41FD: JR Z,$4250
41FF: LD B,$03
4201: CALL $435A
4204: OR A
4205: JR Z,$4273
```

この帯は local block の後で:

- dispatch/callback
- aggregate gate
- continue/fail 分岐

をしているように見える。

したがって combat RNG がここにある可能性も残るが、
もし存在するとしても
`41C4-41EC` より一段後ろの
**post-local accept/reject gate**
として読むほうが自然である。

## 6. Practical Priority Order

次に実 ROM 側で raw/small-range RNG callsite を探す順番は:

1. `41C4-41EC`
2. `41F1-4205`
3. `41A4-41B4`
4. `41B9-41C3`

と置くのが最も false positive を減らしやすい。

## Implication
- `41C4-41EC` は combat RNG の first-line priority block
- `41F1-4205` は second-line の post-local gate
- 次の battle/RNG 解析はまず `41C4-41EC` を actor-local resolution belt として掘るべきである
