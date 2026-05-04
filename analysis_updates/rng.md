# RNG Module

## 対象

TypeScript `rng` モジュールで再現する領域。

- 戦闘ダメージや分岐に使う乱数供給
- 将来的な成長 / ドロップ / 変身補助乱数

## 現時点の直接ソース

- `reports/saga2_damage_formula_pass21_report.md`
- `reports/Saga2DamageModelPass21.gd`
- `reports/Saga2DamagePipelinePass22.gd`
- `reports/saga2_growth_rng_structural_report.md`
- `reports/saga2_growth_rng_structures.json`
- `reports/saga2_random_seeds_callers_report.md`
- `reports/saga2_rng_entrypoints_report.md`
- `reports/saga2_rng_wait_io_report.md`
- `reports/saga2_ff89_behavior_report.md`
- `reports/saga2_0469_state_machine_report.md`
- `reports/saga2_input_wrappers_report.md`
- `reports/saga2_rng_battle_reachability_report.md`
- `reports/saga2_043e_contract_report.md`
- `reports/saga2_0306_divmod_report.md`
- `reports/saga2_02f0_mul_report.md`
- `reports/saga2_043e_callsite_report.md`
- `reports/saga2_rst10_report.md`
- `reports/saga2_rst18_report.md`
- `reports/saga2_rng_slot_classification_report.md`
- `reports/saga2_rng_battle_slot33_report.md`
- `reports/saga2_particle_state_machine_report.md`
- `reports/saga2_rng_slot07_08_offset_report.md`
- `reports/saga2_rng_damage_core_gap_report.md`
- `reports/saga2_normal_attack_entry_gap_report.md`
- `reports/saga2_battle_runtime_entry_report.md`
- `reports/saga2_battle_state_helpers_report.md`

## ROM から直接確定した構造

