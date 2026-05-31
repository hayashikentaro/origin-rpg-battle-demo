# Scene Packs

Scene packs are small entrypoints for work on one concrete game scene.

Use them before opening broad analysis archives. A scene pack should say what is needed for the scene, what is already known, what remains unknown, and which generated artifacts are useful.

## Read Order

1. Pick the scene directory.
2. Read that scene's `README.md`.
3. Read only the focused files named by the scene pack.
4. Open `analysis_updates/` history only when the scene pack points to a specific report.

## Current Packs

- `battle_scene/` - battle screen reconstruction and command/effect execution.

## Rule

When a new scene-specific fact, artifact, tool, or open question is added, update the relevant scene pack in the same change.

Keep cross-scene facts in shared documentation rather than duplicating them into every scene pack.
