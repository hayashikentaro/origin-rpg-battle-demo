# SaGa2 `C2F6` hidden-init entrypoints report

## 1. 目的

- `C2F6` producer 探索を hidden/shared init 側へ寄せたうえで、次に当てる入口候補を優先順位付きで整理する
- 既知の visible/runtime 層除外結果を、探索の実行順へ落とし込む

## 2. 結論

ここまでの evidence を踏まえると、
`C2F6` producer の本命は
**visible helper 群の内部ではなく、それらより前段に一度だけ走る wider hidden-state setup**
にある可能性が高い。

現時点での優先順位は次の 4 層で整理するのが自然。

1. **hidden/shared block init**  
   `C2E0-C2FF` を含む larger shadow block をまとめて準備する entry
2. **overlay reload / banked import**  
   visible `C200` transport ではなく、別 shadow region を banked に出し入れする線
3. **mode-entry bulk setup**  
   `0198` caller より十分前段で、一度だけ走る subsystem entry 初期化
4. **runtime overlay alias**  
   `C2F6` が独立 table でなく、別 workspace の tail/overlay として再利用される線

逆に、visible selector/event/mode-transition helper 群は、
今後の `C2F6` producer 探索の主戦場から外してよい。

## 3. 入口候補のランク付け

### A. 最優先: larger hidden block init

もっとも有力なのは、
`C2F6` を point write せずに済ませる
**larger WRAM block 単位の hidden init**
である。

この仮説が強い理由は:

1. `0667: LD HL,$C2F6` 以外の direct base が見えていない  
2. `006D/0072/00B5/00BC` の既知高確度 caller は visible/runtime 側に偏っている  
3. `C2F6` を含む `C2E0-C2FF` clear/copy がまったく見えていない

したがって最初に当てるべきは、
`C2F6` 単体ではなく
**`C2E0-C2FF` 全域をまたぐ hidden-state entry**
である。

### B. 次点: overlay reload / banked import

次に疑うべきは、
`C200 <-> A600` の visible transport cluster とは別の
**shadow-only banked import/export**
である。

既報 `saga2_c200_export_import_cluster_report.md` により、
`6748-6803` は visible `C200` block transport として切り離せた。

逆に言えば、
`C2F6` producer は
**別の banked reload path**
に残っている可能性が高い。

特に:

- direct point write がない
- static visible caller にも出ない

という条件は、
overlay reload 的な一括復元と相性がよい。

### C. 3番手: mode-entry bulk setup

`0198` の caller 直前では見えなくても、
subsystem 入口で一度だけ hidden state を整える線はまだ残っている。

ここでは例えば:

- menu / selector mode に入るとき
- optional entry 付き subsystem へ遷移するとき
- import/export 直後に shadow state を再構成するとき

などの **entry-point bulk setup** が候補になる。

この線は `5E0D-5F44` の visible mode-transition helper より
さらに前段にあるはずなので、
visible reset family を固定できた今、追いやすくなっている。

### D. 補助仮説: runtime overlay alias

最後に残るのは、
`C2F6` が独立テーブルですらなく、
**別 workspace の tail region として重なっている**
可能性である。

これは direct write が見えないことと整合するが、
いまは検証材料がまだ薄い。

したがって探索順としては:

1. 独立 hidden block init
2. banked reload
3. subsystem entry setup

を先に当て、それでも出なければ alias 仮説を強めるのがよい。

## 4. 逆に優先度を落としてよい線

既報を統合すると、次の線は producer 探索の主戦場からかなり外せる。

1. `5E31/5E35/5E40`, `5E0D-5F44` の visible reset/refresh family  
2. `01B0/01B3/01B6 -> RST $08 -> 0198` の visible dispatch family  
3. `5E65/5EFE` の success/fail event family  
4. `C200 <-> A600` の visible import/export cluster  
5. `C200/C20F/C2B9/C7E0/C760/C785` 周辺の既知 visible/runtime workspace 操作

もちろん補助証拠として参照する価値はあるが、
producer を直接見つける線としては優先度が低い。

## 5. 実務的な次の探索順

次のターンからの実行順は、次のように切るのがよい。

1. `C2E0-C2FF` を含みうる wider WRAM block init 候補を先に抽出する  
2. その中で visible `C200` transport を除外する  
3. 残った cluster を subsystem entry / overlay reload / hidden import に分類する  
4. その後に必要なら alias 仮説へ進む

## 6. 移植上の意味

移植側では引き続き:

```ts
checkOptionalEntryPresence()
```

を abstract API で持てばよく、
backing state の producer は後から差し替え可能な hidden-state provider として扱うのが安全。

つまり今の段階で重要なのは、
`C2F6` の exact bytes より
**探索対象の層を誤らないこと**
である。

## 7. 次の一手

1. wider hidden-state init 候補を「entrypoint report」として具体 cluster 単位に洗う  
2. visible `C200` transport 以外の banked import/export 候補を抽出する  
3. `C2F6` を含む hidden shadow block のサイズ仮説を `C2E0-C2FF` 基準で明文化する
