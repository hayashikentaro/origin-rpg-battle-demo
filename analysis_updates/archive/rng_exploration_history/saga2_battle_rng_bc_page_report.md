# SaGa2 battle RNG BC page report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_battle_rng_bridge_report.md`
- 既存 `saga2_battle_rng_prepass_report.md`

## 目的

- `443B` 入口時点の `BC` ベース page を caller 側から絞る
- `battle` と `rng` の接続部で触っている work record 群の所属を固める

## 結論

このレポートの初期仮説は、
`4086: CALL $443A` caller を
`D849/D949/DA49` family と結びつけていた。

しかし実バイト `0D:4024-4075` を取り直した結果、
ここは修正が必要になった。

現在の高確度な読みは次のとおり。

- `44F4` caller の前半 loop は `D5xx` 3 page
- `DE10` writeback 先は `D849/D94A/D94B` 相当
- `443A` caller の後半 loop は **`BC=$D500 -> D600 -> D700`**

したがって、
**`443A` caller page family を `D8xx-D Axx` とみなす旧仮説は撤回し、`D5xx-D7xx` family として扱うのが安全**
になった。

一方で、
`D849` family が controller-side metadata writeback である可能性自体は残る。

## 1. 修正後の caller 断片

実バイトで確認できた断片:

```text
4024: PUSH BC
4025: PUSH DE
...
4033: LD A,$03
4035: SUB B
4036: ADD A,$49
4038: LD C,A
4039: LD B,$D8
403B: LD A,($DE10)
403E: LD (BC),A
...
4067: LD BC,$D500
406A: LD A,$03
406C: PUSH AF
406D: PUSH BC
406E: CALL $443A
4071: POP BC
4072: INC B
4073: POP AF
4074: DEC A
4075: JR NZ,$406C
```

このため、
`CALL $443A` の 1 回目は `BC=$D500` で入り、
以後 `INC B` により `D600`, `D700` と進むと読むのが自然。

## 2. `443A` と `443B` の関係

`443A` は `RET` で終わる prepass helper、
その直後の `443B` は別 helper である。

ただし ROM 上では連続配置されており、
どちらも `BC` 基準で low offset を切り替えながら処理する。

前者:

- `43FB-443A`
- `BC` が指す 9 個の 16bit entry 群を使う
- `H:2D/H:2E` に集約 flag を作る

後者:

- `443B-4499`
- `C=$0C/$0A/$40` を使って `BC` page 内の複数 offset を読む/書く
- slot `07/08` で pointer record を build する

このため、
両者が battle work helper family に属する可能性は高いが、
**caller 側の page family が同一かどうかは再保留**
とするのが安全。

## 3. `443B` が示す low offset

`443B-4499` では:

- `BC+00`: guard / count
- `BC+0A`: span 上限候補
- `BC+0C/0D`: base pointer
- `BC+40+`: pointer record 書き戻し先

が見えている。

したがって page 単位では
**header/count 領域 + pointer source 領域 + pointer sink 領域**
を持つ compact battle work struct の可能性が高い。

## 4. 何が固まったか

今回の進展で、
少なくとも次を分けて扱う必要がある。

- `DE10` writeback 先: `D8xx` family low offset `$49+`
- `443A` caller: `D5xx-D7xx`
- `4048-405A` 中間 loop: `D0xx-D4xx`

つまり `4024-4075` は、
単一 page family を回すのではなく
**複数の work family を接続する battle prepare cluster**
として読むほうが自然。

## 5. 移植への意味

TypeScript 側では、
この path を単一 struct ではなく、
少なくとも複数 family をまたぐ helper cluster として分けるのが安全。

```ts
type BattlePrepareContext = {
  d0Pages: unknown[]
  d5Pages: unknown[]
  d8Meta: number[]
}
```

もちろん意味論は仮置きだが、
少なくとも `443B-4499` が触っているのは
`C206` actor mirror より
もう一段 controller 寄りの work に見える。

## 残る不明点

- `443B` への direct entry がどこから来るか
- `D849/D94A/D94B` 相当 writeback の正式意味
- `443A` が `D5xx-D7xx` page のどこを読むか
- `449A-44F3` と `4048-405A` loop の関係

## 次の一手

1. `404A-408E` 全体を helper 群の caller cluster として独立整理する
2. `44F4` の契約を切って `443A/443B/449A` との関係を並べる
3. `D84D` 近辺既知 table と `D849` family の整合を取る
