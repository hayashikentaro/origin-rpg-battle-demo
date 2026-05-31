#!/usr/bin/env python3
"""Validate battle scene scenario fixture JSON files."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


SCHEMA = "saga2.battle_scene.scenario_state.v0"
STATUSES = {"confirmed", "working_model", "in_progress", "unknown", "rejected"}
HEX_BYTE = re.compile(r"^0x[0-9A-F]{2}$")
HEX_WORD = re.compile(r"^0x[0-9A-F]{4}$")
ROM_BANK_ADDR = re.compile(r"^[0-9A-F]{2}:[0-9A-F]{4}$")
RECORD_BYTES = re.compile(r"^([0-9A-F]{2})( [0-9A-F]{2})*$")


def require_mapping(value: Any, path: str, errors: list[str]) -> dict[str, Any]:
    if not isinstance(value, dict):
        errors.append(f"{path}: expected object")
        return {}
    return value


def require_string(value: Any, path: str, errors: list[str]) -> str:
    if not isinstance(value, str):
        errors.append(f"{path}: expected string")
        return ""
    return value


def require_list(value: Any, path: str, errors: list[str]) -> list[Any]:
    if not isinstance(value, list):
        errors.append(f"{path}: expected array")
        return []
    return value


def check_pattern(
    data: dict[str, Any],
    key: str,
    pattern: re.Pattern[str],
    path: str,
    errors: list[str],
    *,
    allow_unknown: bool = False,
) -> None:
    value = require_string(data.get(key), f"{path}.{key}", errors)
    if allow_unknown and value == "unknown":
        return
    if value and not pattern.match(value):
        errors.append(f"{path}.{key}: invalid value {value!r}")


def validate_scenario(path: Path) -> list[str]:
    errors: list[str] = []
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        return [f"{path}: invalid JSON: {exc}"]

    root = require_mapping(data, "$", errors)
    if require_string(root.get("schema"), "$.schema", errors) != SCHEMA:
        errors.append(f"$.schema: expected {SCHEMA!r}")
    status = require_string(root.get("status"), "$.status", errors)
    if status and status not in STATUSES:
        errors.append(f"$.status: invalid status {status!r}")
    case_id = require_string(root.get("case_id"), "$.case_id", errors)
    if case_id and not re.match(r"^[a-z0-9_]+$", case_id):
        errors.append("$.case_id: use lowercase snake_case")

    source = require_mapping(root.get("source"), "$.source", errors)
    require_string(source.get("rom"), "$.source.rom", errors)
    require_string(source.get("notes"), "$.source.notes", errors)

    command = require_mapping(root.get("command"), "$.command", errors)
    check_pattern(command, "selected_record_id_cff0", HEX_BYTE, "$.command", errors)
    check_pattern(command, "source_flag_cff1", HEX_BYTE, "$.command", errors, allow_unknown=True)
    check_pattern(command, "record_offset", re.compile(r"^0x[0-9A-F]{6}$"), "$.command", errors)
    check_pattern(command, "record_bytes", RECORD_BYTES, "$.command", errors)
    require_string(command.get("visible_label"), "$.command.visible_label", errors)

    targeting = require_mapping(root.get("targeting"), "$.targeting", errors)
    check_pattern(targeting, "target_token_cff3", HEX_BYTE, "$.targeting", errors)
    check_pattern(targeting, "lane_byte_c2a0", HEX_BYTE, "$.targeting", errors)
    check_pattern(targeting, "resolved_cf94", HEX_BYTE, "$.targeting", errors)
    check_pattern(targeting, "destination_base", HEX_WORD, "$.targeting", errors)
    check_pattern(targeting, "destination_pointer", HEX_WORD, "$.targeting", errors)

    rng = require_mapping(root.get("rng"), "$.rng", errors)
    check_pattern(rng, "seed05_entry", HEX_BYTE, "$.rng", errors, allow_unknown=True)
    check_pattern(rng, "rng_table_bank_addr", ROM_BANK_ADDR, "$.rng", errors)
    check_pattern(rng, "rng_table_file_offset", re.compile(r"^0x[0-9A-F]{6}$"), "$.rng", errors)

    state_before = require_mapping(root.get("state_before"), "$.state_before", errors)
    check_pattern(state_before, "destination_hp", HEX_WORD, "$.state_before", errors, allow_unknown=True)
    for key in ("party_actor_records", "enemy_pages"):
        value = state_before.get(key)
        if value != "unknown" and not isinstance(value, list):
            errors.append(f"$.state_before.{key}: expected array or 'unknown'")

    effect = require_mapping(root.get("expected_effect"), "$.expected_effect", errors)
    require_string(effect.get("route"), "$.expected_effect.route", errors)
    require_string(effect.get("amount_expression"), "$.expected_effect.amount_expression", errors)
    require_string(effect.get("write"), "$.expected_effect.write", errors)

    questions = require_list(root.get("open_questions"), "$.open_questions", errors)
    for idx, question in enumerate(questions):
        require_string(question, f"$.open_questions[{idx}]", errors)

    return [f"{path}: {error}" for error in errors]


def iter_scenarios(path: Path) -> list[Path]:
    if path.is_file():
        return [path]
    return sorted(item for item in path.rglob("*.json") if item.is_file())


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "paths",
        nargs="*",
        type=Path,
        default=[Path("docs/scene_packs/battle_scene/scenarios")],
    )
    args = parser.parse_args()

    scenario_paths: list[Path] = []
    for path in args.paths:
        scenario_paths.extend(iter_scenarios(path))

    errors: list[str] = []
    for path in scenario_paths:
        errors.extend(validate_scenario(path))

    if errors:
        for error in errors:
            print(error)
        raise SystemExit(1)

    print(f"validated {len(scenario_paths)} battle scenario file(s)")


if __name__ == "__main__":
    main()
