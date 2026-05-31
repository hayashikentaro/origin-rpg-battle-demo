# SaGa2 ROM Binary Analysis Package

## 1. metadata
- file name: `SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- file size: `262144` bytes
- sha256: `31477ea9ae09d98e4170938d91ba5a9f5ab94072db4c289988882e0de7e48851`
- format / platform: `Nintendo Game Boy ROM cartridge image`
- suspected encoding: `Game Boy cartridge header ASCII plus SaGa2 custom Japanese text encoding for in-game text`
- endianness: `LR35902 little-endian for 16-bit code/data pointers; header global checksum is stored big-endian`
- base address / load address: `ROM bank 00 maps to CPU 0000-3FFF; switchable ROM banks map to CPU 4000-7FFF through MBC1`
- target question: Convert the SaGa2 ROM into a compact binary analysis package for future offset, table, pointer, text, resource, and porting work.

### Game Boy header

| field | value |
| --- | --- |
| entry | `00 c3 00 02` |
| title_raw | `53 41 47 41 32 00 00 00 00 00 00 00 00 00 00 00` |
| title_ascii | `SAGA2` |
| cgb_flag | `0x00` |
| new_licensee | `00 00` |
| sgb_flag | `0x00` |
| cartridge_type | `0x03` |
| cartridge_type_name | `MBC1+RAM+BATTERY` |
| rom_size_code | `0x03` |
| rom_size_name | `256 KiB / 16 banks` |
| ram_size_code | `0x02` |
| ram_size_name | `8 KiB` |
| destination_code | `0x00` |
| old_licensee | `0xC3` |
| mask_rom_version | `0x01` |
| header_checksum_stored | `0xCD` |
| header_checksum_computed | `0xCD` |
| header_checksum_ok | `True` |
| global_checksum_stored | `0x414E` |
| global_checksum_computed | `0x414E` |
| global_checksum_ok | `True` |

## 2. offset map

| offset | length | type | value | note |
| --- | --- | --- | --- | --- |
| `0x000000` | `0x100` | code/header | `RST/vector area + fixed-bank startup surface` | Game Boy fixed bank |
| `0x000100` | `0x4` | header | `00 c3 00 02` | cartridge entry point |
| `0x000104` | `0x30` | header | `Nintendo logo` | validated by boot ROM |
| `0x000134` | `0x10` | header | `SAGA2...........` | title / flags overlap area |
| `0x000147` | `0x1` | header | `0x03` | cartridge type |
| `0x000148` | `0x1` | header | `0x03` | ROM size code |
| `0x000149` | `0x1` | header | `0x02` | RAM size code |
| `0x004000` | `0x4000` | bank | `ROM bank 01` | switchable CPU window 4000-7FFF |
| `0x00C000` | `0x100` | gfx? | `bank03:4000 first map preload block source` | used by current preload proof extraction |
| `0x010700` | `0x900` | gfx/font? | `bank04:4700` | copied to VRAM 9700 by battle display setup candidate |
| `0x01E3C0` | `0x20` | map/object stream? | `00 0f 43 06 f8 91 18 0b 04 c6 5e f0 11 11 44 c6 03 f1 80 60 22 c1 43 f9 80 61 24 c2 46 f9 80 62` | map0 preload proof object stream opening |
| `0x007AEE` | `0x80` | music? | `04 41 42 01 02 1f 03 23 1f 41 42 1f 43 63 9f 02 00 20 9f 04 40 60 9f 03 1f 01 02 03 23 9f 02 41 ...` | current music anchor extraction range |
| `0x032F80` | `0x400` | table | `data_items / action records` | 8-byte records; CFF0 index uses helper 00:0067 |
| `0x033E80` | `0x180` | table | `data_item_usage` | item/action usage-side table candidate |
| `0x03C000` | `0x100` | table | `data_rng` | RNG lookup table |
| `0x03E640` | `0x800` | text table | `data_item_names` | 8-byte custom text records |

## 3. hex dump

Full hex dump is saved separately at `build/binary_analysis/saga2_rom_full.hex.txt`.

### 0x000000-0x0000FF fixed vectors/startup

```text
00000000  c5 06 00 4f 09 c1 c9 00  c3 21 09 e1 d1 c1 f1 c9  |...O.....!......|
00000010  c3 d9 00 f2 16 00 00 00  c3 80 ff 00 00 00 00 00  |................|
00000020  c3 19 08 00 00 00 00 00  f3 cd b1 04 d9 00 00 00  |................|
00000030  c3 01 07 00 00 00 00 00  c3 38 00 00 00 00 00 00  |.........8......|
00000040  c3 03 c7 00 00 00 00 00  c3 06 c7 87 87 87 87 87  |................|
00000050  87 c9 29 29 29 29 29 29  29 c9 29 29 29 29 29 29  |..))))))).))))))|
00000060  29 09 c9 29 29 29 29 29  29 29 19 c9 af 22 05 20  |)..)))))))...". |
00000070  fc c9 af f5 d5 5f 73 23  0b 79 b0 20 f9 d1 f1 c9  |....._s#.y. ....|
00000080  f5 2a 12 13 05 20 fa f1  c9 f5 2a 12 13 0b 79 b0  |.*... ....*...y.|
00000090  20 f8 f1 c9 cd 8d 16 cd  6d 00 18 16 cd 8d 16 cd  | .......m.......|
000000a0  73 00 18 0e cd 8d 16 cd  80 00 18 06 cd 8d 16 cd  |s...............|
000000b0  89 00 c3 aa 16 ef f5 cd  80 00 18 13 ef f5 cd 89  |................|
000000c0  00 18 0c ef f5 cd a4 00  18 05 ef f5 cd ac 00 f1  |................|
000000d0  ef c9 c5 ef 4e ef 79 c1  c9 f5 cd b0 06 76 f0 44  |....N.y......v.D|
000000e0  fe 90 38 f9 f1 c9 31 00  00 c9 3e 00 c3 00 00 cb  |..8...1...>.....|
000000f0  47 c9 e0 46 3e 28 3d 20  fd c9 00 00 00 00 00 00  |G..F>(= ........|
```

### 0x000100-0x00014F cartridge header

```text
00000100  00 c3 00 02 ce ed 66 66  cc 0d 00 0b 03 73 00 83  |......ff.....s..|
00000110  00 0c 00 0d 00 08 11 1f  88 89 00 0e dc cc 6e e6  |..............n.|
00000120  dd dd d9 99 bb bb 67 63  6e 0e ec cc dd dc 99 9f  |......gcn.......|
00000130  bb b9 33 3e 53 41 47 41  32 00 00 00 00 00 00 00  |..3>SAGA2.......|
00000140  00 00 00 00 00 00 00 03  03 02 00 c3 01 cd 41 4e  |..............AN|
```

### 0x032F80 bank0C:6F80 item/action records

```text
00032f80  a1 00 00 31 06 00 90 2b  a1 00 00 31 07 00 88 20  |...1...+...1... |
00032f90  a1 00 00 31 08 00 90 2b  a1 00 00 31 09 00 88 20  |...1...+...1... |
00032fa0  a1 00 00 31 0a 00 8b 20  a1 00 00 31 0b 00 88 20  |...1... ...1... |
00032fb0  a1 00 00 0c 0d 30 88 20  a1 00 00 0c 0d a0 90 20  |.....0. ....... |
00032fc0  a1 00 00 0c 0e 60 88 20  a1 00 00 0c 0f b0 8c 20  |.....`. ....... |
00032fd0  a1 00 00 0a 0c 80 8d 20  a1 00 00 0a 0c 40 8e 20  |....... .....@. |
00032fe0  a1 00 00 0a 0c 20 8f 2b  a1 08 00 31 0e 50 88 20  |..... .+...1.P. |
00032ff0  a1 10 00 31 0c 00 90 2b  a1 00 00 0e 07 00 9e 2c  |...1...+.......,|
00033000  a1 00 00 0e 09 00 9e 2c  a1 00 00 0e 0d 00 9e 2c  |.......,.......,|
00033010  a1 00 00 0d 06 b0 8a 20  a1 00 00 11 00 04 89 20  |....... ....... |
00033020  11 01 00 08 14 00 89 20  21 00 00 14 0a 32 e4 23  |....... !....2.#|
00033030  21 00 00 14 40 64 e4 23  11 08 00 06 00 32 80 08  |!...@d.#.....2..|
00033040  11 08 00 06 00 3c 80 08  11 08 00 06 00 46 80 08  |.....<.......F..|
00033050  11 08 00 07 40 50 80 08  11 08 00 07 80 50 80 08  |....@P.......P..|
00033060  11 08 00 07 f0 5a 80 08  03 00 00 01 28 14 a3 33  |.....Z......(..3|
00033070  03 00 00 01 96 32 a3 33  03 00 00 02 df 00 a3 33  |.....2.3.......3|
```

### 0x03C000 bank0F:4000 data_rng

```text
0003c000  09 b4 9a 88 21 7c c2 6f  46 c4 95 e7 d1 73 92 df  |....!|.oF....s..|
0003c010  96 d4 3a 57 7e 9c 62 b0  e6 e4 f5 38 31 53 32 40  |..:W~.b....81S2@|
0003c020  c9 f4 25 c8 e1 bc 02 2f  79 fb aa a7 6e 33 2d 9f  |..%..../y...n3-.|
0003c030  29 eb 85 17 41 dc 5d f0  26 db 4a 78 f1 13 8d 80  |)...A.].&.Jx....|
0003c040  76 cb e5 f7 5e fc bd 10  c6 bb 15 67 51 0c ed 5f  |v...^......gQ.._|
0003c050  e9 ab ba 28 fe e3 e2 cf  99 9b 75 b8 4e 2c b2 c0  |...(......u.N,..|
0003c060  49 8b 5a b7 61 c3 82 50  06 7b d5 27 ee 4c 52 1f  |I.Z.a..P.{.'.LR.|
0003c070  56 6b 05 68 3e a3 22 8f  a6 5b ca f8 71 6c 0d ff  |Vk.h>."..[..ql..|
0003c080  f6 4b 65 77 de 83 3d 90  b9 3b 6a 18 2e 8c 6d 20  |.Kew..=..;j...m |
0003c090  69 2b c5 a8 81 63 9d 4f  19 1b 0a c7 ce ac cd bf  |i+...c.O........|
0003c0a0  36 0b da 37 1e 43 fd d0  86 04 55 58 91 cc d2 60  |6..7.C....UX...`|
0003c0b0  d6 14 7a e8 be 23 a2 0f  d9 24 b5 87 0e ec 72 7f  |..z..#...$....r.|
0003c0c0  89 34 1a 08 a1 03 42 ef  39 44 ea 98 ae f3 12 a0  |.4....B.9D......|
0003c0d0  16 54 45 d7 01 1c 1d 30  66 64 8a 47 b1 d3 4d 3f  |.TE....0fd.G..M?|
0003c0e0  b6 74 a5 48 9e 3c 7d af  f9 84 2a d8 11 b3 ad e0  |.t.H.<}...*.....|
0003c0f0  a9 94 fa 97 c1 5c dd 70  59 a4 35 07 8e 93 f2 00  |.....\.pY.5.....|
```

### 0x03E640 bank0F:6640 item-name text records

```text
0003e640  71 cf e4 d5 e9 da f2 ff  e6 e9 64 ca f2 70 ff ff  |q.........d..p..|
0003e650  71 cf e4 bc c3 c8 ff ff  97 8b b1 ba 8c 9d 8c ff  |q...............|
0003e660  8f 99 9e ff ff ff ff ff  db c8 e3 e4 ca f2 70 ff  |..............p.|
0003e670  94 b7 52 a2 9b b2 4f ff  c0 f2 62 c2 e2 f2 ff ff  |..R...O...b.....|
0003e680  70 e2 66 e9 ca f2 70 ff  c6 e9 73 e5 f2 70 ff ff  |p.f...p...s..p..|
0003e690  d7 e5 f2 dc ca f2 70 ff  bc bd c8 73 e2 e9 70 ff  |......p....s..p.|
0003e6a0  c6 e9 6c f2 bc c3 c8 ff  6f eb d7 f5 e9 6c f2 ff  |..l.....o....l..|
0003e6b0  e4 f2 e9 bc c3 c8 ff ff  e5 bd 7c bc ff ff ff ff  |..........|.....|
0003e6c0  c6 f2 74 e4 ff ff ff ff  d3 c5 a2 cd dd ff ff ff  |..t.............|
0003e6d0  73 e2 ec 70 ca f2 70 ff  62 e2 c8 a2 9b b2 4f ff  |s..p..p.b.....O.|
0003e6e0  8c b0 a9 a2 9b b2 4f ff  ae a9 ff ff ff ff ff ff  |......O.........|
0003e6f0  db c8 e3 e4 a2 ae a9 ff  73 e6 e9 69 a2 99 9c ff  |........s..i....|
0003e700  66 f2 e4 70 a2 99 9c ff  db c8 e3 e4 a2 99 9c ff  |f..p............|
0003e710  a7 a2 8e a2 99 9c ff ff  bc bd c8 c7 f2 e4 70 ff  |..............p.|
0003e720  70 e2 66 e9 a2 99 9c ff  7f f2 c7 ef e9 ff ff ff  |p.f.............|
0003e730  d5 bd 7f f2 c7 ef e9 ff  54 ba 8c 54 8f ff ff ff  |........T..T....|
```

## 4. decoded candidates

### strings

| offset | raw bytes | decoded | confidence |
| --- | --- | --- | --- |
| `0x000134` | `53 41 47 41 32 00 00 00 00 00 00 00 00 00 00 00` | SAGA2 | `0.95` |
| `0x03E760` | `c4 bc e4 a2 95 bb ff ff` | custom text record; known current label: ケアルのしょ | `0.8` |
| `0x03E640` | `71 cf e4 d5 e9 da f2 ff` | custom text table first record | `0.5` |

### pointers

| offset | raw | interpreted address | target offset | note |
| --- | --- | --- | --- | --- |
| `0x000000` | `c5 06` | `0x06C5` | `0x0006C5` | fixed-bank pointer candidate |
| `0x000002` | `00 4f` | `0x4F00` |  | banked pointer candidate; active MBC bank required |
| `0x000003` | `4f 09` | `0x094F` | `0x00094F` | fixed-bank pointer candidate |
| `0x000008` | `c3 21` | `0x21C3` | `0x0021C3` | fixed-bank pointer candidate |
| `0x000009` | `21 09` | `0x0921` | `0x000921` | fixed-bank pointer candidate |
| `0x000013` | `f2 16` | `0x16F2` | `0x0016F2` | fixed-bank pointer candidate |
| `0x000020` | `c3 19` | `0x19C3` | `0x0019C3` | fixed-bank pointer candidate |
| `0x000021` | `19 08` | `0x0819` | `0x000819` | fixed-bank pointer candidate |
| `0x00002A` | `b1 04` | `0x04B1` | `0x0004B1` | fixed-bank pointer candidate |
| `0x000030` | `c3 01` | `0x01C3` | `0x0001C3` | fixed-bank pointer candidate |
| `0x000031` | `01 07` | `0x0701` | `0x000701` | fixed-bank pointer candidate |
| `0x000038` | `c3 38` | `0x38C3` | `0x0038C3` | fixed-bank pointer candidate |
| `0x000040` | `c3 03` | `0x03C3` | `0x0003C3` | fixed-bank pointer candidate |
| `0x000048` | `c3 06` | `0x06C3` | `0x0006C3` | fixed-bank pointer candidate |
| `0x000051` | `c9 29` | `0x29C9` | `0x0029C9` | fixed-bank pointer candidate |
| `0x000052` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x000053` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x000054` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x000055` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x000056` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x000057` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x000059` | `c9 29` | `0x29C9` | `0x0029C9` | fixed-bank pointer candidate |
| `0x00005A` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x00005B` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x00005C` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x00005D` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x00005E` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x00005F` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x000060` | `29 09` | `0x0929` | `0x000929` | fixed-bank pointer candidate |
| `0x000062` | `c9 29` | `0x29C9` | `0x0029C9` | fixed-bank pointer candidate |
| `0x000063` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x000064` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x000065` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x000066` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x000067` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x000068` | `29 29` | `0x2929` | `0x002929` | fixed-bank pointer candidate |
| `0x000069` | `29 19` | `0x1929` | `0x001929` | fixed-bank pointer candidate |
| `0x00006C` | `af 22` | `0x22AF` | `0x0022AF` | fixed-bank pointer candidate |
| `0x00006D` | `22 05` | `0x0522` | `0x000522` | fixed-bank pointer candidate |
| `0x00006E` | `05 20` | `0x2005` | `0x002005` | fixed-bank pointer candidate |
| `0x000074` | `d5 5f` | `0x5FD5` |  | banked pointer candidate; active MBC bank required |
| `0x000075` | `5f 73` | `0x735F` |  | banked pointer candidate; active MBC bank required |
| `0x000076` | `73 23` | `0x2373` | `0x002373` | fixed-bank pointer candidate |
| `0x000077` | `23 0b` | `0x0B23` | `0x000B23` | fixed-bank pointer candidate |
| `0x000078` | `0b 79` | `0x790B` |  | banked pointer candidate; active MBC bank required |
| `0x00007A` | `b0 20` | `0x20B0` | `0x0020B0` | fixed-bank pointer candidate |
| `0x000080` | `f5 2a` | `0x2AF5` | `0x002AF5` | fixed-bank pointer candidate |
| `0x000081` | `2a 12` | `0x122A` | `0x00122A` | fixed-bank pointer candidate |

### tables

| offset | row size | rows | fields guess |
| --- | --- | --- | --- |
| `0x03C000` | `1` | `256` | data_rng byte table |
| `0x032F80` | `8` | `128` | item/action records; record[3]->CF23, record[4]->CF24, record[5]->CF25 in current phase05/S00 model |
| `0x03E640` | `8` | `256` | custom text records / item names |
| `0x01E3C0` | `1` | `32` | map0 object/preload stream candidate |
