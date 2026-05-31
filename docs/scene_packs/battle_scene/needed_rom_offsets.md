# Battle Scene Needed ROM Offsets

## Status

working_model

## Shared ROM Facts

- ROM platform: Nintendo Game Boy.
- Cartridge title: `SAGA2`.
- Cartridge type: `MBC1+RAM+BATTERY`.
- ROM size: `256 KiB / 16 banks`.
- Bank mapping:
  - bank `00` maps to CPU `0000-3FFF`
  - switchable banks map to CPU `4000-7FFF`
- 16-bit code/data pointers are LR35902 little-endian.

See `../../binary_analysis/saga2_rom_binary_analysis_package.md`.

## Battle Display / Graphics Anchors

| bank:addr | file offset | purpose | status |
|---|---:|---|---|
| `0F:5D20` | unknown here | battle display setup candidate | working_model |
| `0F:5DE1` | unknown here | static monster BG rectangle writer | working_model |
| `0F:5E4D` | unknown here | monster tilemap address calculation from `D936/D939` | working_model |
| `0D:525B` | unknown here | enemy graphics metadata preparation | working_model |
| `0D:5302` | unknown here | graphics source pointer math | working_model |
| `04:4700` | `0x010700` | copied to VRAM `$9700` by battle display setup candidate | working_model |

## Text / Window Anchors

| bank:addr | file offset | purpose | status |
|---|---:|---|---|
| `00:0E8B` | `0x000E8B` | generic window overlay entry candidate | working_model |
| `00:0A44` | `0x000A44` | bordered rectangle builder | working_model |
| `00:070C` | `0x00070C` | text byte dispatcher | working_model |
| `00:1570` | `0x001570` | `C785` text-buffer wrapper | working_model |
| `00:15B1` | `0x0015B1` | fixed-width record to `C785` helper | working_model |
| `0F:6640` | `0x03E640` | item/name text records | working_model |

## Command / Effect Anchors

| bank:addr | file offset | purpose | status |
|---|---:|---|---|
| `0C:6F80` | `0x032F80` | item/action records, 8 bytes each | working_model |
| `0C:7E80` | `0x033E80` | item/action usage-side table candidate | working_model |
| `0F:4000` | `0x03C000` | `data_rng` table | confirmed |
| `0C:658A` | unknown here | S00 effect target | working_model |
| `0C:65F5` | unknown here | S00 amount generation | working_model |
| `0C:65BA` | unknown here | S00 destination pointer setup | working_model |
| `0C:65C2` | unknown here | S00 apply through `CF32/CF33` | working_model |

## Notes

- Unknown file offsets in this scene pack should be resolved through bank/address conversion when needed.
- Keep Game Boy common structure separate from SaGa2 battle-specific meaning.