- `data_rng` は `bank $0F:$4000` の 256 byte table
- 次ラベル `data_sine` が `0x4100` にあるため、サイズはちょうど 256 byte
- テーブルは `0x00-0xFF` を一度ずつ含む順列になっている
- `00:0440` 付近に `random_seeds ($C0A0)` を increment して `0F:40xx` を引く強い参照候補がある
- `00:0258` 付近に `random_seeds ($C0A0)` を 64 byte 初期化する強い参照候補がある
- `00:0258` は起動シーケンスから fallthrough で到達する
- `00:0469` は `00:0493` / `00:0CC8` などの wrapper が存在する入力 repeat 制御候補
- `00:068F` は RNG 専用ではなく、入力待ち / フレーム更新の共有ルーチン候補
- `FF8A` は wrapper の戻り値に使われる有効入力値候補
- `FF89` は `00:0469` の分岐条件に使われる入力/状態フラグ候補
- `FF89` は `00:29A3` で 0..4 の方向 index 風値へ変換されるため、direction/button bitfield の可能性が高い
- `C774=0x1E/0x05` は key repeat の初回遅延 / 連続間隔候補
- `00:049D` / `00:04A6` は `FF89==0` を待つ input release wrapper 候補
- `00:043E` は dispatch table 公開入口候補で、`0440` はその内部本体の可能性が高い
- `00:043E` は `A=seed slot` と `D/E=range` を受け、`data_rng` 生値を modulo で範囲縮小して `A` で返す helper 候補
- callsite では `DE=$FF00/$0300/$0F00` が現れ、`E=lower`, `D=upper` の向きが強く支持される
- `00:0306` は `H/L -> quotient,remainder` の div/mod helper 候補で、`043E` は remainder 側を使っている可能性が高い
- `00:02F0` は `H*L -> HL` の 8bit multiply helper 候補
- `RST $10` は `06B0` 実行後に VBlank 近辺まで待つ frame sync helper 候補
- `RST $18` は `A` を DMA source page として OAM DMA を起動する helper 候補
- `00:068F` は `RST $18` を使って OAM staging page を OAM へ反映している可能性が高い
- slot `07/08` は battle / item 系 caller、`0C/0D` は 0..1 binary pair caller、`00/01/09/0A/20` は action / field / script 側 caller で見えている
- bank `0D:4440` の slot `07/08` は上位/下位 byte を別々に引いて 16bit offset を作り、`HL` から差し引く pair RNG の可能性が高い
- bank `0D:5741` では slot `33` が `DE=$1300` とともに使われ、battle 側で `0..19` index を生成している可能性が高い
- `56C0` クラスタは `window_buffer_1.particle_*` を使う particle system で、slot `33` は particle 初期配置 RNG の可能性が高い
- battle runtime helper `0D:435A` は actor page 群の同 offset byte 合計 helper 候補
- battle runtime helper `0D:4361` は bank `0C:4680 + index*2` の 2 byte table を引く state/descriptor dispatch helper 候補
- `0D:4178` 以降の `actors ($D803)` は `0xFF` sentinel の 2 byte queue entry 群候補で、action resolve 前処理に見える
- `01E3` は `JP $18CE -> CALL $04BF ; 03 5D 0F ; RET` の thin wrapper で、battle queue 中の固定 dispatch hook 候補
- `437E` は `D0xx..D4xx` actor page を `C206` ベース work buffer へ正規化展開する state staging helper 候補
- `4579` は `D040` 付近の battle stat bits を走査して `actors ($D803)` へ 2 byte entry を積む queue builder 候補
- `0D:43FB-443A` は 9 個の 16bit entry を走査し、`0C:6F82 + entry*8` から 2 byte の集約 flag を作る prepass helper 候補
- より具体的には `43FB-443A` は `D?2D/D?2E` を 0 初期化し、9 個の 2byte entry から `0D:6F82 + entry*8` の 8byte record を引き、先頭 byte の `0x30` class bits に応じて record 4 byte 目を `D?2D` または `D?2E` へ OR fold する helper と読むのが自然
- `40BC: CALL $43FA` の caller から見ると、この 9件 list の実体は `BC` ではなく `HL` 入力で、`HL=$D012` から始めて `INC H` しながら 8 page (`D012..D712`) に対して回している可能性が高い
- さらに `4090-40B4` では `C2DA` の 14 個の 2byte entry を走査し、high nibble で選んだ `D?` page の `+2A/+2B/+2C` に `sourceIndex / 01 / payload` を書く seed/setup loop が見えている
- `C2DA` の producer 候補としては `01:634A-6365` の low-nibble 条件 writer と `01:5B70-5B91` の packed-entry builder が有力で、battle prepass 用の 14件 tableは複数 helperで段階的に組まれている可能性が高い
- `01:5B95` と `01:60E2` はどちらも実質 `C21F + 16 * index` を返す同型 helper とみられ、`C2DA` high nibble は `C21F` 側 16byte block selector としても使われている可能性が高い
- `01:60C0-60E1` は 2byte entry 列を 14 件走査し、low nibble 非 0 entry について `C21F + 16*block` の offset `+0` に `sourceIndex C` を書く block builder と読むのが自然
- `0D:443B-4499` は battle work record から base pointer / span を取り、slot `07/08` で 16bit signed offset を作って pointer record へ書き戻す battle/RNG bridge 候補
- `449A-44F3` は record expansion helper 風だが、`443B-4499` の continuation とまではまだ確定していない
- `4024-4075` 実バイトから、`44F4` caller は `D5xx` 3-page source loop、`443A` caller は `D500/D600/D700` 3-page prepass loop、さらに中間に `D0xx` 5-page staging loopがあると読める
- `1918` は `JP $1B99` wrapper で、`1B99` は `party_order ($C2A0)` の 2-bit field から `HL += 0x20 * slot` を作る address helper 候補
- `44F4-4575` は `D?xx` page の low offsets と `0F:6EC0` / `0D:6F80` table を使って `DE00` scratch record を組む deterministic staging helper 候補
- `44F4` が作る `DE10` は直後に `D849/D949/DA49` family へ書き戻されるため、`DE00` は battle controller へ戻る staging record の可能性が高い
- `4024-403E` で `DE10 -> D849/D94A/D94B` 相当の metadata writeback を行い、`4048-405A` では `D0xx` 5-page loop で `1918` と `449A` を呼び、その後 `4067-4075` で `D500/D600/D700` に対して `443A` を回す
- `449A-44EE` は `HL` source から `D?00-20` / `D?40` 付近の page-local battle work layout へ fixed record を展開する deterministic expander 候補
- `common.i` と照合すると `449A` / `437E` / `actors` loop は `D?40=status`, `D?43=item_id`, `D?45 target近辺`, `D?12..=inventory起点` でかなり整合し、`D0xx` page を戦闘用 working set とみるのが自然
- `D?43/44/45/46` は `00D2 -> C1A5-C1AC` small descriptor とかなり自然に重なり、`item_id / param / target / slot_index` 系の compact action head とみるのが現時点で最も安全
- ただし `42D4-442A` 全域をそのまま `C1A5-C1AC` build とみなすのは粗く、`42B9-4309` は `C200` / transformation 側、`4417+` は action class 判定側として分けて追うほうが安全
- さらに `4417` という番地は `43FB-443A` の内部 `CALL $00D2` 着地点にも現れるため、prepass helper 内部の `4417` と battle core の `443B+` / class 判定帯を混同しないほうが安全
- そのため以前の「`BC=$D500` が `443A` caller page family」という整理は弱く、`43FA-443A` の主入力はむしろ `D?12..` slot list として扱うほうが安全
- `43FA` の直前には `D?2A/2B/2C` を埋める deterministic prepare step もあるため、battle.data page の prepass は `seed pages -> fold slot classes` の 2段で見るほうが安全
- `C2DA` の各 entry は現時点では `high nibble = page selector`, `low nibble = kind/slot id`, `byte1 = payload` の packed seed entry と仮置きするのが最も整合する
- `C21F` は battle prepass 中間の 16byte-block table base 候補で、少なくとも block offset `+0` に source index / owner index 類を持つ可能性が高い
- `60B8` から `60C0` へ fallthrough する直前で `HL=$C2DA`, `DE=$C7E0`, `BC=$0E00` が積まれているため、`60C0-60E1` の flat sentinel list は `C7E0..C7ED` の 14 byte とみてよい
- ただし `01:5B64-5B90` に `C7E0` を `FF` 埋めしたうえで `C2DA` high nibble 0 entry の source index を flat に詰めるほぼ同型 builder があるため、`C7E0` を battle 専用 scratch とみなすのは危険
- bank0 `1237-124B` と `10B2-10C2` でも `HL=$C7E0 + index ; LD A,(HL) ; CP $FF` の read path があり、`C7E0..C7ED` は item / magi / selection setup をまたぐ共有 14-byte candidate list とみるほうが安全
- したがって `C7E0` は `common.i` 上の `script_arg_magi` という名前より広く、shared selection workspace / sparse candidate list として扱うほうが移植上安全
- `1237-124B` (`script opcode 0x1D`) と `109F-10C2` (`script opcode 0x1C`) はどちらも low-range selector を `C7E0 + index` へ通しており、`LD A,(HL); CP $FF` の形から `C7E0` 各 entry は候補IDより `resolved source slot / physical slot index` を返す sparse remap table とみるほうが自然
- したがって現時点では `C7E0[logicalIndex] = physicalSlotIndex | 0xFF` という shared selector workspace 仮説が最も整合する
- `10CC` は単独 helper というより high-range selector dispatcher 本体で、`C71D`, `C2B9`, player inventory-derived pointer, `D906` pointer table など複数経路を `HL -> 1byte candidate ; A=(HL); CP $FF` という共通契約へ正規化している可能性が高い
- このため `C7E0` low-range path も `10CC` high-range path と同じく、「最終 1byte candidate value を返す selector 経路のひとつ」とみるのが安全
- `1551/1552/1554` は `10CC` の resolver 本体ではなく、selector で得た 1byte/16bit 値を bank `0F` の `8byte` record table (`6640` / `6EC0`) に通して `C785` 表示バッファへ展開する terminal helper 群とみるのが自然
- より具体的には `1551` は `(HL)` の 1byte index を、`1552` は `L` の 1byte index を、`1554` は `HL` の index 値をそのまま使い、共通本体で `DE + index*8` を bank `0F` から引いて `15B1` で `C785` へ 0-terminated buffer 化している可能性が高い
- `15B1` は trailing `FF` を落としつつ `C785` を組む text buffer helper、`15CE-15F1` は別系統の numeric formatter とみるほうが自然で、selector 解決と presentation terminal を分けて扱うのが移植上安全
- `1237` 後段では low-range / high-range selector の返り値 1byte を `ADD A,A ; HL=$C2DA ; RST $00` で `C2DA[index*2]` へ通しているため、`C71D` / `C2B9` / `C7E0` はいずれも `C2DA` 14件 table の entry index として使える shared source index 空間を返している可能性が高い
- 同じ返り値は `109F/10D4` 側では `6640` / `6EC0` の 8byte name record table index としてもそのまま使われており、`C2DA` packed entry と name table が同一 source index 空間上で対応づいている可能性が高い
- `1237` では selector 返り値 index で引いた `C2DA[index*2]` の low nibble を `15CE` numeric formatter へ渡しているため、shared source index は単なる name ID ではなく、`C2DA` packed entry と UI 表示の両方へ接続する key とみるのがより自然
- `6640` / `6EC0` 自体は `FF` padding を含む `8byte` fixed-length record table とかなり強く読め、少なくとも script/item selector 系では `resolved source index -> text record` の presentation lookup を担っている可能性が高い
- caller 分類で見ると、`6EC0` は `104B-10C9` cluster の inventory / script-arg / dynamic slot 解決寄り文脈に集中し、`6640` は `10D4-1169` cluster の high-range selector / fixed table / entity-class 解決寄り文脈に集中している
- したがって移植時は `ResolvedSourceIndex` 自体は共通化しつつ、presentation lookup は `6EC0` 側と `6640` 側で分けて持つほうが安全
- ただし `C71D` / `C2B9` 自体は ROM static table より WRAM runtime selector buffers とみるほうが自然になってきた。`C71D` には direct write (`3F08`) があり、`6493-64A8` では 8 件 * 2 byte の pair table が明示的に構築され、`C2B9` には clear / scan / read helper がそろっている
- したがって以前の「`C71D/C2B9` は fixed selector table」という整理は弱く、`10CC` high-range 側も ROM 定数 selector というより事前構築済み WRAM selector buffers を読む reader として扱うのが安全
- さらに `C71D` builder は少なくとも `3F08-3F1C` の single-entry writer 系と `6493-64A8` の 8-entry bulk builder 系に分かれて見えるため、同じ backing buffer を複数 subsystem が上書き再利用している可能性が高い
- どちらも pair byte0 を主たる `sourceIndex` として持ち、byte1 は `0C:7E80 + sourceIndex` 由来の補助 byte 候補なので、移植時は `C71D` storage と builder API を分けて持つほうが安全
- `C2B9` も `6797-679C` の全体 clear、`663F-6646` の単一 entry tombstone、`6657-6668` の active scan、`5D84/65CA/1155` の reader がそろっており、fixed selector table より 16 件 * 2 byte の mutable workspace と見るほうが自然
- したがって selector-runtime は少なくとも `presentation-oriented C71D` と `stateful candidate workspace C2B9` を分けて持つ設計が安全
- `65C9-65E0` は `C2B9[index]` を `C73B/C73C/C760` へ正規化する decode bridge とみるのが自然で、`byte0` は `FF` sentinel を持つ primary `sourceIndex`、`byte1` は `0C:7E80 + sourceIndex` 由来 byte と比較される aux/class byte 候補として読むのが最も整合する
- さらに `6669` は `sourceIndex` を `0F:7860 + index*2` 系の `3byte` descriptor に展開して `C760` へコピーしている可能性が高く、`C2B9` から presentation/usage 側へは直接ではなく decode scratch を一段挟む設計が安全
- `0F:7860` の先頭 dump では 3byte record がすべて `xx yy 00` になっており、`6669` が `C760` へコピーしているのは opaque descriptor というより `little-endian 16bit value + 00 pad` とみるほうが自然
- したがって `C2B9` decode bridge は、`sourceIndex -> value16 lookup (7860)` と `classByte` 比較/補正を束ねる段として持つのが実装寄り
- `65F8-6618` の差異補正部では `0183 -> 040B` が `C760` 3byte scratch の `24bit / 8bit` 除算 helper、`0180 -> 03DC` が `24-step shift/add` の乗算/拡張 helper と読むのが最も整合する
- mismatch 時の順序は `divideBy(canonicalByte from 0C:7E80[sourceIndex]) -> multiplyBy(entry byte C73C) -> divideBy(2)` に見えるため、`C2B9.byte1` は単なる aux byte ではなく `value16/24` を再スケールする class/rank byte 候補へ上がった
- `6610-6618` では補正後の `C760` low 3byte がすべて 0 のとき byte0 を `01` へ clamp しているため、この scratch は opaque descriptor より quantity/value 系の数量 scratch とみるほうが自然
- `6632: DE=$C2A2, HL=$C760, CALL $0162` は `0162 -> 0390` の 3byte add helper を通して `C2A2 += C760` を行う immediate consumer 候補で、`C760` は採用された candidate の value scratch とみるのが最も整合する
- その直後 `663B-6647` では `C70D` current index で引いた `C2B9[index]` を `FF,FF` tombstone 化しており、selector-runtime は `decode -> rescale -> clamp -> accumulate -> tombstone` の 1サイクルで current candidate を消費している可能性が高い
- `0165 -> 03A6` は `[DE] -= [HL]` の 3byte subtract helper、`0168 -> 03BC` は carry を `dst < src` に使う 3byte compare helperとみるのが自然で、`C2A2` を扱う helper family は `add / subtract / compare` まで一通り揃っている
- 実際に `62D1: DE=$C2A2, HL=$C745, CALL $0168 ; JR C,... ; CALL $0165` と `6554: DE=$C2A2, HL=$C70A, CALL $0168 ; JR C,... ; CALL $0165` が見えているため、`C2A2` は単なる accumulator ではなく後段で candidate value と比較・減算される 3byte budget/pool とみるほうが整合する
- `6548-6554` では `DE=$C70A` に `CALL $6669` を当てた直後に `HL=$C70A` で compare/subtract しているため、`C70A` は current sourceIndex から都度作る単発 3byte cost/value scratch とみるのが自然
- いっぽう `64B0-64BC` では `HL=$C71D`, `DE=$C745`, `B=$08` で `CALL $6669` を 8 回回しており、`6669` が `DE` を 3 byte 進めることを踏まえると `C745` は単一値より 3byte cost table base とみるほうが整合する
- ただし `6310-632D` では `0156 -> 0376` の 16bit subtract helperで得た delta を `C745/C746` に `ADD HL,DE` して書き戻しているため、この局面の `C745/C746` は少なくとも pointer/head workspace として使われている
- したがって `C745` は単一の固定 struct より、phase に応じて `cost head / table base / pointer head` を再利用する selector workspace として扱うほうが安全
- `62A2-6330` 全体を見ると、cluster は `C745` head clear -> `630B` による record scan/head update -> candidate gate -> `C2A2` vs `C745` spend判定 -> success/fail side effect -> `0174/01A7` advance loop、という高位 selector-budget flow にかなり自然にまとまる
- このため `C2A2` / `C745` / `C70A` / `C71D` は単独変数としてより、phase-based selector cluster state としてまとめて持つほうが移植上安全
- `62DD: CALL $6332` の success-side helper は、`C709` を保存しつつ `0..3` player loop を回し、`C206/C204/C20F/C785` を巻き込む `636C` worker と、`C2DA` 14件に対する `0C:7F80` 再正規化 pass を持つ post-success rebuild helper 候補とみるのが自然
- したがって success path は単なる演出ではなく、budget spend 後に selector/runtime tables を再構築する段を含んでいる可能性が高い
- `019B -> 05D9` は `FF8B` mode で stride を切り替える index helper とみるのが自然で、通常経路では `party_order ($C2A0)` 経由の `base + 16*index`、別経路では `base + 0x100*index` を作っている可能性が高い
- したがって `6332` の `C206/C204/C20F` は少なくともこの文脈では 16byte stride の player-local record 群として読むのが整合しやすい
- `0198 -> 0608` は `E=0` 固定で `063E -> 0661 -> C2F6` 系 table を見る predicate helper 候補で、caller では `AND A` / `JR Z` による真偽判定として使われている
- このため `6332` の `633F: CALL $0198 ; JR Z,$6347 ; CALL $636C` は、「通常の 4 回 loop に加えて、predicate が真のときだけ追加でもう 1 件 rebuild する」と読むのが安全
- `405C` 側でも `CALL $0198` の結果で `D400/D401` clear を入れるかどうかを切り替えているため、`0198` の subsystem 共通意味は heavy check より `optional page/slot/entry presence predicate` とみるほうが整合する
- したがって移植時は `checkOptionalEntryPresence()` くらいの抽象 API として battle/selector の両側から共有するのが安全
- いっぽう `C2F6` 自体は現時点で direct writer / direct reader がほぼ見えず、`0198` から point read される shared state / shadow table に見えるため、producer は point write より bulk init / block copy 側を疑うほうが安全
- bank0 helper 群では `0080` が `HL -> DE` の `B` byte copy、`0089` が `HL -> DE` の `BC` byte copy、`006D` が zero-fill 本体とかなり自然に読めるため、`C2F6` producer 探索は direct store から `C2E0-C2FF` をまたぐ bulk copy/fill caller 探索へ切り替えるのが筋がよい
- 現時点で `0080/0089` caller の `C2xx` 近傍 high-confidence cluster は主に `C200/C20F` 側に偏っており、`C2F6` を直接含む base/copy はまだ見えていないため、`C2F6` は visible player-local record 直系より別レイヤの shared optional-entry state とみるほうが整合する
- `C2xx` を destination にする bulk copy caller を見ても、高確度なのは `A600 <-> C200` の large copy cluster で、`C2F6` を含む `C2E0-C2FF` base copy は依然として未検出だったため、`C2F6` は visible/local record export-import とも別レイヤの hidden shadow state である可能性がさらに上がった
- `607A-6087` には `C2DA` 先頭 byte を low nibble のみに正規化する in-place pass があり、`6087-60A2` には `C21F` block head を `((block+1)<<4) | lowNibble` 風に再構築する helper が見えている
- `60AA-60B7` は `C21F` の最初の 4 block head を `FF` で clear する隣接 helper とみるほうが安全で、`60B8-60E1` と同一処理に潰さないほうがよい
- `60E8-611B` は `player_index ($C709)` を 1..3 で回しながら `611C` と `6157` を呼ぶ player-by-player orchestration loop 候補
- `611C` は `C20F + 16*player` を `FF` 埋めし、`C73D..C744` を `F0..F7` で初期化してから `FF8C` ベースの選択/検証を行う helper 候補
- `6157` は `C200 + 16*player` と `C7EE` の 4 byte scratch copy を含み、さらに `D400/D500` family を巻き込む後段 staging helper 候補
- `61EB-61FB` に `C7EE -> C200 + 16*player` の逆向き copy があるため、`C7EE` は `60C0` builder の flat sentinel list ではなく player-local scratch header とみるほうが安全
- `405C-4066` には `CALL $0198` と条件付き `D400/D401` clear があり、従来の「単なる phase switch」より一段具体的な cluster 中継部だった
- ただし現時点では `D849/D949/DA49` の direct readback は未確認で、隣接する `D84D + 2*n` lookup 系とは分けて扱うほうが安全
- `45A8` は `DE` source から 2 byte pair を `HL` 側 page-stride で書く generic scatter writer に見え、`D849` family の direct consumer とみなす根拠は弱い
- `4361` dispatch 先と `449A-44F3` 側からも、現時点では `D849/D949/DA49` の direct readback は未確認

