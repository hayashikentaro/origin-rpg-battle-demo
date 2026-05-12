# SaGa2 `C2F6` state gap report

## 対象

- `rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- 既存 `saga2_0198_predicate_report.md`
- 既存 `saga2_0198_cross_cluster_report.md`

## 目的

- `C2F6` の producer を追う
- `0198` predicate の背後状態について、分かったことと未確定点を整理する

## 結論

現時点では、
`C2F6` は **`0198 -> 0608 -> 0661` から読む shared state / table base**
としてはかなり強いが、
**direct writer / direct reader はまだ見つかっていない**。

したがって今いちばん安全な整理は次のとおり。

1. `0198` は `C2F6[0]` 系の先頭状態を見て optional entry presence を返す predicate  
2. `C2F6` 自体は direct `LD (C2F6),A` で更新されるのでなく、別 helper の block copy / bulk init / overlap 再利用で埋まる可能性が高い  
3. そのため `C2F6` の「意味」より先に、「誰がいつこの backing bytes を準備するか」を切る必要がある

## 1. いま確定している read path

`0198 -> 0608`:

```text
0608: LD E,$00
060D: CALL $063E
...
063F: CALL $0661
...
0661: LD A,E
0662: AND $1F
0664: SRL A
0667: LD HL,$C2F6
066A: RST $00
066C: LD A,(HL)
```

少なくとも `0198` 文脈では、
`E=0` 固定なので `C2F6` 先頭近辺を読む。

## 2. direct writer が見つからない

今回改めて見た範囲では、

- `LD (C2F6),A`
- `LD (C2F7),A`
- `LD (C2F8),A`
- `LD (C2F9),A`
- `LD A,(C2F6..C2F9)`
- `LD DE,$C2F6`

の direct hit は見つからなかった。

一方で `HL=$C2F6` の direct hit は `0667` のみ。

つまり `C2F6` は、
少なくとも静的に見える範囲では
**point read はあるが point write が見えない backing bytes**
になっている。

## 3. 何が言えるか

このパターンから安全に言えるのは、
`C2F6` が

- ROM fixed table
- WRAM shared state
- bulk-copied shadow table

のどれかだということ。

ただしアドレスが `C2xx` なので、
現時点では **WRAM shared state / shadow table**
として扱うほうが自然。

## 4. `0198` への影響

`405C` と `633F` の両方で、
`0198` は

- extra iteration を回すか
- zero-clear を省くか

を決める predicate として働いていた。

したがって `C2F6` 自体の producer が未確定でも、
`0198` を

```ts
checkOptionalEntryPresence()
```

のような抽象 API で持つ方針は維持できる。

## 5. 次の一手

1. `C2F6` を含むより大きい `C2E0-C2FF` block の bulk writer を探す
2. `RST $00` / `0080` / `006D` 系の memset/copy helper caller から `C2F6` 周辺を逆引きする
3. `62B4` / `633F` / `405C` の実行前に `C2F6` がどのような状態であるべきかを動的仮説として整理する
