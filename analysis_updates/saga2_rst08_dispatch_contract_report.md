# SaGa2 `RST $08` dispatch contract report

## 1. 目的

- `RST $08` を `01B6` 後段の dispatch primitive として整理する
- `E` 即値ごとの caller 文脈を束ねて、返り値契約を高位で確定する
- visible selector dispatch と `C2F6` hidden backing state の境界をはっきりさせる

## 2. 結論

現時点の高確度 caller を合わせると、
`RST $08` はかなり自然に
**`E` で command/message/selector entry を選ぶ shared dispatch primitive**
として読める。

今回確度高く言えるのは次の 4 点。

1. `01B6` の直後 `5E6F: RST $08` は **base optional dispatch** 候補  
2. `5E75: RST $08` は `0198` 成功時だけ通る **resolved optional dispatch** 候補  
3. `62BC`, `62EF`, `62FC` の `RST $08` は selector-budget cluster 内で **candidate/event/wait loop** を切り替える高位 dispatch として整合する  
4. これらの caller では `RST $08` 自身が `C2F6` を作るのでなく、すでに用意された visible/local state を **表示・進行・選択イベントへ反映する consumer**

したがって `RST $08` family も、
`C2F6` producer 探索から見ると hidden-state builder ではなく
**visible selector dispatch 側**
として分離してよい。

## 3. caller 1: `5E6F` と `5E75`

もっとも分かりやすい caller は `5E62-5E76`:

```text
5E62: LD DE,$0504
5E65: XOR A
5E66: LDH ($FF9B),A
5E68: XOR A
5E69: LD ($C796),A
5E6C: CALL $01B6
5E6F: RST $08
5E70: CALL $0198
5E73: RET Z
5E74: LD E,D
5E75: RST $08
5E76: RET
```

ここから高確度に言えるのは:

- `01B6` が `RST $08` の前段 setup
- 最初の `RST $08` は `E=$04` を使う base dispatch
- `0198` 成功時だけ `LD E,D` により `E=$05` へ切り替え
- 2 回目の `RST $08` は resolved optional entry dispatch

であることだ。

つまり `RST $08` は、
少なくともこの caller では
**`E` で選ばれた UI/selector action を実行する dispatcher**
とみるのが最も自然。

## 4. caller 2: `62BA/62EF/62FC`

selector-budget cluster では:

```text
62BA: LD E,$1E
62BC: RST $08
...
62ED: E=$1D
62EF: RST $08
62F0: E=$29
62F2: JR $62F9
...
62F9: CALL $01B0
62FC: RST $08
62FD: CALL $0174
6300: CALL $01A7
6303: AND A
6304: JR Z,$62FC
```

ここでは:

- `E=$1E` が current candidate/selectable entry を提示
- success side では `E=$1D` が success-side event/message
- post-event loop では `E=$29` をセットした状態で `62FC: RST $08` を反復

という 3 種類の使い分けが見える。

この構造は、`RST $08` が 1 種の値返し helper というより
**selector/event/message dispatch gateway**
であることを強く示している。

## 5. `01B6` との接続

既報では `01B6` を:

```text
prepareSelectorDispatch()
```

相当と仮置きした。

今回の `RST $08` caller 整理で、それはさらに補強される。

なぜなら `01B6` のすぐ後に来るのが
数値演算でも table build でもなく、
`E` code つきの dispatch だからである。

したがって `01B6 -> RST $08` は:

```ts
prepareSelectorDispatch()
dispatchByCode(E)
```

という並びで読むのが安全。

## 6. 返り値契約

`RST $08` 自身の direct body は未確定だが、
caller から見て安全に言える返り値契約は次の程度である。

1. `RST $08` は `E` の code を消費する  
2. caller の多くは `RST $08` 直後に `A` を直接判定していない  
3. したがって main effect は return value より **side effect と flow progression** にある  
4. 真偽や存在判定は `RST $08` の後に `0198`, `01A7`, `5F07`, `FF8C` など別 helper/状態で読む

つまり `RST $08` は
`returns something small`
より
**`performUiSelectorDispatch(code)`**
として扱うほうが整合する。

## 7. 高位擬似コード

安全な高位擬似コードは次の程度。

```ts
function dispatchOptionalEntryFlow(): void {
  prepareSelectorDispatch()
  dispatchByCode(0x04)
  if (!checkOptionalEntryPresence()) return
  dispatchByCode(0x05)
}

function selectorBudgetStep(): void {
  dispatchByCode(0x1e) // candidate/event prompt
  if (!passesCandidateGate()) {
    dispatchByCode(0x29) // wait/advance loop side
    return
  }
  dispatchByCode(0x1d) // success-side event
}
```

ここでは `dispatchByCode()` の内部が message, selection, sound, redraw のどれを含むかまでは未確定だが、
少なくとも hidden optional backing state の構築ではない。

## 8. `C2F6` 探索への意味

今回さらに強くなったのは次の点である。

1. `01B6` は visible selector dispatch の前段 setup  
2. `RST $08` は `E` code で切り替わる visible dispatch primitive  
3. `0198` はその後段で optional presence を読む consumer

つまり

```text
prepare -> dispatch -> presence-check
```

という 3 段がかなり明確になった。

この 3 段のどこにも `C2F6` を direct に埋める処理は見えていないため、
`C2F6` producer 探索はこの family より前段の
**hidden/shared init / overlay reload / import**
へ寄せるのが安全である。

## 9. 次の一手

1. `RST $08` の direct body を取り、`E` code table の実体を切る  
2. `5E65` と `5EFE` を並べて success/fail event family を整理する  
3. `C2F6` producer 探索は visible dispatch 層を外して hidden/shared init 側へ進める
