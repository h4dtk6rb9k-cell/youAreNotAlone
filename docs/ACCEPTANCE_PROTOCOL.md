# Acceptance Protocol

Manual playtest is the source of truth.

Codex cannot close a bug that requires user confirmation.

Ready for next stage = YES only if:

- Automated checks pass.
- Automated checks contain no project scene/resource/script/import/parse errors.
- Internal review passes.
- Screenshot Gate passes when visual work is involved.
- Collision Alignment Gate passes when visual layout or playable space changed.
- Scale Consistency Gate passes when player, camera, or environment art changed.
- Manual playtest instructions are clear.
- No known blockers remain.

If the user says manual test failed:

- Ready becomes NO.
- Create an open bug.
- Fix only that bug.
- Do not proceed.

## Visual Direction Acceptance

VISUAL PASS cannot start until the user selects one visual direction.

If no visual direction has been selected:

- Ready for VISUAL PASS: NO

The team must propose 3 options before Visual Pass.

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

After user selection:

- Ready for VISUAL PASS: YES

The selected direction becomes binding.

If Visual Pass does not follow the selected direction:

- Ready becomes NO
- return to Visual Pass
- fix only visual direction mismatch

## Required Report After Each Task

ACCEPTANCE REPORT:

- Stage:
- What changed:
- What was tested:
- Passed:
- Failed:
- Blockers:
- Manual test instructions:
- Ready for next stage: YES/NO

## Required Report Before Visual Pass

VISUAL DIRECTION REPORT:

- Option 1:
  - Name:
  - Mood:
  - Lighting setup:
  - Color palette:
  - Visual focus:
  - Emotional effect:
  - Why it fits the game:
  - Required assets or placeholder techniques:
  - Risks or limitations:

- Option 2:
  - Name:
  - Mood:
  - Lighting setup:
  - Color palette:
  - Visual focus:
  - Emotional effect:
  - Why it fits the game:
  - Required assets or placeholder techniques:
  - Risks or limitations:

- Option 3:
  - Name:
  - Mood:
  - Lighting setup:
  - Color palette:
  - Visual focus:
  - Emotional effect:
  - Why it fits the game:
  - Required assets or placeholder techniques:
  - Risks or limitations:

- Waiting for user selection: YES
- Ready for VISUAL PASS: NO

## Visual Reference Check

During Visual Pass and Final QA:

The level must be compared to:

docs/VISUAL_REFERENCE.md

If:

- lighting is significantly flatter
- composition is not isometric
- scene lacks depth
- player does not visually belong

→ Ready becomes NO
→ return to Visual Pass

## Screenshot Gate Acceptance

Automated QA passed does not mean the level is visually ready.

Before `Ready for user playtest: YES`, the team must review a current in-game screenshot or equivalent playable-scene capture.

The project includes `ScreenshotManager`:

- F12 saves `res://docs/reference/current_level_screenshot.png`.
- A graphical run with `--capture-screenshot` auto-saves the same file.
- Headless Godot does not satisfy Screenshot Gate.

Screenshot Gate fails if:

- background art is hidden
- scene looks like blockout
- selected visual direction is not visible
- player appears outside the room
- player looks like an abstract marker
- screen, door, player, or walkable area are unreadable
- camera framing hides required gameplay space
- a layer-order problem is visible

If Screenshot Gate fails:

- Visual QA: FAIL
- Ready for user playtest: NO
- fix the visible issue before reporting completion

## Collision Alignment Acceptance

Collision space must match visible space.

Collision Alignment Gate fails if:

- no explicit walkable/forbidden foot-anchor zones exist for the level
- player can leave the visible room/floor
- player can walk through visible solid furniture or props
- player cannot reach the screen
- player cannot reach the door
- player start is outside visible playable space
- invisible walls block the main path in a way that contradicts the image

If Collision Alignment Gate fails:

- Collision QA: FAIL
- Ready for user playtest: NO
- fix collision only unless the visual layout is the root cause

## Scale Consistency Acceptance

Player scale must be believable against the environment.

Scale Consistency Gate fails if:

- player looks too small or too large compared to the door
- bed, sofa, chairs, table, shelves, or TV console do not feel human-scale next to the player
- player shadow or feet do not ground the character
- player sprite is not foot-anchored to the collision footprint
- player looks pasted over the background
- interaction distance at the screen or door looks absurd
- camera zoom or background scaling breaks human scale

If Scale Consistency Gate fails:

- Visual QA: FAIL
- Ready for user playtest: NO
- adjust player scale, camera, art scale, or environment composition before proceeding

## Error Gate Acceptance

Godot errors are blockers even if a test script prints PASS.

Blocking errors include:

- scene parse errors
- missing resources
- failed script compilation
- missing imports
- invalid node paths used by gameplay scripts
- runtime errors caused by the current scene

If any blocking error appears:

- Automated QA: FAIL
- Ready for user playtest: NO
- fix the error before proceeding

Non-project platform warnings may be documented, but must not hide project errors.

## QA Status Labels

Final reports must distinguish:

- Logic QA: PASS/FAIL
- Visual QA: PASS/FAIL
- Collision QA: PASS/FAIL
- Scale QA: PASS/FAIL
- Feeling QA: PASS/FAIL
- Manual Playtest Required: YES/NO

`QA Level PASS` is not enough by itself.
