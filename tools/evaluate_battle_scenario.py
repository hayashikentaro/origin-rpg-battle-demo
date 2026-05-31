#!/usr/bin/env python3
"""Evaluate small battle scene scenario fixtures against committed ROM analysis data."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


DEFAULT_SCENARIO = Path("docs/scene_packs/battle_scene/scenarios/cure_book_working_model.json")
DEFAULT_HEXDUMP = Path("build/binary_analysis/saga2_rom_full.hex.txt")
RNG_TABLE_OFFSET = 0x03C000
RNG_TABLE_SIZE = 0x100


def parse_hex_int(value: str, name: str) -> int:
    if not re.match(r"^0x[0-9A-Fa-f]+$", value):
        raise ValueError(f"{name}: expected hex value, got {value!r}")
    return int(value, 16)


def parse_hexdump(path: Path) -> bytes:
    rows: dict[int, list[int]] = {}
    max_end = 0
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        left = line.split("|", 1)[0]
        parts = left.split()
        if not parts:
            continue
        offset = int(parts[0], 16)
        byte_values = [int(part, 16) for part in parts[1:] if re.match(r"^[0-9a-fA-F]{2}$", part)]
        rows[offset] = byte_values
        max_end = max(max_end, offset + len(byte_values))

    data = bytearray(max_end)
    for offset, byte_values in rows.items():
        data[offset : offset + len(byte_values)] = bytes(byte_values)
    return bytes(data)


def load_scenario(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def s00_amounts(rng_table: bytes, seed05: int | None, cf24: int, cf25: int) -> list[dict[str, int]]:
    if seed05 is not None:
        index = (seed05 + cf25 + 1) & 0xFF
        return [{"seed05": seed05, "rng_index": index, "rng_value": rng_table[index], "amount": rng_table[index] + cf24}]

    return [
        {
            "seed05": seed,
            "rng_index": (seed + cf25 + 1) & 0xFF,
            "rng_value": rng_table[(seed + cf25 + 1) & 0xFF],
            "amount": rng_table[(seed + cf25 + 1) & 0xFF] + cf24,
        }
        for seed in range(0x100)
    ]


def summarize_amounts(amounts: list[dict[str, int]]) -> dict[str, Any]:
    values = [row["amount"] for row in amounts]
    return {
        "count": len(values),
        "min_amount": min(values),
        "max_amount": max(values),
        "unique_amounts": len(set(values)),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scenario", type=Path, default=DEFAULT_SCENARIO)
    parser.add_argument("--hexdump", type=Path, default=DEFAULT_HEXDUMP)
    parser.add_argument("--seed05", help="Override seed05 as 0xNN.")
    parser.add_argument("--destination-hp", help="Override destination HP as 0xNNNN.")
    parser.add_argument("--limit", type=int, default=16, help="Rows to print when enumerating unknown seed05.")
    args = parser.parse_args()

    scenario = load_scenario(args.scenario)
    hexdump = parse_hexdump(args.hexdump)
    rng_table = hexdump[RNG_TABLE_OFFSET : RNG_TABLE_OFFSET + RNG_TABLE_SIZE]
    if len(rng_table) != RNG_TABLE_SIZE:
        raise SystemExit("RNG table is not available in the hexdump")

    command_bytes = bytes.fromhex(scenario["command"]["record_bytes"])
    if scenario["expected_effect"]["route"] != "S00":
        raise SystemExit("only S00 fixtures are supported")
    if len(command_bytes) < 6:
        raise SystemExit("command record must contain at least 6 bytes")

    cf24 = command_bytes[4]
    cf25 = command_bytes[5]
    seed_value = args.seed05 or scenario["rng"]["seed05_entry"]
    seed05 = None if seed_value == "unknown" else parse_hex_int(seed_value, "seed05")
    hp_value = args.destination_hp or scenario["state_before"]["destination_hp"]
    destination_hp = None if hp_value == "unknown" else parse_hex_int(hp_value, "destination_hp")

    amounts = s00_amounts(rng_table, seed05, cf24, cf25)
    result: dict[str, Any] = {
        "case_id": scenario["case_id"],
        "status": scenario["status"],
        "route": "S00",
        "record_bytes": scenario["command"]["record_bytes"],
        "cf24": f"0x{cf24:02X}",
        "cf25": f"0x{cf25:02X}",
        "destination_pointer": scenario["targeting"]["destination_pointer"],
        "amount_summary": summarize_amounts(amounts),
    }

    if seed05 is None:
        result["mode"] = "enumerated_seed05"
        result["first_rows"] = amounts[: max(args.limit, 0)]
    else:
        row = amounts[0]
        result["mode"] = "exact_seed05"
        result["seed05"] = f"0x{seed05:02X}"
        result["rng_index"] = f"0x{row['rng_index']:02X}"
        result["rng_value"] = f"0x{row['rng_value']:02X}"
        result["amount"] = row["amount"]
        if destination_hp is not None:
            result["destination_hp_before"] = destination_hp
            result["destination_hp_after"] = (destination_hp + row["amount"]) & 0xFFFF

    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
