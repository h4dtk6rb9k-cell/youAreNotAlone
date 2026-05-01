# Still City

Short atmospheric mobile-first 2D narrative game foundation built in Godot 4.

## Current State

Level 01: Apartment is the current playable level.

Core features:

- Godot 4 Standard project.
- Reusable core systems for state, scene loading, interaction, dialogue, audio state, and screenshots.
- Mobile portrait baseline with desktop keyboard testing.
- Level 01 apartment scene with visual pass, interaction logic, dialogue, collision gates, and screenshot workflow.

## Run

Open this folder in Godot 4 and run the project.

Desktop controls:

- Move: `WASD` or arrow keys
- Interact: `E`, `Enter`, or `Space`
- Save screenshot: `F12`

Screenshots are saved to:

`docs/reference/current_level_screenshot.png`

## QA

Run Level 01 checks with Godot:

```bash
Godot --headless --path . --script res://tests/qa_level_01.gd
```

Headless QA checks logic and structure. Visual acceptance still requires a real rendered screenshot.

## Production Rules

See:

- `docs/AUTO_LEVEL_PRODUCTION.md`
- `docs/PIPELINE.md`
- `docs/ACCEPTANCE_PROTOCOL.md`
- `docs/VISUAL_BASELINE.md`
- `docs/VISUAL_REFERENCE.md`
