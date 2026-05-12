# SaGa2 `0198` immediate caller cluster report

## 1. 目的

- `0198 -> 0608` を呼ぶ直前の cluster を絞る
- `C2F6` producer 探索を「誰が読むか」の側から狭める

## 2. 結論

`0198` の高確度 immediate caller は、現時点では主に次の 3 系統に集約できる。

1. `6451` 周辺の **shop / selector candidate scan**
2. `62B6` 周辺の **selector-budget spend 判定後の optional rebuild gate**
3. `5E70` 周辺の **UI / selector side optional dispatch gate**

重要なのは、これらの直前 cluster にも
**`C2F6` を明示的に埋める処理はまだ見えていない** ことだ。

つまり `0198` は、
「その時点で既にどこかにある optional-entry presence state を読む consumer」
としてはかなり強い一方、
producer はなお caller 直前 local setup の中には現れていない。

## 3. caller 1: `6451`

`63C0-6500` cluster の中では:

```text
6448: XOR A
6449: CALL $6455
644C: INC A
644D: CP $04
644F: JR C,$6449
6451: CALL $0198
6454: RET Z
```

ここではまず `A=0..3` を回し、
`6455` で `C206 + 16*index` 相当の record を見て candidate scan を行い、
そのあと `0198` で optional entry presence を問うている。

したがって `6451` は:

- `C2F6` を作る場所ではない
- **candidate scan 後に optional slot が有効かを見る gate**

とみるのが自然。

## 4. caller 2: `62B6`

`628A` から入る selector-budget cluster では:

```text
62A4: XOR A
62A5: LD HL,$C745
62A8: LD (HL+),A
62A9: LD (HL+),A
62AA: LD (HL),A
62AB: LD HL,$C207
62AE: LD B,$04
62B0: CALL $630B
62B3: DEC B
62B4: JR NZ,$62B0
62B6: CALL $0198
62B9: CALL NZ,$630B
```

ここで直前に見えているのは:

- `C745` の clear
- `C207` base の 4 件 scan

であり、`C2F6` 自体への write はない。

なので `62B6` も:

- local cluster state を整えたあと
- **optional extra candidate / page の有無だけを `0198` で判定**

しているとみるのが安全。

## 5. caller 3: `5E70`

`5E62-5E76` は:

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

ここでは `FF9B`, `C796` を初期化し、
`01B6` / `RST $08` の UI or selector side setup を行ったうえで
`0198` を呼んでいる。

つまりここも `C2F6` を作っているのでなく、
**UI/selector dispatch を出すべき optional entry があるか**
を見ている流れに見える。

## 6. producer が見えないことの意味

3 系統とも共通しているのは:

- caller 直前で見えるのは local scratch / visible runtime setup
- `C2F6` を base にした clear/copy/write は出ない
- それでも `0198` は即座に呼ばれる

このため `C2F6` backing state は、
少なくとも immediate caller cluster より
**前段の wider shared init**
で準備済みとみるほうが自然。

## 7. 現時点での整理

`0198` はさらに強く:

```text
checkOptionalEntryPresence()
```

相当の consumer helper とみてよい。

いっぽう producer 探索は:

- local caller 直前 setup
- visible zero-fill/copy wrapper

からは離れつつあり、
**shared init / mode transition / overlay reload**
側へ寄せるのが筋になる。

## 8. 次の一手

1. `5E0D/5E35/5E43` を shared mode-transition helper 群として切る  
2. `62A4-62B9` より前の entry path をたどって wider init を探す  
3. `0198` 実行前 snapshot として `C2E0-C2FF` の期待状態を仮説化する
