# Auto Level Production Mode

Goal:
Build complete playable levels, not intermediate blockouts.

The team must read the active project context before production:

- `docs/GAME_OVERVIEW.md`
- `docs/PROJECT_PROFILE.md` if present
- `docs/VISUAL_REFERENCE.md`
- level brief or task brief

## Required Pipeline

Run the full pipeline internally:

1. Level Brief
2. Blockout + Logic
3. Manual Playtest Preparation
4. Readability Review
5. Visual Direction Proposal
6. Visual Pass
7. Scale Consistency Pass
8. Collision Alignment Pass
9. Screenshot Gate
10. Feeling Pass
11. Final QA

Do not stop after intermediate stages unless there is a blocker that cannot be resolved without user input.

Intermediate stages must be handled internally.

Final output only:

- playable level
- final report
- manual test steps
- known limitations

## Stop Conditions

Stop and ask the user only if:

- manual playtest is required and cannot be simulated
- a blocker cannot be fixed after 3 attempts
- design direction requires user taste or approval
- visuals would require external assets not available in the project
- visual direction has not been selected by the user

## Visual Direction Gate

Before Visual Pass, the team must stop and propose 3 visual directions.

Do not implement visuals before user selection.

Each option must include:

- Name
- Mood
- Lighting setup
- Color palette
- Visual focus
- Emotional effect
- How it fits the active project profile
- Required assets or placeholder techniques
- Risks or limitations

The 3 options must be meaningfully different.

All options must follow:

- the active project visual profile
- the selected reference direction
- believable player/environment scale
- readable gameplay space
- no debug-looking final scene
- no raw blockout as final output

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
- current in-game screenshot was reviewed when visual work is involved
- screenshot visibly follows the selected visual direction
- collision alignment pass is complete
- scale consistency pass is complete
- player can move according to the project controls
- player cannot leave playable space
- player cannot pass through visible solid blockers
- player can reach every required interaction
- required interactions work
- exit or progression condition works
- scene is readable without debug labels
- debug UI can be hidden
- visual direction was selected by user
- visual pass follows selected direction
- visual pass improves atmosphere and clarity
- player is represented according to the project profile
- player scale is believable against the level's scale anchors
- feeling pass adds pacing, audio, text, or atmosphere as appropriate
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
- Logic QA: PASS/FAIL
- Visual QA: PASS/FAIL
- Collision QA: PASS/FAIL
- Scale QA: PASS/FAIL
- Feeling QA: PASS/FAIL
- Ready for user playtest: YES/NO
- Ready as finished level: YES/NO

## Screenshot Gate

Before returning `Ready for user playtest: YES`, the team must inspect the current playable scene as an image when visual output is part of the task.

Accepted sources:

- screenshot produced by the project
- screenshot supplied by the user
- equivalent in-editor visual capture

Headless or dummy-renderer captures do not satisfy Screenshot Gate.

If no current screenshot is available:

- Visual QA: FAIL
- Ready for user playtest: NO

Screenshot Gate must fail if:

- background art is hidden or covered by another layer
- scene looks like raw blockout
- camera framing cuts off required gameplay space
- player appears outside playable space
- player looks like an unintended marker
- required interactions, player, exit, or walkable area are unreadable
- selected visual direction is not clearly reflected

Automated QA passing is not enough. Screenshot Gate is mandatory for visual acceptance.

## Collision Alignment Gate

Before returning `Ready for user playtest: YES`, gameplay space must be checked against the visible scene.

Must prove:

- level has explicit walkable and blocked gameplay zones
- foot-anchor levels expose editable `WalkableFloor` and `NoFeetZones` or an equivalent scene-layer representation
- player cannot leave visible playable space
- player cannot pass through visible solid blockers
- player cannot stand on non-floor surfaces such as doors, windows, wall planes, furniture tops, shelves, or decorative vertical planes
- player can reach every required interaction
- player can reach the exit or progression target
- player start is inside visible playable space
- collision boundaries do not create absurd invisible blockers on the main path
- automated QA samples no-feet zones densely enough to catch gaps that hand-picked points miss

If visual art changes, Collision Alignment Gate must run again.

## Scale Consistency Gate

Before returning `Ready for user playtest: YES`, player scale must be checked against visible environment scale anchors.

Must prove:

- player size is believable against entrances, exits, interaction objects, props, and architecture
- player contact point makes the character feel grounded
- player does not look pasted over the environment
- interaction distance feels plausible

Scale Consistency Gate must run again if:

- player visual changes
- background or environment art changes
- camera zoom changes
- room/world art is rescaled
- major scale-anchor props change

If player scale feels wrong:

- Visual QA: FAIL
- Ready for user playtest: NO
- adjust player scale, camera, art scale, or scene composition before proceeding

## Error Gate

Any output containing scene, script, resource, import, parse, or blocking runtime errors blocks readiness.

If errors appear:

- Automated QA: FAIL
- Ready for user playtest: NO
- fix the error before proceeding
