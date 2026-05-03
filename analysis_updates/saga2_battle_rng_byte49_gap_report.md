# SaGa2 battle RNG byte49 gap report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_battle_rng_de00_consumers_report.md`
- 既存 `saga2_actors_loop_report.md`

## 目的

- `D849/D949/DA49` family の readback を探す
- `D84D` 近辺既知 table との関係を整理する

## 結論

今回の局所追跡では、
**`D849/D949/DA49` の byte49 を直接読む強い箇所はまだ取れなかった。**

一方で、同じ `actors` loop の中では
**`D84D + 2*entryByte1` 系はかなり明確に読まれている。**

したがって現段階では:

- `D84D` family は queue/actor-page 解決に使う active table
- `D849` family は `44F4 -> DE10` から書かれるが、用途は未確定

と分けて扱うのが安全。

## 1. `D84D` 側は読める

既報 `actors_loop_report` の `4195-419A` では:

```text
4195: LD A,L
4196: ADD A,A
4197: ADD A,$4D
4199: LD L,A
419A: LD H,$D8
```

となっており、
entry byte1 から
**`D84D + 2*id`**
を引いていると読むのが自然。

その直後は:

```text
419A: LD A,(DE)
...
41BC: LD A,(DE)
41C0: LD A,(DE)
```

で actor page 側 `D0xx + id` も並行して見ている。

このため `D84D` family は、
queue entry と actor page を結ぶ
**controller-side lookup table**
の可能性が高い。

## 2. `D849` 側はまだ未読

これに対して、今わかっている `D849` family は:

```text
4044: CALL $44F4
4053: LD A,($DE10)
4056: LD (BC),A   ; BC = D849/D949/DA49
```

という **write** しか確定していない。

今回見た `4178-424D` loop でも、
直接 `D849` を指して読む形はまだ見つからなかった。

なので byte49 は、

- この loop より後の phase で使われる
- 別 helper (`449A`, `45A8` 以降, あるいは `4361` dispatch 先) で使われる
- または compact flag として他 byte に畳み込まれる

のどれかである可能性がある。

## 3. 現時点の最小整理

少なくとも battle controller work には
近接する 2 系統がありそう。

- `D849/D949/DA49`: `DE10` 由来 byte を保持する writeback slot
- `D84D + 2*n`: queue/actor-page 解決に使う active lookup

現時点では、両者を同じ struct の連続フィールドと断定するには材料不足。

ただし page family としては近く、
同じ controller cluster に属している可能性は高い。

## 4. 移植への意味

TypeScript 側では今のところ、
`byte49` は即 meaning を決め打ちせず、
controller work 内の未命名 field として残すのが安全。

```ts
type BattleControllerPage = {
  byte49_from_de10?: number
  queueLookup?: number[]
}
```

重要なのは、`D84D` は active read path、
`D849` は今のところ write-only path として扱うこと。

## 次の一手

1. `45A8` 以降の helper 群で `D849/D949/DA49` を触っていないか追う
2. `4361` dispatch 先で `D849` family が使われるか確認する
3. `449A-44F3` と `DE00` / `D849` の関係を追加確認する
