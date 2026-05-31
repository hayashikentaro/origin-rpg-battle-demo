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
