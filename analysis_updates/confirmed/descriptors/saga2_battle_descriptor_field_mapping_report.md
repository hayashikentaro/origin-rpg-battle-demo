# SaGa2 battle descriptor field mapping report

## 対象

- `rom/common.i`
- 既存 `saga2_00d2_battle_callers_report.md`
- 既存 `saga2_battle_page_field_correspondence_report.md`
- 既存 `saga2_actors_loop_report.md`

## 目的

- `D?43/44/45/46` を `00D2 -> C1A5-C1AC` descriptor path と照合する
- `item_id / target / slot` の暫定対応を battle core 向けに整理する

## 結論

現時点では完全確定ではないが、
`common.i` の battle.data ラベル、
`449A -> D0xx` 展開、
`437E` / `actors` loop の read path、
`42D4-442A` の `C1A5-C1AC` descriptor build
を横に置くと、
`D?43/44/45/46` はかなり自然に
**`item_id / parameter-or-subtarget / target / item_slot_index`**
系として読める。

特に確度が高いのは次の 3 点。

1. `D?43` は `item_id` 候補
2. `D?45` は `target` 候補
3. `D?46` は `item_slot_index` 候補

逆に `D?44` はまだ中間的で、
`parameter / count / subtarget / pointer-low` のどれかに寄るが未確定。

## 1. `common.i` からの素直な対応

`common.i` では:

```text
battle.data.1.stat.1.status          = $D040
battle.data.1.stat.1.hp              = $D041
battle.data.1.stat.1.item_id         = $D043
battle.data.1.stat.1.target          = $D045
battle.data.1.stat.1.item_slot_index = $D046
```

なので、名前だけを素直に読むなら
`D?43/45/46` はすでにかなり明快。

問題はこれが battle 実行時の実アクセスと噛み合うかだが、
現状の解析結果はむしろかなり整合している。

## 2. `449A` 展開との一致

`449A` では:

- `D?40` に 1 byte
- `D?41/42` に補助値
- `D?43/44` に 2 byte copy
- その後 `D?0C..11`, `D?12..` を埋める

が見えている。

この形は、
`stat.1.status`
に続いて
`stat.1.item_id` とその隣接 field を入れる構造としてかなり自然。

少なくとも `D?43` が action/item kind を持ち、
`D?44` がその補助 byte という読みは強い。

## 3. `437E` 側の使われ方

`437E` では:

- `D?40` の high nibble を status として読む
- `D?43/44` を `C206` 側へ mirror する
- `D?12..` を 8 要素列として mirror する

ここで重要なのは、
`D?43/44` が **status 直下の compact pair**
として扱われていること。

もし `D?43` が item_id であれば、
`D?44` はその parameter/target-side 補助値として
かなり自然に並ぶ。

## 4. `actors` loop 側の読み

`actors` loop では、
actor page から:

- `+1` の active/zero 判定
- その後ろの 2 byte を pointer 候補として読む
- さらに後続で special value `0E/0F/FF/FE` を判定

が見えていた。

このことから、
`D?43..46` 全体が単なる UI 表示値ではなく、
**action resolve に直接使う compact descriptor**
である可能性が高い。

特に `D?45/46` は、
target / slot index のような small routing field を持っていても自然。

## 5. `C1A5-C1AC` small descriptor との対応

`42D4-442A` cluster では、
banked ROM から small descriptor を引いて
`C1A5-C1AC` へ組み立てていた。

ここで見えているのは:

- `C1A5-C1A7`
- `C1A8-C1AA`
- `C1AB`
- `C1AC...` への copy

で、直後に low 5bit を見て action class 判定へ進む。

この構造を `D?43/44/45/46` に重ねると、
かなり自然な対応は次の通り。

```ts
type ActionDescriptorSmall = {
  kindOrItemId: number   // C1A5  <-> D?43 候補
  argOrParam: number     // C1A6  <-> D?44 候補
  targetOrSlot: number   // C1A7  <-> D?45/46 候補
}
```

もちろん 1:1 確定ではないが、
`kind -> param -> target/slot`
という並び自体は battle command descriptor として非常に自然。

## 6. 現時点の暫定対応

最も安全な暫定対応はこう置ける。

```ts
type BattleDataStat1 = {
  status: number        // +40
  hpOrAux1: number      // +41
  aux2: number          // +42
  itemId: number        // +43
  paramOrSubtarget: number // +44
  target: number        // +45
  itemSlotIndex: number // +46
}
```

ここで `+44` だけは保留し、
`+45/+46` を target/slot 側へ寄せるのがいまは最も安全。

## 7. 何がまだ足りないか

未確定なのは主に 3 点。

1. `D?44` の意味
2. `C1A5-C1A7` と `D?43-46` の直接コピー関係
3. `00D2` で組んだ descriptor が `D0xx` page にいつ反映されるか

なので、まだ「完全確定」ではなく
**battle core 実装に耐える暫定 mapping**
として扱うのが安全。

## 移植への意味

TypeScript 側では、battle action input を次のように仮置きしやすくなった。

```ts
type BattleActionHead = {
  kindId: number
  arg: number
  target: number
  slotIndex: number
}
```

内部では `arg` を `D?44` の保留 field として持ち、
後から意味が確定したら rename する方針がよい。

## 次の一手

1. `42D4-442A` をもう一段擬似コード化して `C1A5-C1AC` byte ごとの役割を切る
2. `D?12..` 8 要素列が inventory か action slot かを `race < 2` 分岐と一緒に確定する
3. `443A` が `D500/D600/D700` family のどこを畳み込むかを追って controller 側との接続を詰める
