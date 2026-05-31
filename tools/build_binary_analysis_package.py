#!/usr/bin/env python3
"""Build a compact binary analysis package for a Game Boy ROM."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


ROM_DEFAULT = Path(
    "/Users/hayashikentarou/Library/CloudStorage/GoogleDrive-jacques.m.e.lapin@gmail.com/マイドライブ/SaGa 2 - Hihou Densetsu (J) (V1.1)/SaGa 2 - Hihou Densetsu (J) (V1.1).gb"
)
OUT_DIR_DEFAULT = Path("docs/binary_analysis")
BUILD_DIR_DEFAULT = Path("build/binary_analysis")

BANK_SIZE = 0x4000

CARTRIDGE_TYPES = {
    0x00: "ROM ONLY",
    0x01: "MBC1",
    0x02: "MBC1+RAM",
    0x03: "MBC1+RAM+BATTERY",
    0x05: "MBC2",
    0x06: "MBC2+BATTERY",
    0x08: "ROM+RAM",
    0x09: "ROM+RAM+BATTERY",
    0x0F: "MBC3+TIMER+BATTERY",
    0x10: "MBC3+TIMER+RAM+BATTERY",
    0x11: "MBC3",
    0x12: "MBC3+RAM",
    0x13: "MBC3+RAM+BATTERY",
    0x19: "MBC5",
    0x1A: "MBC5+RAM",
    0x1B: "MBC5+RAM+BATTERY",
}

ROM_SIZES = {
    0x00: "32 KiB / 2 banks",
    0x01: "64 KiB / 4 banks",
    0x02: "128 KiB / 8 banks",
    0x03: "256 KiB / 16 banks",
    0x04: "512 KiB / 32 banks",
    0x05: "1 MiB / 64 banks",
    0x06: "2 MiB / 128 banks",
    0x07: "4 MiB / 256 banks",
    0x08: "8 MiB / 512 banks",
}

RAM_SIZES = {
    0x00: "none",
    0x01: "2 KiB",
    0x02: "8 KiB",
    0x03: "32 KiB / 4 banks",
    0x04: "128 KiB / 16 banks",
    0x05: "64 KiB / 8 banks",
}


def cpu_to_file_offset(bank: int, address: int) -> int:
    if 0 <= address <= 0x3FFF:
        return address
    if 0x4000 <= address <= 0x7FFF:
        return bank * BANK_SIZE + (address - 0x4000)
    raise ValueError(f"address outside ROM window: {address:04X}")


def slice_hex(data: bytes, offset: int, length: int) -> str:
    return data[offset : offset + length].hex(" ")


def ascii_preview(raw: bytes) -> str:
    return "".join(chr(b) if 0x20 <= b <= 0x7E else "." for b in raw)


def hexdump(data: bytes, offset: int, length: int) -> str:
    lines = []
    end = min(len(data), offset + length)
    for row in range(offset, end, 16):
        chunk = data[row : min(row + 16, end)]
        hex_part = " ".join(f"{b:02x}" for b in chunk)
        if len(chunk) > 8:
            hex_part = hex_part[: 8 * 3 - 1] + "  " + hex_part[8 * 3 :]
        lines.append(f"{row:08x}  {hex_part:<49} |{ascii_preview(chunk)}|")
    return "\n".join(lines)


def full_hexdump(data: bytes) -> str:
    return hexdump(data, 0, len(data)) + "\n"


def gb_header(data: bytes) -> dict[str, object]:
    title_raw = data[0x0134:0x0144]
    title = title_raw.split(b"\x00", 1)[0].decode("ascii", errors="replace")
    header_checksum = 0
    for b in data[0x0134:0x014D]:
        header_checksum = (header_checksum - b - 1) & 0xFF
    global_sum = sum(b for i, b in enumerate(data) if i not in (0x014E, 0x014F)) & 0xFFFF
    stored_global = (data[0x014E] << 8) | data[0x014F]
    cart_type = data[0x0147]
    rom_size = data[0x0148]
    ram_size = data[0x0149]
    return {
        "entry": slice_hex(data, 0x0100, 4),
        "title_raw": title_raw.hex(" "),
        "title_ascii": title,
        "cgb_flag": f"0x{data[0x0143]:02X}",
        "new_licensee": data[0x0144:0x0146].hex(" "),
        "sgb_flag": f"0x{data[0x0146]:02X}",
        "cartridge_type": f"0x{cart_type:02X}",
        "cartridge_type_name": CARTRIDGE_TYPES.get(cart_type, "unknown"),
        "rom_size_code": f"0x{rom_size:02X}",
        "rom_size_name": ROM_SIZES.get(rom_size, "unknown"),
        "ram_size_code": f"0x{ram_size:02X}",
        "ram_size_name": RAM_SIZES.get(ram_size, "unknown"),
        "destination_code": f"0x{data[0x014A]:02X}",
        "old_licensee": f"0x{data[0x014B]:02X}",
        "mask_rom_version": f"0x{data[0x014C]:02X}",
        "header_checksum_stored": f"0x{data[0x014D]:02X}",
        "header_checksum_computed": f"0x{header_checksum:02X}",
        "header_checksum_ok": header_checksum == data[0x014D],
        "global_checksum_stored": f"0x{stored_global:04X}",
        "global_checksum_computed": f"0x{global_sum:04X}",
        "global_checksum_ok": global_sum == stored_global,
    }


def known_offset_map(data: bytes) -> list[dict[str, object]]:
    rows = [
        (0x0000, 0x0100, "code/header", "RST/vector area + fixed-bank startup surface", "Game Boy fixed bank"),
        (0x0100, 0x0004, "header", slice_hex(data, 0x0100, 4), "cartridge entry point"),
        (0x0104, 0x0030, "header", "Nintendo logo", "validated by boot ROM"),
        (0x0134, 0x0010, "header", ascii_preview(data[0x0134:0x0144]), "title / flags overlap area"),
        (0x0147, 0x0001, "header", f"0x{data[0x0147]:02X}", "cartridge type"),
        (0x0148, 0x0001, "header", f"0x{data[0x0148]:02X}", "ROM size code"),
        (0x0149, 0x0001, "header", f"0x{data[0x0149]:02X}", "RAM size code"),
        (0x4000, 0x4000, "bank", "ROM bank 01", "switchable CPU window 4000-7FFF"),
        (cpu_to_file_offset(0x03, 0x4000), 0x100, "gfx?", "bank03:4000 first map preload block source", "used by current preload proof extraction"),
        (cpu_to_file_offset(0x04, 0x4700), 0x900, "gfx/font?", "bank04:4700", "copied to VRAM 9700 by battle display setup candidate"),
        (cpu_to_file_offset(0x07, 0x63C0), 0x20, "map/object stream?", slice_hex(data, cpu_to_file_offset(0x07, 0x63C0), 0x20), "map0 preload proof object stream opening"),
        (0x7AEE, 0x80, "music?", slice_hex(data, 0x7AEE, 0x20) + " ...", "current music anchor extraction range"),
        (cpu_to_file_offset(0x0C, 0x6F80), 0x400, "table", "data_items / action records", "8-byte records; CFF0 index uses helper 00:0067"),
        (cpu_to_file_offset(0x0C, 0x7E80), 0x180, "table", "data_item_usage", "item/action usage-side table candidate"),
        (cpu_to_file_offset(0x0F, 0x4000), 0x100, "table", "data_rng", "RNG lookup table"),
        (cpu_to_file_offset(0x0F, 0x6640), 0x800, "text table", "data_item_names", "8-byte custom text records"),
    ]
    return [
        {"offset": offset, "length": length, "type": kind, "value": value, "note": note}
        for offset, length, kind, value, note in rows
    ]


def decoded_string_candidates(data: bytes) -> list[dict[str, object]]:
    candidates = [
        (0x0134, data[0x0134:0x0144], "ASCII title/header", 0.95),
        (cpu_to_file_offset(0x0F, 0x6760), data[cpu_to_file_offset(0x0F, 0x6760) : cpu_to_file_offset(0x0F, 0x6760) + 8], "custom text record; known current label: ケアルのしょ", 0.8),
        (cpu_to_file_offset(0x0F, 0x6640), data[cpu_to_file_offset(0x0F, 0x6640) : cpu_to_file_offset(0x0F, 0x6640) + 8], "custom text table first record", 0.5),
    ]
    return [
        {
            "offset": offset,
            "raw_bytes": raw.hex(" "),
            "decoded": decoded if offset != 0x0134 else raw.split(b"\x00", 1)[0].decode("ascii", errors="replace"),
            "confidence": confidence,
        }
        for offset, raw, decoded, confidence in candidates
    ]


def pointer_candidates(data: bytes, limit: int = 48) -> list[dict[str, object]]:
    rows = []
    for off in range(0, len(data) - 1):
        value = data[off] | (data[off + 1] << 8)
        if 0x4000 <= value <= 0x7FFF:
            rows.append(
                {
                    "offset": off,
                    "raw": data[off : off + 2].hex(" "),
                    "interpreted_address": f"0x{value:04X}",
                    "target_offset": None,
                    "note": "banked pointer candidate; active MBC bank required",
                }
            )
        elif 0x0100 <= value <= 0x3FFF:
            rows.append(
                {
                    "offset": off,
                    "raw": data[off : off + 2].hex(" "),
                    "interpreted_address": f"0x{value:04X}",
                    "target_offset": value,
                    "note": "fixed-bank pointer candidate",
                }
            )
        if len(rows) >= limit:
            break
    return rows


def table_candidates() -> list[dict[str, object]]:
    return [
        {"offset": cpu_to_file_offset(0x0F, 0x4000), "row_size": 1, "rows": 256, "fields_guess": "data_rng byte table"},
        {"offset": cpu_to_file_offset(0x0C, 0x6F80), "row_size": 8, "rows": 128, "fields_guess": "item/action records; record[3]->CF23, record[4]->CF24, record[5]->CF25 in current phase05/S00 model"},
        {"offset": cpu_to_file_offset(0x0F, 0x6640), "row_size": 8, "rows": 256, "fields_guess": "custom text records / item names"},
        {"offset": cpu_to_file_offset(0x07, 0x63C0), "row_size": 1, "rows": 32, "fields_guess": "map0 object/preload stream candidate"},
    ]


def markdown_table(headers: list[str], rows: list[list[str]]) -> str:
    out = ["| " + " | ".join(headers) + " |", "| " + " | ".join("---" for _ in headers) + " |"]
    for row in rows:
        out.append("| " + " | ".join(row) + " |")
    return "\n".join(out)


def build_markdown(package: dict[str, object], selected_dumps: list[dict[str, object]]) -> str:
    metadata = package["metadata"]
    header = package["header"]
    offset_map = package["offset_map"]
    decoded = package["decoded_candidates"]
    lines = [
        "# SaGa2 ROM Binary Analysis Package",
        "",
        "## 1. metadata",
        f"- file name: `{metadata['file_name']}`",
        f"- file size: `{metadata['file_size']}` bytes",
        f"- sha256: `{metadata['sha256']}`",
        f"- format / platform: `{metadata['format_platform']}`",
        f"- suspected encoding: `{metadata['suspected_encoding']}`",
        f"- endianness: `{metadata['endianness']}`",
        f"- base address / load address: `{metadata['base_address_load_address']}`",
        f"- target question: {metadata['target_question']}",
        "",
        "### Game Boy header",
        "",
        markdown_table(
            ["field", "value"],
            [[key, f"`{value}`"] for key, value in header.items()],
        ),
        "",
        "## 2. offset map",
        "",
        markdown_table(
            ["offset", "length", "type", "value", "note"],
            [
                [f"`0x{row['offset']:06X}`", f"`0x{row['length']:X}`", str(row["type"]), f"`{row['value']}`", str(row["note"])]
                for row in offset_map
            ],
        ),
        "",
        "## 3. hex dump",
        "",
        "Full hex dump is saved separately at `build/binary_analysis/saga2_rom_full.hex.txt`.",
        "",
    ]
    for dump in selected_dumps:
        lines.extend(
            [
                f"### {dump['label']}",
                "",
                "```text",
                str(dump["dump"]),
                "```",
                "",
            ]
        )
    lines.extend(
        [
            "## 4. decoded candidates",
            "",
            "### strings",
            "",
            markdown_table(
                ["offset", "raw bytes", "decoded", "confidence"],
                [
                    [f"`0x{row['offset']:06X}`", f"`{row['raw_bytes']}`", str(row["decoded"]), f"`{row['confidence']}`"]
                    for row in decoded["strings"]
                ],
            ),
            "",
            "### pointers",
            "",
            markdown_table(
                ["offset", "raw", "interpreted address", "target offset", "note"],
                [
                    [
                        f"`0x{row['offset']:06X}`",
                        f"`{row['raw']}`",
                        f"`{row['interpreted_address']}`",
                        "" if row["target_offset"] is None else f"`0x{row['target_offset']:06X}`",
                        str(row["note"]),
                    ]
                    for row in decoded["pointers"]
                ],
            ),
            "",
            "### tables",
            "",
            markdown_table(
                ["offset", "row size", "rows", "fields guess"],
                [
                    [f"`0x{row['offset']:06X}`", f"`{row['row_size']}`", f"`{row['rows']}`", str(row["fields_guess"])]
                    for row in decoded["tables"]
                ],
            ),
            "",
        ]
    )
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rom", type=Path, default=ROM_DEFAULT)
    parser.add_argument("--out-dir", type=Path, default=OUT_DIR_DEFAULT)
    parser.add_argument("--build-dir", type=Path, default=BUILD_DIR_DEFAULT)
    args = parser.parse_args()

    data = args.rom.read_bytes()
    header = gb_header(data)
    package = {
        "metadata": {
            "file_name": args.rom.name,
            "file_size": len(data),
            "sha256": hashlib.sha256(data).hexdigest(),
            "format_platform": "Nintendo Game Boy ROM cartridge image",
            "suspected_encoding": "Game Boy cartridge header ASCII plus SaGa2 custom Japanese text encoding for in-game text",
            "endianness": "LR35902 little-endian for 16-bit code/data pointers; header global checksum is stored big-endian",
            "base_address_load_address": "ROM bank 00 maps to CPU 0000-3FFF; switchable ROM banks map to CPU 4000-7FFF through MBC1",
            "target_question": "Convert the SaGa2 ROM into a compact binary analysis package for future offset, table, pointer, text, resource, and porting work.",
        },
        "header": header,
        "offset_map": known_offset_map(data),
        "decoded_candidates": {
            "strings": decoded_string_candidates(data),
            "pointers": pointer_candidates(data),
            "tables": table_candidates(),
        },
    }

    selected_dumps = [
        {"label": "0x000000-0x0000FF fixed vectors/startup", "dump": hexdump(data, 0x0000, 0x100)},
        {"label": "0x000100-0x00014F cartridge header", "dump": hexdump(data, 0x0100, 0x50)},
        {"label": "0x032F80 bank0C:6F80 item/action records", "dump": hexdump(data, cpu_to_file_offset(0x0C, 0x6F80), 0x100)},
        {"label": "0x03C000 bank0F:4000 data_rng", "dump": hexdump(data, cpu_to_file_offset(0x0F, 0x4000), 0x100)},
        {"label": "0x03E640 bank0F:6640 item-name text records", "dump": hexdump(data, cpu_to_file_offset(0x0F, 0x6640), 0x100)},
    ]

    args.out_dir.mkdir(parents=True, exist_ok=True)
    args.build_dir.mkdir(parents=True, exist_ok=True)
    json_path = args.build_dir / "saga2_rom_binary_analysis_package.json"
    hex_path = args.build_dir / "saga2_rom_full.hex.txt"
    md_path = args.out_dir / "saga2_rom_binary_analysis_package.md"

    json_path.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    hex_path.write_text(full_hexdump(data), encoding="utf-8")
    md_path.write_text(build_markdown(package, selected_dumps), encoding="utf-8")

    print(json.dumps({"markdown": str(md_path), "json": str(json_path), "full_hex": str(hex_path)}, indent=2))


if __name__ == "__main__":
    main()
