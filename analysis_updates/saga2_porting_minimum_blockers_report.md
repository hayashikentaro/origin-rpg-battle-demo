# SaGa2 Porting Minimum Blockers Report

## Summary
- 現在の解析状況から見ると、移植に必要な未確定点は「全部の ROM 意味論」ではなく、**TypeScript core の API を確定するための最小集合** にかなり絞れている。
- その最小集合の中心は、`019E` が確定する success-side local meaning と、battle 本線での RNG slot 消費順である。
- したがって次の解析は、`019E` 後段 local state を battle 本線へ接続する線を最優先にすれば、移植可能性へ最短で近づける。

## 1. Already Stable Enough For Porting

少なくとも次は、移植設計の土台としてかなり安定している。

1. `611C` は player-local seed/selection gate  
2. inner core は `01B9 -> FF8C -> 5F07 -> C73D[index] -> 019E`
3. `FF8C` は current-selection token  
4. `C73D..C744` は local 8-entry seed table  
5. `6157` は後段 apply/staging helper

このため、移植側ではすでに:

- `selection token`
- `local seed remap`
- `post-resolve / pre-apply local state`

という抽象は切り出せる。

## 2. Minimum Blockers

### A. `019E` の success-side local state

まだ必要なこと:

- `019E` が確定する local meaning の正体
- それが outcome byte / marker / short pair のどれに近いか

これは `rng` 単体のためというより、
**battle.resolveAction(...)` の中間 state**
を決めるために必要。

### B. battle 本線の RNG slot 消費順

まだ必要なこと:

- 命中
- ダメージ
- 対象選択
- 行動順

で、どの slot をどの順に使うか。

これが確定しないと、
`rng.next(slot, range?)`
の実使用契約がまだ弱い。

### C. action descriptor の最終 struct

まだ必要なこと:

- `C1A5-C1AC`
- `D?43-46`

などが最終的に何を表すか。

これがないと、Godot 側から core に渡す
`resolveAction(input)` の形が完全には固まらない。

## 3. What Is No Longer A Hard Blocker

次は、移植の最小条件としては後回しでよい。

- particle/effect RNG の完全再現
- `C2F6` producer の全容解明
- `C21F` richer field の確定
- input/wait helper の細部
- growth/transform の未着手細部

これらは精度向上には効くが、
まず core API を立てる段階の blocker ではない。

## 4. Practical Next Step

最短線は次の 1 本に絞れる。

1. `019E` が確定する success-side local state を取る  
2. その local state が battle 本線のどこで読まれるかを見る  
3. そこから RNG slot 消費順と action resolve 中間 state を確定する  

## Implication
- 移植の本当の blocker は少ない
- いま追っている `019E` 線は、そのまま core API 仕様の確定に直結している
- 次の最優先は `019E` 後段 local state の battle-side consumer である
