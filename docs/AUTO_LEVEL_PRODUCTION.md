# Auto Level Production Mode

Goal:
Build complete playable levels, not intermediate blockouts.

The team must run the full pipeline internally:

1. Level Brief
2. Blockout + Logic
3. Manual Playtest Preparation
4. Readability Review
5. Visual Direction Proposal
6. Visual Pass
7. Feeling Pass
8. Final QA

Do not stop after intermediate stages unless there is a blocker that cannot be resolved without user input.

Intermediate stages must be handled internally.

Final output only:
- playable level
- final report
- manual test steps
- known limitations

## Stop Conditions

Stop and ask user only if:

- manual playtest is required and cannot be simulated
- a blocker cannot be fixed after 3 attempts
- design decision requires user taste/approval
- visuals would require external assets not available in project
- visual direction has not been selected by the user

## Visual Direction Gate

Before VISUAL PASS, the team must stop and propose 3 visual directions.

Do not implement visuals before user selection.

Each option must include:

- Name
- Mood
- Lighting setup
- Color palette
- Visual focus
- Emotional effect
- Why it fits the game
- Required assets or placeholder techniques
- Risks or limitations

The 3 options must be meaningfully different.

They must all follow:

- isometric / 45-degree visual language
- clean world, not ruins
- warm light + cold ambient contrast
- believable human scale
- emotional loneliness
- no debug-looking final scene
- no flat rectangles as final output

After presenting the 3 options:

- stop
- wait for user choice
- do not proceed to Visual Pass

After user selection:

- continue automatically with Visual Pass
- follow the chosen direction strictly

## Internal Loop

For each stage:

1. Implement
2. Self-review
3. Fix blockers
4. Re-test
5. Continue to next stage

Exception:
Visual Direction Proposal must stop for user selection.

## Final Acceptance

A level is not ready unless:

- automated QA passes with no scene/resource/script/import/parse errors
- current in-game screenshot was reviewed
- screenshot visibly follows the selected visual direction
- collision alignment pass is complete
- scale consistency pass is complete
- player can move
- player cannot leave playable space
- player cannot walk through visible solid furniture or props
- player can still reach every required interaction
- required interactions work
- exit condition works
- scene is readable without debug labels
- debug UI can be hidden
- visual direction was selected by user
- visual pass follows selected direction
- visual pass improves atmosphere
- player is represented as a readable character silhouette, not a marker
- player scale is believable against door, bed, sofa, table, screen, and room
- feeling pass adds pacing/audio/text moments
- final QA finds no blocking issues

## Final Report Format

FINAL LEVEL REPORT:

- Level:
- Built:
- Gameplay:
- Narrative:
- Selected visual direction:
- Visual:
- Feeling:
- Files changed:
- Manual test steps:
- Known limitations:
- Ready for user playtest: YES/NO
- Ready as finished level: YES/NO

VISUAL QUALITY IS NOT OPTIONAL.

Visual Reference is mandatory.

Use:
docs/VISUAL_REFERENCE.md

The final scene must move toward that reference.

If visual direction deviates significantly:
→ continue Visual Pass

If final scene looks like blockout or prototype:
→ pipeline is NOT complete

Do NOT return final level until:

- an actual in-game screenshot has been checked
- scene visually matches the selected reference quality direction
- lighting is present
- materials exist
- depth is visible
- player visually belongs to the scene
- space feels real, not schematic
- visible room boundaries match gameplay boundaries
- visible furniture and solid props block movement
- the player can reach the required path, screen, and door
- player scale matches the environment and does not look pasted onto the scene

If assets are missing:

- create temporary textured placeholders
- use gradients, noise, lighting, color variation
- clearly list what should later be replaced by real art

Flat color rectangles are forbidden in final output.

## Screenshot Gate

Before returning `Ready for user playtest: YES`, the team must inspect the current playable scene as an image.

Accepted sources:

- a screenshot produced from Godot
- a screenshot supplied by the user
- an equivalent in-editor visual capture

Built-in project capture:

- Press F12 during a graphical playtest to save `res://docs/reference/current_level_screenshot.png`.
- Or run the game graphically with `--capture-screenshot` to auto-save the same file after a short delay.
- Headless Godot does not satisfy Screenshot Gate because it may use a dummy renderer.

If no current screenshot is available:

- Visual QA: FAIL
- Ready for user playtest: NO

Screenshot Gate must fail if:

- the background art is hidden or covered by another layer
- the scene looks like raw blockout
- camera framing cuts off required gameplay space
- player appears outside the room
- player looks like a cursor, arrow, diamond, or abstract marker
- door, screen, player, or exit path are unreadable
- visual target and selected direction are not clearly reflected

Automated QA passing is not enough. Screenshot Gate is mandatory.

## Collision Alignment Gate

Before returning `Ready for user playtest: YES`, gameplay space must be checked against the visible scene.

Must prove:

- level has explicit walkable/forbidden foot-anchor zones
- player cannot leave the visible room/floor area
- player cannot walk through bed, sofa, tables, TV console, shelves, or other visible solid props
- player can reach the screen interaction
- player can reach the door interaction
- player start is inside the visible playable floor
- collision boundaries do not create absurd invisible walls on the main path

If visual art changes, Collision Alignment Gate must run again.

Collision implementation rule:

- Player origin is the foot anchor.
- Walkability is judged by the foot anchor.
- Solid furniture must be represented as forbidden foot polygons.
- Approximate physics bodies alone are not enough for final acceptance.

## Scale Consistency Gate

Before returning `Ready for user playtest: YES`, player scale must be checked against the visible environment.

Must prove:

- player height is believable compared to the door
- bed appears usable by the player
- sofa/chairs/tables appear human-scale
- TV/screen, window, shelves, and props do not make the player look tiny or giant
- player shadow/feet make the character feel grounded
- player sprite uses a foot-anchor: visual feet, shadow, and collision footprint align
- player does not look pasted over the background art
- interaction distance feels plausible at screen and door

Scale Consistency Gate must run again if:

- player sprite/scene changes
- background art changes
- camera zoom changes
- room art is rescaled
- major furniture or door art changes

If player scale feels wrong:

- Visual QA: FAIL
- Ready for user playtest: NO
- adjust player scale, camera, art scale, or scene composition before proceeding

## Error Gate

Any Godot output containing scene, script, resource, import, or parse errors blocks readiness.

If Godot reports such errors:

- Automated QA: FAIL
- Ready for user playtest: NO
- fix the error before reporting completion

Warnings may be documented separately, but errors tied to the project cannot be ignored even if a test script prints PASS.
