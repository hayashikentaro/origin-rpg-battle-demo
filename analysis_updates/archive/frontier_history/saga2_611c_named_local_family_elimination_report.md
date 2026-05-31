# SaGa2 `611C` Named-Local-Family Elimination Report

## Summary
- `611C` core 周辺で現時点までに名前がついている local family は、実質 `C20F`, `C73D`, `FF8C` の 3 本にかなり収束している。
- この 3 本を役割で突き合わせると、`019E` の immediate target として自然に残るのは **この 3 本のどれでもない未命名 local hidden result slot** である。
- つまり次の探索単位は、「`C20F`/`C73D`/`FF8C` の意味をさらに広げること」より、**`611C` core と同じ layer にある未命名 shadow/result family を探すこと** に寄せるのが安全である。

## 1. The Named Local Families Around `611C`

`611C` で高確度に見えている local/state family は次の 3 つ。

1. `C20F + 16*player`  
   player-local selector/candidate workspace
2. `C73D..C744`  
   8-entry local seed table
3. `FF8C`  
   current-selection token storage

これ以外に、`611C` inner core で同程度に役割が見えている
named local family はまだ出ていない。

## 2. Why Each Named Family Falls Short As The Immediate Target

### `C20F`
- `611C` 冒頭で `FF` clear
- workspace / precondition buffer として強い
- selector/high-range path の source 候補でもある

近い候補ではあるが、
現時点の証拠は **結果書き込み先** より
**前提 work area** 側に寄っている。

### `C73D`
- 毎回 `F0..F7` 初期化
- `5F07` 後の local index で読む
- `019E` に渡る 1byte seed source

完全に source table として説明できるため、
first writeback target とみる必要が薄い。

### `FF8C`
- `01B9` が materialize
- `0xFF` invalid sentinel
- `5F07` 前段 token

token storage として十分説明でき、
resolved seed byte commit の直受け先としては遠い。

## 3. What This Elimination Implies

もし `019E` の first writeback が local 側にあるなら、
その置き場所は:

- `C20F` 既知 workspace
- `C73D` source table
- `FF8C` token storage

の外にあるか、
少なくとも **まだ役割が見えていない subfield / shadow byte**
である必要がある。

ここから最も安全な仮説は:

**`611C` core と同じ layer に属する未命名 local result family**

である。

## 4. Why This Is Better Than Forcing `C20F`

`C20F` に無理に寄せると、

- workspace
- candidate source
- result sink

を同じ 16byte record に詰め込みすぎる危険がある。

もちろん実際にそうなっている可能性は残るが、
現時点の evidence だけで first hypothesis にするには重すぎる。

そのため今は、
`C20F` を secondary line に残しつつ、
**未命名 local family を first line**
に置くほうが false positive を減らしやすい。

## 5. Updated Search Framing

今後の `611C -> 019E` 下向き探索は、次の framing で持つのがよい。

1. named family (`C20F/C73D/FF8C`) の role はいったん固定  
2. `019E` immediate target は unnamed local result/shadow family を first guess にする  
3. それが外れた場合のみ `C20F` subfield 仮説を強める  

## Implication
- `611C` 周辺の named local family はかなり出揃っている
- そのどれも `019E` immediate target には決め手がない
- したがって次に狙うべきは未命名 local result/shadow family である
