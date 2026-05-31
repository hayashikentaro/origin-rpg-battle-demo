# Repository Working Rules

## Directory Indexes

Every maintained source, data, documentation, analysis, scene, test, and tool directory should contain an `INDEX.md` file.

When adding, moving, renaming, or deleting files, update the affected directory indexes in the same change.

Use this command from the repository root to refresh indexes:

```bash
python3 -B tools/update_directory_indexes.py
```

The generator intentionally skips local caches, hidden dependency folders, compiled outputs, and app bundles such as `.git`, `.godot`, `.nuget`, `.dotnet-home`, `bin`, `obj`, `__pycache__`, and `build/OriginalRpgBattleDemo.app`.

`INDEX.md` files are generated inventories. Keep hand-written context in `README.md` or topic documents, not in generated indexes.

## Scene Packs

Use `docs/scene_packs/` as the first stop for scene-specific work.

When adding scene-specific offsets, generated artifacts, runtime-state assumptions, implementation notes, or open questions, update the relevant scene pack in the same change. If no pack exists for that scene, create a small pack with a `README.md` and `open_questions.md` before adding broad notes elsewhere.

Scene packs should link to heavy historical reports instead of duplicating them. They should stay small enough for future Codex/GPT sessions to read first.