したがって、これは単純な seed 値保存域ではなく、lookup/permutation 型の補助表である可能性が高いです。

## 現状

乱数ルーチン単体の実行フローはまだ未確定です。ただし、battle 側の仮説だけだった状態から、少なくとも ROM 上に専用 256 byte table があることは確認できました。

- ダメージ算出で `rng & 0x03` 相当の分散を使う仮説がある
- 乱数値そのものは table 参照や index 更新を伴う可能性がある
- 少なくとも 1 本は RAM seed byte -> `data_rng` lookup の形が見えている
- `random_seeds` への direct 参照は現時点で `00:0258` と `00:0440` の 2 箇所のみ確認
- direct call/jp は `00:0440` ではなく `00:0469` に集まっている
- ただし `0469` は RNG API ではなく、待機/入力制御の key repeat ルーチンとして読むほうが自然になった
- したがって `0440` と `0469` は ROM 上で隣接していても、論理的には別責務の可能性がある
- `0CC4` 周辺は fresh input wait の高位 API と見なすほうが自然
- `043E/0469/049D` は usage handler 側の dispatch table に載るため、battle 専用 helper と断定する根拠は弱い
- `RST $28 -> 04B1` は ROM bank swap helper で、`043E` の `0F:4000` 参照を支えている
- したがって `043E` の一般ケースは unbiased scale より `raw % span + lower` に近い可能性がある
- `02F0-0306` は bank0 arithmetic helper 帯として読める
- `068F` は `RST $10` と `RST $18` を下位 primitive に持つ高位 wait/update/OAM flush routine と見なせる
- `043E` の slot は少なくとも単一用途ではなく、caller cluster ごとに使い分けられている可能性が高い
- battle 側には少なくとも slot `07/08` に加えて slot `33` caller が存在する
- ただし slot `07/08` も pointer / position offset 生成寄りで、damage core とは別責務の可能性がある
- ただし slot `33` は battle logic 本体より演出 particle 側に属する可能性が高い
- 既存 pass21-23 の damage 主線候補では `016B/043E` が未検出で、core damage / hit 用 RNG slot は別系統の可能性が高い
- pass19 の高スコア routine には data 誤読や effect/setup 側候補が混ざり、通常攻撃 entry の起点としては弱い
- bank `0D:40E6` は `battle_turn` / `actors` / `current_actor_index` を扱う battle runtime 入口候補で、通常攻撃探索の起点として有望
- `435A/4361` はこの battle runtime 入口配下の state helper と読むほうが自然で、RNG helper と混同しないほうが安全
- `4178-424D` は `actors` queue を走査しつつ state `04/05/06/07` と `435A` 集計を使う action resolve 前処理候補
- `01D4-01E3` は固定 inline operand つき `04BF` wrapper 群で、battle controller 側の descriptor dispatch 群に見える
- `437E` も RNG 本体ではなく、battle round 開始時の actor state / candidate 展開側に見える
- `4579` も RNG 本体ではなく、`actors` queue を構築する battle controller 前処理側に見える
- `443B-4499` は battle 側が slot `07/08` 指定で RNG を 2 回呼ぶ最初の具体的接続部として有力
- したがって battle 側での RNG の役割は、少なくとも一部で direct damage 値ではなく pointer/record 候補選択にある

## 実装方針

最初は ROM 完全再現よりも、注入可能なインターフェースで始めるのが安全です。

- `next(): number`
- `peek?(): number`
- `fork?(seed): Rng`

ROM 実装が確定したら、内部を table-driven 実装に差し替える。

## battle 側との境界

- `battle` は RNG 実装詳細を知らない
- `rng` は seed 更新と値供給だけを担当する
- ROM 実機再現が進んだら実装を差し替えられる形にする

## 追加解析の優先度

1. damage / hit 本体で使う slot を別系統で探す
2. `445E` ループの実初期レジスタと `BC` record ベースを確定する
3. index / seed 更新規則の確定
4. 行動順 / 命中 / ダメージ / ドロップでの消費順
5. `443B` caller を追って slot `07/08` の record writer を確定する
6. `D933` / `5FBC/60D3` を追って particle 初期化 API を固める
