#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path


OUTPUT_DEFAULT = Path("build/rom_extracts/music_anchor_7aee")


def split_on_byte(data: bytes, marker: int) -> list[list[int]]:
    out: list[list[int]] = []
    cur: list[int] = []
    for b in data:
        cur.append(b)
        if b == marker:
            out.append(cur)
            cur = []
    if cur:
        out.append(cur)
    return out


def main() -> None:
    parser = argparse.ArgumentParser(description="Extract first ROM music anchor bytes around 0x7AEE.")
    parser.add_argument("--rom", type=Path, default=os.environ.get("SAGA2_ROM_PATH"))
    parser.add_argument("--out", type=Path, default=OUTPUT_DEFAULT)
    parser.add_argument("--start", type=lambda s: int(s, 0), default=0x7AEE)
    parser.add_argument("--length", type=lambda s: int(s, 0), default=0x80)
    args = parser.parse_args()
    if args.rom is None:
        raise SystemExit("provide --rom or set SAGA2_ROM_PATH")

    rom = args.rom.read_bytes()
    start = args.start
    end = start + args.length
    blob = rom[start:end]

    args.out.mkdir(parents=True, exist_ok=True)
    raw_path = args.out / "music_anchor.bin"
    manifest_path = args.out / "music_anchor.json"
    raw_path.write_bytes(blob)

    segments = split_on_byte(blob, 0x9F)
    manifest = {
        "anchor": {
            "rom_start": f"0x{start:04X}",
            "rom_end": f"0x{end - 1:04X}",
            "length": len(blob),
            "script_anchor": "opcode $47 / $32 path uses HL=$7AEE before CALL $00D2 and saved_bg_music write",
        },
        "bytes_hex": blob.hex(" "),
        "segments_terminated_by_9f": [
            {
                "index": idx,
                "length": len(seg),
                "bytes_hex": " ".join(f"{b:02x}" for b in seg),
            }
            for idx, seg in enumerate(segments)
        ],
    }
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {raw_path}")
    print(f"wrote {manifest_path}")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
