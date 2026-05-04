# SaGa2 battle descriptor cluster correction report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_00d2_battle_callers_report.md`
- 既存 `saga2_battle_descriptor_field_mapping_report.md`
- 既存 `saga2_battle_prepare_helpers_report.md`

## 目的

- `42D4-442A` を一枚岩の `C1A5-C1AC` descriptor build と見ていた整理を修正する
- battle descriptor 本線をより狭い帯へ絞る

## 結論

今回の実バイト再確認で、
`0D:42D4-442A` 全体をそのまま
`C1A5-C1AC` descriptor build とみなすのは粗すぎる、
という点がはっきりした。

少なくともこの帯は 2 群に分けるほうが自然。

1. `42B9-4349`  
   **変身/party record 展開寄りの経路**  
   `HL=$C204` / `CALL $1918` / `0D:6F80` 読みがあり、`C200` 系 player/party buffer を直接触っている
2. `4417+` およびその直前の helper 群  
   **action class 判定と RNG 分岐に近い経路**  
   `AND $1F`, `CP $12/$13`, `CALL $016B`

したがって battle descriptor 本線は、
今後は
**`4329-4349` の中でも `DE=$C1A5` が明示される箇所**
と
**`4417+` の class 判定帯**
へ絞って追うのが安全。

## 1. `42B9-4309` は `C200` 系を直接触る

既存 `item_usage_code_contexts_pass25.csv` では、
この帯の実コード断片として次が見えていた。

```text
42AC: LD HL,$C204
42AF: CALL $1918
...
42D1: ADD HL,DE
42D2: LD A,$0D
42D4: CALL $00D2
...
```

ここで重要なのは、
入口 `HL` が `C204` だということ。

これは `C1A5-C1AC` small descriptor より、
**player/party side の record (`C200` family)**
を直接触る path と読むほうが自然。

さらに `1918` は既報どおり
`party_order ($C2A0)` に従って `HL += 0x20 * slot` を作る helper。

したがって `42B9-4309` は、
`C1A5` 本線というより
**party-ordered record を引いて変身/actor state を展開する path**
とみるのが自然。

## 2. `0D:6F80` 読みの意味

同じ帯では:

```text
42C5: LD L,A
42C6: LD H,$00
42C8: ADD HL,HL
42C9: LD E,L
42CA: LD D,H
42CB: ADD HL,HL
42CC: ADD HL,HL
42CD: ADD HL,DE
42CE: LD DE,$6F80
42D1: ADD HL,DE
42D4: CALL $00D2
```

があり、これは
**index * 5 + `0D:6F80`**
の record 参照としてかなり自然。

しかもその直前には
`LD A,($D847)`、つまり transformation result が見えている。

なのでこの帯は、
**transform result -> record lookup -> `C200` side 展開**
として読むほうが整合する。

## 3. `4329-4349` の位置づけ

一方で `4329-4349` には、
既報どおり `DE=$C1A5` を疑わせる小さな work 展開がある。

既存断片では:

```text
4329: ... CALL $00D2
...
4335: LD A,(DE)
4336: ADD A,$80
...
4341: CALL $00D2
4349: LD A,$0A
434B: CALL $4361
```

ここは:

- 16-byte `FF` buffer 初期化
- nibble/count 由来の回数 loop
- 最後に `0x0A` state dispatch

という形で、
`42B9-4309` よりは
**descriptor/work 側**
に近い。

ただしここも、
`C1A5-C1AC` の各 byte が完全に切れたわけではない。

現段階では
**descriptor build への移行帯**
として扱うのが安全。

## 4. `4417+` は本当に action class 判定に近い

`4417+` は既報のとおり:

- `AND $1F`
- `CP $12`
- `CP $13`
- `CALL $016B`

を持つ。

この帯は、
`low 5bit class 判定 -> 必要時 RNG`
の構造が強く、
少なくとも battle core で重要な action branch に近い。

したがって battle descriptor の意味論を切るなら、
`42D4-442A` 全域ではなく
**`4417+` を主線**
に置くのがよい。

## 5. 修正後の整理

この correction を入れたうえでの暫定整理はこうなる。

```ts
// 42B9-4309
expandTransformOrPartyRecordIntoC200Side()

// 4329-4349
buildIntermediateDescriptorWork()

// 4417+
classifyActionHeadAndMaybeUseRng()
```

つまり、
以前より `descriptor` の境界が細かくなった。

## 移植への意味

TypeScript の `battle` では、
最初から 1 本の巨大 `buildActionDescriptor()` に詰め込むより、
少なくとも次の 3 段に分ける前提で設計するほうが安全。

```ts
expandPartyRecord()
buildActionWork()
classifyActionAndResolveRng()
```

## 次の一手

1. `4417-4443` を battle core 本線として擬似コード化する
2. `4329-4349` の `DE` ベースが本当に `C1A5` かを追加確認する
3. `42B9-4309` は transformation / party-record side helper として battle descriptor 本線から分離する
