# Monster Graphics Pack

## Status

working_model

## Purpose

Track monster and battle enemy graphics extraction independently from battle command/effect simulation.

## Read First

1. `open_questions.md`
2. `resource_offsets.md`
3. `../battle_scene/graphics.md`

## Current Model

- Static enemy graphics preload/draw is a working model.
- The current battle pack records anchors around `0F:5D20`, `0F:5DE1`, `0F:5E4D`, `0D:525B`, `0D:5302`, and `04:4700`.
- Repeated enemy count is battle state, not repeated graphics data.
- Current implementation-facing offsets are summarized in `resource_offsets.md`.

## Implementation Relevance

- Graphics extraction should produce small manifests and preview commands before large PNG sets are promoted.
- OAM/effect animation should stay separate from static BG/tilemap rendering.
