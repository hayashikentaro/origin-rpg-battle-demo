# Saga2 Counter Consume Microflow Report

## 要点

- `41D9-41EC` の exact micro-flow を既存解析から抜き出すと、`41E7-41E9 -> 41EB-41EC` 自体はかなり **deterministic consume path** に見える
- したがって current `combatDecision` 仮説は、「この 3 命令列そのものに RNG が埋まっている」というより、**ここへ到達する前の local decision が consume/writeback を開くかどうか** に対応づけるほうが自然である
- つまり next pass の本命は依然 `41E7-41E9` 相当の gate 周辺だが、観測対象は `CP/JR/DEC` そのものの内部乱択より、**そこへ入る branch の条件形成** に置くのが安全である

## exact flow

既報 `actors_loop` 解析から、relevant 部分は次のとおり。

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

## 読み

この exact flow は battle-side meaning で少なくとも 3 段に分けて読める。

1. `41D9-41E5`  
   local entry / record pointer resolution
2. `41E6-41E9`  
   counter read + sentinel gate
3. `41EB-41EC`  
   deterministic consume/writeback

特に `41EB-41EC` は単純な `DEC` と writeback であり、ここ自体に random reduction や table lookup は見えていない。

## implication for `combatDecision`

したがって current `combatDecision.shouldConsumeCounter` 仮説は、

- `41EB-41EC` の計算そのもの

ではなく、

- **この deterministic consume path に入るかどうか**

の判定を切り出したものとして持つのが最も自然である。

この意味では、現在の provisional label

- `local_counter_gate`
- `candidate_counter_gate`

は依然妥当で、少なくとも「consume path そのもの」ではなく「consume path を開く gate」の側に置くのが安全である。

## 何がまだ未確定か

未確定なのは次の 2 点に絞られる。

1. `41E7-41E9` の前後に raw/small-range RNG helper が本当にあるか
2. その helper の返り値が `JR Z,$41ED` 相当の gate 条件へどう効くか

つまり next pass では、

- `41EB-41EC` の内部

を掘るより、

- `41D9-41E6` から `41E7-41E9` へ入る条件形成
- その直前直後の branch source

を priority に置くべきである。

## まとめ

- `41E7-41E9 -> 41EB-41EC` は exact flow で見ると deterministic consume belt に近い
- current `combatDecision` はその **gate** に対応づけるのが自然
- 次の battle/RNG 解析は `DEC/writeback` の内側ではなく、**そこへ入る branch 条件の形成源** を first-line に置くべきである
