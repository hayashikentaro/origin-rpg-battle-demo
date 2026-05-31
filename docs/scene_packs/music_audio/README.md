# Music Audio Pack

## Status

in_progress

## Purpose

Keep music and audio resource investigation separate from battle graphics/text/command work.

## Read First

1. `open_questions.md`
2. `../battle_scene/generated_artifacts.md`

## Current Model

- `0x7AEE` is a current music anchor extraction range.
- The local `build/rom_extracts/music_anchor_7aee/` output is useful exploration material but is not committed as canonical data.
- Music script ownership and playback semantics are not yet summarized as an implementation-facing spec.

## Implementation Relevance

- Audio work should promote small manifests or decoded command tables before committing raw extracted blobs.
- Do not mix music anchors into battle-scene command execution docs unless a battle scene directly references the playback path.
