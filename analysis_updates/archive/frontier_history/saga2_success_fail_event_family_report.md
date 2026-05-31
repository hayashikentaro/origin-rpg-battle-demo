# SaGa2 `5E65/5EFE` success-fail event family report

## 1. 目的

- `62A2-6330` cluster 内の success / fail side event helper を切り分ける
- `RST $08` dispatch contract と合わせて event-layer の責務を整理する
- visible event 層と `C2F6` hidden backing state の境界をさらに明確にする

## 2. 結論

現時点の caller 文脈からは、
`5E65` と `5EFE` はかなり自然に
**selector-budget cluster の success / fail event family**
として分けて持てる。

今回確度高く言えるのは次の 4 点。

1. `62E7: CALL $5E65(DE=$1C1B)` は success path 専用  
2. `62F4: CALL $5EFE` は fail path 専用  
3. どちらも後続 `RST $08` と組み合わさって event/message/visible feedback を出している可能性が高い  
4. この event family も `C2F6` を生成する層ではなく、**budget 判定後の visible side effect**

したがって selector-budget cluster は:

- budget compare / spend
- success/fail event helper
- `RST $08` dispatch / wait loop

の 3 段として分けるのが安全である。

## 3. success path

既報 cluster:

```text
62DA: CALL $0165
62DD: LD A,$33
62DF: LDH ($FFB2),A
62E1: CALL $6332
62E4: CALL $5E35
62E7: LD DE,$1C1B
62EA: CALL $5E65
62ED: LD E,$1D
62EF: RST $08
62F0: LD E,$29
62F2: JR $62F9
```

ここで success path は:

1. `C2A2 -= C745`
2. `6332` で rebuild
3. `5E35` で visible reset
4. `DE=$1C1B` を伴って `5E65`
5. `E=$1D ; RST $08`

の順に進む。

この構造から言えるのは、
`5E65` が rebuild 後の visible state を受けて
**success-side event payload を整える helper**
である可能性が高いことだ。

少なくともこれは:

- budget/spend 本体
- hidden optional state build

ではなく、
**success feedback/event 準備**
に属する。

## 4. fail path

fail path はより短い:

```text
62D5: CALL $0168
62D8: JR C,$62F4
...
62F4: CALL $5EFE
62F7: LD E,$1F
62F9: CALL $01B0
62FC: RST $08
```

ここでは compare 失敗で直ちに `5EFE` へ落ち、
その後 `E=$1F` として post-event dispatch へ入る。

この構造から `5EFE` は
**fail-side local event state / message state 準備**
とみるのが自然。

success path に `5E65 + E=$1D` があり、
fail path に `5EFE + E=$1F` がある対称性も、
この読みをかなり補強する。

## 5. `RST $08` との関係

既報 `saga2_rst08_dispatch_contract_report.md` では、
`RST $08` は `E` code つき visible dispatch primitive と整理した。

今回の success/fail family を重ねると、
この周辺はかなり自然に:

```ts
if (success) {
  rebuildRuntime()
  resetVisibleScratch()
  prepareSuccessEvent(payload = 0x1c1b)
  dispatchByCode(0x1d)
} else {
  prepareFailEvent()
  dispatchByCode(0x1f)
}

dispatchByCode(0x29) // post-event wait/advance loop
```

のように読める。

つまり `5E65/5EFE` は
`RST $08` の代替ではなく、
**dispatch 前の event payload / state builder**
として分離して持つほうがよい。

## 6. `C2F6` 探索への意味

この整理でさらに強くなったのは次の点である。

1. `01B6 -> RST $08` は visible selector dispatch  
2. `5E65/5EFE` は visible success/fail event 準備  
3. `0198` は optional presence consumer

つまり `62A2-6330` 周辺で見えているのは、
ほぼ一貫して **visible selection/event progression** である。

この層でも `C2F6` を direct に埋める clear/copy/write は見えていないため、
`C2F6` producer 探索はさらに安心して
hidden/shared init / overlay reload / import 側へ寄せられる。

## 7. 次の一手

1. `RST $08` direct body を取って `E=$1D/$1E/$1F/$29` code table の実体を切る  
2. `5E65` の caller を他にも探して payload `DE=$1C1B` の意味を詰める  
3. `C2F6` producer 探索は event/dispatch 層を外して hidden/shared state init に集中する
