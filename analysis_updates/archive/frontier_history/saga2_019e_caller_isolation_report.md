# SaGa2 `019E` Caller-Isolation Report

## Summary
- 現在の workspace 上の高確度 evidence で見る限り、`019E` の主 caller は依然として **`611C` inner core** であり、ここを基準に contract を固める方針は維持してよい。
- 既存 report 群でも `019E` は一貫して `01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E` の末尾 commit としてだけ現れており、別 subsystem の visible dispatch / render / selector terminal と直結する強い別 caller はまだ出ていない。
- したがって次に `019E` direct body / writeback を探るときは、`611C` を中心にした caller cluster から下向きに追うのが最も効率的である。

## 1. High-Confidence Caller Baseline

現時点の高確度 caller 文脈:

```asm
6142: CALL $01B9
6145: LDH A,($FF8C)
6147: CP $FF
6149: RET Z
614A: CALL $5F07
614D: LD HL,$C73D
6150: RST $00
6151: LD A,(HL)
6152: CALL $019E
6155: SCF
6156: RET
```

この形が繰り返し参照されているため、
いま `019E` を解釈するときの基準 caller は
**`611C` 一択に近い**
とみてよい。

## 2. What We Do Not Yet Have

逆に、まだ持っていないものもはっきりしている。

- `019E` の direct body
- `019E` への別系統 high-confidence caller
- `019E` が visible state を直接更新する証拠
- `019E` が `C2F6` へ direct write する証拠

この欠け方からすると、
いま無理に `019E` の意味論を広げるより、
**caller isolation を保ったまま commit point として持つ**
ほうが安全である。

## 3. Why This Still Matters

`611C` 側では、

1. `01B9` が token を materialize  
2. `FF8C` が invalid sentinel を持つ current-selection token  
3. `5F07` が local index へ remap  
4. `C73D[index]` が resolved seed byte を供給  
5. `019E` がそれを consume/commit  

という分業がかなり安定している。

したがって、たとえ `019E` の direct body が未確認でも、
**`611C` caller だけで commit frontier として扱う根拠は十分ある**。

## 4. Search Direction That Follows From This

次に `019E` を詰めるときの順序は、次の形で固定してよい。

1. `611C` caller cluster を起点に `019E` 本体/薄い wrapper を探す  
2. そこで writeback destination が見えなければ、`611C` の前後で hidden-local scratch の変化候補を洗う  
3. それでも出なければ、初めて別 caller 仮説を広げる  

いきなり subsystem 横断で `019E` を広げるより、
この順のほうが false positive を減らせる。

## Implication
- `019E` の最重要 caller はまだ `611C` と見てよい
- `019E` direct body 未確認でも、commit frontier 仮説は維持できる
- 次の主戦場は引き続き `611C -> 019E` の下向き探索である
