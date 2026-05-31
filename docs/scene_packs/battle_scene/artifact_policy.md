# Battle Scene Artifact Policy

## Status

working_model

## Purpose

Battle-scene work produces two different artifact classes:

- small committed analysis artifacts that future sessions should read
- bulky or regenerable local extraction outputs that should not become default context

Keep those classes separate so scene work stays reproducible without forcing every future session to inspect generated files.

## Committed By Default

Commit small artifacts when they are stable and useful as entrypoints:

- Markdown summaries under `docs/scene_packs/battle_scene/`
- small JSON scenario fixtures under `docs/scene_packs/battle_scene/scenarios/`
- binary-analysis summaries under `docs/binary_analysis/`
- generated directory `INDEX.md` files
- source tools under `tools/`

## Local / Regenerable By Default

Keep these local unless deliberately promoted:

- `build/rom_extracts/**`
- extracted PNG previews
- `.png.import` files
- extracted stage/tile binary blobs
- broad scratch outputs from one-off ROM extraction experiments

The repository keeps `INDEX.md` files inside `build/rom_extracts/` as directory signposts, but ignores generated extraction contents by default.

## Promotion Rule

Promote a local artifact only when all of these are true:

- it answers a current scene-pack question
- it is small enough to be reviewed directly
- its source tool and source ROM assumptions are documented
- `generated_artifacts.md` links to it
- any copied ROM-derived data is limited to the minimum needed for analysis

If the artifact is large or easy to regenerate, prefer documenting the command/tool instead of committing the output.

## Current Decision

`build/rom_extracts/` remains a local generated-output namespace. Future scene work may add committed manifests or tiny fixtures elsewhere when they become canonical.
