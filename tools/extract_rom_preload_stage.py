#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import struct
import zlib
from pathlib import Path


OUTPUT_DEFAULT = Path("build/rom_extracts/map0_preload37")


def banked_offset(bank: int, addr: int) -> int:
    if addr < 0x4000:
        return addr
    return bank * 0x4000 + (addr - 0x4000)


def read_bytes(rom: bytes, bank: int, addr: int, length: int) -> bytes:
    off = banked_offset(bank, addr)
    return rom[off : off + length]


def chunk(tag: bytes, payload: bytes) -> bytes:
    crc = zlib.crc32(tag + payload) & 0xFFFFFFFF
    return struct.pack(">I", len(payload)) + tag + payload + struct.pack(">I", crc)


def write_png_grayscale(path: Path, width: int, height: int, pixels: bytes) -> None:
    rows = bytearray()
    stride = width
    for y in range(height):
        rows.append(0)
        start = y * stride
        rows.extend(pixels[start : start + stride])
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 0, 0, 0, 0)
    png = bytearray(b"\x89PNG\r\n\x1a\n")
    png.extend(chunk(b"IHDR", ihdr))
    png.extend(chunk(b"IDAT", zlib.compress(bytes(rows), level=9)))
    png.extend(chunk(b"IEND", b""))
    path.write_bytes(bytes(png))


def decode_2bpp_tiles(tile_bytes: bytes, columns: int = 16) -> tuple[int, int, bytes]:
    tile_count = len(tile_bytes) // 16
    rows = (tile_count + columns - 1) // columns
    width = columns * 8
    height = rows * 8
    pixels = bytearray([255] * (width * height))
    palette = [255, 170, 85, 0]

    for tile_index in range(tile_count):
        tx = tile_index % columns
        ty = tile_index // columns
        tile = tile_bytes[tile_index * 16 : (tile_index + 1) * 16]
        for row in range(8):
            lo = tile[row * 2]
            hi = tile[row * 2 + 1]
            for col in range(8):
                mask = 1 << (7 - col)
                value = ((lo & mask) >> (7 - col)) | (((hi & mask) >> (7 - col)) << 1)
                x = tx * 8 + col
                y = ty * 8 + row
                pixels[y * width + x] = palette[value]

    return width, height, bytes(pixels)


def write_block_tiles(
    out_dir: Path, block_index: int, block_bytes: bytes, object_byte: int, source_bank: int, source_addr: str
) -> dict:
    width, height, pixels = decode_2bpp_tiles(block_bytes, columns=4)
    filename = f"block_{block_index:02d}_obj_{object_byte:02X}_b{source_bank}_{source_addr[2:]}.png"
    path = out_dir / filename
    write_png_grayscale(path, width, height, pixels)
    return {
        "file": str(path),
        "width": width,
        "height": height,
    }


def emulate_first_proof_case(rom: bytes) -> dict:
    object_stream_bank = 0x07
    object_stream_addr = 0x63C0
    stage_dest_base = 0x8100
    max_blocks = 6
    block_size = 0x100

    stage = bytearray()
    blocks = []

    for index in range(max_blocks):
        object_byte = read_bytes(rom, object_stream_bank, object_stream_addr + index, 1)[0]
        if object_byte == 0xFF:
            break

        transformed = (object_byte + 0x40) & 0xFF
        if transformed & 0x80:
            source_high = (transformed & 0x7F) | 0x40
            source_bank = 0x04
        else:
            source_high = transformed
            source_bank = 0x03
        source_addr = source_high << 8
        block = read_bytes(rom, source_bank, source_addr, block_size)
        stage.extend(block)
        blocks.append(
            {
                "block_index": index,
                "object_byte": object_byte,
                "transformed": transformed,
                "source_bank": source_bank,
                "source_addr": f"0x{source_addr:04X}",
                "dest_addr": f"0x{stage_dest_base + index * block_size:04X}",
                "copy_size": block_size,
                "bytes": block,
            }
        )

    return {
        "proof_case": {
            "map_id": 0,
            "header": "0x63B1",
            "object_stream_bank": "0x07",
            "object_stream_addr": "0x63C0",
            "preload_entry": "0x25",
        },
        "staging": {
            "dest_range": f"0x{stage_dest_base:04X}-0x{stage_dest_base + len(stage) - 1:04X}",
            "byte_count": len(stage),
            "tile_count": len(stage) // 16,
        },
        "object_stream_opening": [block["object_byte"] for block in blocks],
        "blocks": blocks,
        "stage_bytes": bytes(stage),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Extract the first ROM preload proof-case stage.")
    parser.add_argument("--rom", type=Path, default=os.environ.get("SAGA2_ROM_PATH"))
    parser.add_argument("--out", type=Path, default=OUTPUT_DEFAULT)
    args = parser.parse_args()
    if args.rom is None:
        raise SystemExit("provide --rom or set SAGA2_ROM_PATH")

    rom = args.rom.read_bytes()
    result = emulate_first_proof_case(rom)
    stage_bytes = result.pop("stage_bytes")
    block_records = result["blocks"]

    args.out.mkdir(parents=True, exist_ok=True)
    stage_bin = args.out / "stage.bin"
    manifest_json = args.out / "manifest.json"
    tiles_png = args.out / "tiles.png"
    blocks_dir = args.out / "blocks"
    blocks_dir.mkdir(parents=True, exist_ok=True)

    stage_bin.write_bytes(stage_bytes)
    width, height, pixels = decode_2bpp_tiles(stage_bytes)
    write_png_grayscale(tiles_png, width, height, pixels)
    for block in block_records:
        block["preview"] = write_block_tiles(
            blocks_dir,
            block["block_index"],
            block.pop("bytes"),
            block["object_byte"],
            block["source_bank"],
            block["source_addr"],
        )
    manifest_json.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")

    print(f"wrote {stage_bin}")
    print(f"wrote {manifest_json}")
    print(f"wrote {tiles_png}")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
