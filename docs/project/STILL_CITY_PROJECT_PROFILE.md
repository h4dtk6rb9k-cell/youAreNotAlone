# Still City Project Profile

This file is project-specific and should not be copied into another game unchanged.

## Project Identity

- Working title: Still City
- Genre: short atmospheric 2D narrative game
- Target duration: 2-3 hours
- Target platform: mobile-first, portrait by default, desktop testing supported
- Primary input: touch architecture with keyboard testing
- Engine/toolchain: Godot 4 Standard, GDScript

## Creative Pillars

- A living person should feel rare and precious.
- The world functions, but identity has faded through comfort and passive consumption.
- Silence and restraint matter more than spectacle.

## Visual Profile

- Camera/view style: fake-isometric / 45-degree 2D
- Composition language: clean modern inhabited spaces, lonely but not ruined
- Lighting rules: warm windows or interior sources against cold ambient streets/rooms
- Color balance: warm human traces, cold environmental quiet
- Material/rendering style: believable clean interiors, soft shadows, visible depth
- Character scale rule: human scale must match doors, furniture, windows, and interaction objects
- Reference image path: `docs/project/reference/visual_target.png`

## Gameplay Profile

- Core verbs: move, explore, interact, read sparse text, transition levels
- Required systems: player movement, interaction, dialogue, level transition, state flags, audio mood
- Forbidden systems: combat, inventory, leveling, shop, crafting, open world, HUD-heavy UI
- UI density: minimal
- Failure states: locked progression states are allowed; punitive failure is not core

## Level Design Rules

- Required start clarity: player starts in a readable lived-in space
- Required goal clarity: next progression target should be readable without HUD
- Walkable-space rule: visual floor and gameplay floor must match
- Solid-object rule: furniture and walls block the foot anchor
- Interaction-distance rule: interactions must feel physically plausible
- Exit/progression rule: exit becomes meaningful after the narrative beat is complete

## Narrative Profile

- Dialogue density: minimal, short lines
- Environmental storytelling rules: objects imply routines continuing without identity
- NPC presence rules: rare human contact should feel important
- Emotional pacing rules: silence, pauses, and absence carry meaning

## Acceptance Overrides

- Screenshot Gate is mandatory for visual work.
- Scale Consistency Gate is mandatory after every player, camera, or background change.
- Collision Alignment Gate must prove the player cannot walk through furniture or leave visible space.

## Screenshot Capture

- Manual capture: run Godot with a graphics window and press `F12`.
- Automatic graphical capture: run `tools/capture_level_screenshot.sh`.
- Finder/Terminal helper: run `tools/capture_level_screenshot.command`.
- Codex-driven capture: keep `tools/screenshot_capture_agent.command` open, then Codex can request screenshots with `tools/request_screenshot.sh`.
- Output path: `res://docs/reference/current_level_screenshot.png`.
- Headless Godot does not satisfy Screenshot Gate.
- Codex Desktop may be unable to open a macOS AppKit graphics window directly from its sandbox. In that case, run the capture script from a normal Terminal window or provide a manual screenshot.
