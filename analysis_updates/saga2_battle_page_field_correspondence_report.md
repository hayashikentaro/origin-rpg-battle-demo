# SaGa2 battle page field correspondence report

## 対象

- `rom/common.i`
- 既存 `saga2_battle_prepare_helpers_report.md`
- 既存 `saga2_437e_contract_report.md`
- 既存 `saga2_actors_loop_report.md`

## 目的

- `449A` が展開する `D0xx` page fields と、`437E` / `actors` loop の read path を照合する
- `D0xx` battle page struct を仮ラベル付きで一段具体化する

## 結論

`common.i` の `battle.data.*` ラベルと照らすと、
`449A` が `D0xx..D4xx` に展開している field 群は
`437E` / `actors` loop が読んでいる offset とかなり素直に噛み合う。

特に強い対応は次の 4 本。

1. `D?40-42`  
   `status / hp / status-adjacent staging`
2. `D?43-46`  
   `item_id / target / item_slot_index` 近辺
3. `D?0A-0B`  
   `monster_id / race`
4. `D?12..`  
   `inventory` 起点の 8 要素列

したがって `4048-405A` の `449A` は、
単なる謎 record 展開ではなく
**battle.data page を戦闘実行用の compact work / status / inventory staging に整形する helper**
とみるのがかなり自然になった。

## 1. `common.i` の関連ラベル

`common.i` では `D0xx` / `D5xx` に次のラベルがある。

```text
battle.data.1          = $D000
battle.data.1.monster_id = $D00A
battle.data.1.race       = $D00B
battle.data.1.inventory  = $D012

battle.data.1.stat.1          = $D040
battle.data.1.stat.1.status   = $D040
battle.data.1.stat.1.hp       = $D041
battle.data.1.stat.1.item_id  = $D043
battle.data.1.stat.1.target   = $D045
battle.data.1.stat.1.item_slot_index = $D046
```

同じパターンが `D500` 側にもある。

このため `D0xx` / `D5xx` family は、
少なくとも battle actor/page 単位の構造体として
既にかなり一貫している。

## 2. `449A` の書き込みと struct 対応

`449A` の展開先を `common.i` に当てると、
次の対応が見えてくる。

### 強い対応

- `D?00 = 01`
  - `max_stack` か active marker 候補
- `D?0A..0B`
  - `monster_id / race`
- `D?12..`
  - `inventory` 起点
- `D?40`
  - `stat.1.status`
- `D?43..44`
  - `stat.1.item_id` とその隣接 field

### 中程度の対応

- `D?01`
  - `D?40` bit4 由来の 0/1 flag
  - `current_stack` そのものか、あるいは action enable flag の可能性
- `D?06..09`
  - `FF` 初期化される補助 slot
- `D?0C..11`
  - `hp / str / agl / mana / def / ...` の戦闘用抜粋

### 8 要素 pair 展開

`449A` 後半の 8 回ループは、
`D?12..` 以降へ
`value, 0, value`
風の pair/triad を並べている。

`common.i` で `inventory = $D012` なので、
ここはかなり自然に
**8 inventory slots の action staging**
と読める。

## 3. `437E` 側との一致

`437E` では実際に次を読んでいた。

- `D?40` の high nibble を status として使う
- `D?41/42` を条件付きで更新/正規化する
- `D?43/44` を `C206` 側へコピーする
- `D?12..` から 8 要素を mirror する
- `D?0B` を見て `race < 2` らしき条件分岐を行う

これは `449A` の展開先とかなりきれいに一致する。

特に:

- `D?40 -> C206.status`
- `D?43/44 -> C206 compact work`
- `D?12.. -> C206 inventory/candidate mirror`

の 3 本は強い。

したがって `437E` は
`449A` が作った `D0xx` page をさらに `C206` へ要約する
**second-stage normalizer**
とみるのが自然。

## 4. `actors` loop 側との一致

`actors` loop でも:

- actor page は `D0xx + id`
- offset `+1` を active/zero 判定
- さらに `+3` 相当先から 2 byte を引いて pointer 候補化

という read path が見えていた。

このことは、
`D0xx` page が実際に battle 実行時の actor working set として使われていることを補強する。

つまり `449A` は
単に staging するだけではなく、
**その後の queue/action resolve が直接読む page**
を作っている可能性が高い。

## 5. `race < 2` 分岐の意味

`437E` の後半では
`D?0B < 2` 条件が出ていた。

`D?0B = race` とみるなら、
これはかなり自然に
**人間/エスパー系とモンスター系の分岐**
を示している可能性がある。

この場合、`D?12..` inventory 起点の正規化で
`C < $80` なら `FF` を入れる条件も、
装備/能力 slot の扱い差として読める。

ここはまだ断定しないほうが安全だが、
field 対応としてはかなり筋が通る。

## 6. 仮 struct

現時点では、`D0xx` battle page を次のように仮置きできる。

```ts
type BattleDataPage = {
  maxStackOrActive: number      // +00
  currentStackOrFlag: number    // +01
  nameOrHeader: number[]        // +02..05
  tempFF: number[]              // +06..09
  monsterId: number             // +0A
  race: number                  // +0B
  statsBlock: number[]          // +0C..11
  inventoryLike: number[]       // +12..
  stat1Status: number           // +40
  stat1HpOrFlag: number         // +41
  stat1Aux: number              // +42
  stat1ItemId: number           // +43
  stat1TargetLike: number       // +44/+45
  stat1ItemSlotIndexLike: number // +46
}
```

命名はまだ仮だが、
`449A` / `437E` / `actors` loop の 3 本を横に置くと、
このくらいの粒度で持つのはかなり安全。

## 移植への意味

TypeScript 側では `battle` モジュール内に、
少なくとも次の 2 層を分けるとよさそう。

```ts
expandBattleDataPageFromPartyRecord()
normalizeBattleDataPageToVisibleActorState()
```

前者が `449A`、後者が `437E` に近い責務になる。

## 次の一手

1. `D?43/44/45/46` を `actors` loop と `00D2` descriptor path に照合して `item_id / target / slot` を確定する
2. `D?12..` 8 要素列を inventory / action slot のどちらかへ寄せる
3. `D500/D600/D700` family と `D0xx` family の役割分担を `443A` 側から切る
