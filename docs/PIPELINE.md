# Production Pipeline

## A. Level Brief

Define:

- Emotional goal.
- Gameplay goal.
- Narrative beat.
- Player start.
- Player end.
- Acceptance criteria.

## B. Blockout + Logic First

Must prove:

- Player location.
- Walkable area.
- Exit.
- Interactions.
- Collision boundaries.
- No absurd positioning.

## C. Manual Playtest

Must prove:

- Player moves.
- Player cannot leave playable area.
- Player can reach goal.
- Interactions work.

## D. Readability Review

Must prove:

- Scene is readable without UI.
- Exit is readable.
- Important object is readable.
- Player is readable.

## E. Visual Direction Proposal

Before Visual Pass, the team must propose 3 distinct visual directions.

The team must not implement visuals yet.

Each visual direction must include:

- Name.
- Mood.
- Lighting setup.
- Color palette.
- Visual focus.
- Emotional effect.
- Why it fits the game.
- What assets or placeholder techniques are required.
- Risks or limitations.

The 3 options must be meaningfully different in:

- Lighting.
- Mood.
- Composition.
- Color.
- Player focus.

All options must follow the Visual Baseline:

- Isometric / 45-degree visual language.
- Clean world, not ruins.
- Warm light against cold ambient tone.
- Believable human scale.
- No flat-color blockout as final output.

The team must stop and wait for user selection.

Visual Pass cannot begin until the user chooses one direction.

## F. Visual Pass

Only after:

- Blockout passed.
- Manual playtest passed.
- Readability review passed.
- User selected one visual direction.

The visual pass must not break gameplay.

The selected visual direction must be followed strictly.

Must preserve:

- Layout.
- Collision boundaries.
- Player start.
- Exit.
- Required interactions.
- Readability.

Must improve:

- Lighting.
- Depth.
- Material clarity.
- Atmosphere.
- Visual focus.

If the level still looks like blockout or prototype, Visual Pass is not complete.

The Visual Pass must be evaluated against:

- docs/VISUAL_BASELINE.md
- docs/VISUAL_REFERENCE.md

If the scene does not move toward the reference:
→ Visual Pass is not complete

Visual Pass has two required sub-passes:

### F1. Background / Lighting / Composition

Must prove:

- The actual in-game background is visible.
- The scene follows the selected visual direction.
- Lighting has a clear source and soft falloff.
- Materials are readable.
- Space has foreground, midground, and background.
- The room does not look like abstract geometry.

### F2. Gameplay Integration

Must prove:

- Player visually belongs in the scene.
- Player is a readable character placeholder, not an arrow or marker.
- Player scale matches furniture and room size.
- Screen and door visuals match their interaction areas.
- Visual room boundaries match gameplay boundaries.
- Visible solid props block movement.
- Required path to screen and door remains open.

Visual Pass is not complete until both F1 and F2 pass.

## G. Scale Consistency Pass

Run after Visual Pass and before Collision Alignment Pass.

Must prove:

- Player height is believable compared to the door.
- Bed appears usable by the player.
- Sofa, chairs, table, shelves, and TV console match human scale.
- Screen and window are not absurdly large or small relative to the player.
- Player shadow/feet ground the character on the floor.
- Player sprite uses a foot-anchor: visual feet, shadow, and collision footprint align.
- Player does not look pasted onto the background.
- Interaction distance at screen and door feels plausible.

If player scale and environment scale do not match:
→ return to Visual Pass or player visual adjustment

## H. Collision Alignment Pass

Run after Visual Pass and after every meaningful visual layout change.

Must prove:

- Level has explicit walkable/forbidden foot-anchor zones, not only approximate visible art.
- Player cannot leave the visible playable room/floor.
- Player cannot walk through bed, sofa, tables, TV console, shelves, or other visible solid objects.
- Player start is inside the visible room.
- Screen is reachable.
- Door is reachable.
- No major invisible blocker interrupts the main route.

If collision space and visual space do not match:
→ return to Collision Alignment Pass

Collision implementation rule:

- The player origin is the foot anchor.
- Walkability is judged by the foot anchor.
- Solid furniture is represented as forbidden foot polygons.
- Physics collision shapes may support movement, but they are not the only source of truth.

## I. Screenshot Gate

Before Final QA, inspect the current playable scene as an image.

Accepted sources:

- Godot screenshot.
- User screenshot.
- Equivalent editor/game capture.

Built-in capture path:

- Press F12 during graphical playtest.
- Or run graphically with `--capture-screenshot`.
- Output file: `res://docs/reference/current_level_screenshot.png`.
- Headless capture does not count for Screenshot Gate.

Must prove:

- Background art is visible.
- Selected visual direction is visible.
- Player is visible and grounded.
- Door, screen, and walkable area are readable.
- No layer-order issue hides the scene.
- No obvious camera/framing problem exists.

If no screenshot was reviewed:
→ Ready for user playtest: NO

## J. Feeling Pass

Add sound, silence, pacing, and atmosphere after the level already works and after Visual Pass is accepted.

Feeling Pass may add:

- Ambient sound.
- Silence moments.
- Minimal text.
- Interaction pacing.
- Subtle state changes.

Feeling Pass must not add new major mechanics.

## K. Final QA

Run a regression check after each meaningful change.

Confirm:

- Godot reports no scene/resource/script/import/parse errors.
- No core behavior was broken by visual, narrative, or pacing edits.
- Player can still move.
- Player cannot leave playable space.
- Player cannot walk through visible solid furniture.
- Player scale matches environment scale.
- Interactions still work.
- Exit still works.
- Debug UI can be hidden.
- The level no longer looks like raw blockout.
- Screenshot Gate passed.
- Collision Alignment Pass passed.
- Scale Consistency Pass passed.

Automated QA only proves technical checks. It does not replace Screenshot Gate or manual playtest.
