# Acceptance Protocol

Manual playtest is the source of truth.

Codex cannot close a bug that requires user confirmation.

Ready for next stage = YES only if:

- automated checks pass
- automated checks contain no project scene/resource/script/import/parse/runtime errors
- internal review passes
- Screenshot Gate passes when visual work is involved
- Collision Alignment Gate passes when visual layout or playable space changed
- Scale Consistency Gate passes when player, camera, or environment art changed
- manual playtest instructions are clear
- no known blockers remain

If the user says manual test failed:

- Ready becomes NO
- create an open bug
- fix only that bug unless the user expands scope
- do not proceed as if accepted

## Continuation Protocol

Do not stop in the middle of a task without an explicit reason.

A local fix, commit, push, screenshot, or single automated QA pass is not a stopping point by itself.

The team may stop only when:

- the requested work reached a clear acceptance report
- user manual playtest confirmation is required
- a blocker remains after 3 fix attempts
- a user taste/design decision is required
- continuing would exceed the active task scope
- the user explicitly asks to pause, stop, or wait

If a bug escaped existing checks:

- Ready becomes NO for the affected gate
- add or strengthen the relevant automated check when possible
- update the relevant pipeline/documentation rule if the failure represents a process gap
- rerun the relevant QA gates
- report the remaining status honestly

## Visual Direction Acceptance

VISUAL PASS cannot start until the user selects one visual direction.

If no visual direction has been selected:

`Ready for VISUAL PASS: NO`

The team must propose 3 options before Visual Pass.

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

After user selection:

`Ready for VISUAL PASS: YES`

The selected direction becomes binding.

If Visual Pass does not follow the selected direction:

- Ready becomes NO
- return to Visual Pass
- fix only visual direction mismatch unless other blockers are found

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
  - How it fits the active project profile:
  - Required assets or placeholder techniques:
  - Risks or limitations:

- Option 2:
  - Name:
  - Mood:
  - Lighting setup:
  - Color palette:
  - Visual focus:
  - Emotional effect:
  - How it fits the active project profile:
  - Required assets or placeholder techniques:
  - Risks or limitations:

- Option 3:
  - Name:
  - Mood:
  - Lighting setup:
  - Color palette:
  - Visual focus:
  - Emotional effect:
  - How it fits the active project profile:
  - Required assets or placeholder techniques:
  - Risks or limitations:

- Waiting for user selection: YES
- Ready for VISUAL PASS: NO

## Visual Reference Check

During Visual Pass and Final QA, compare the playable scene to:

- `docs/VISUAL_REFERENCE.md`
- the active project reference
- the selected visual direction

If:

- lighting or value structure does not support the selected direction
- camera/view style contradicts the project profile
- scene lacks required depth or clarity
- player does not visually belong

then:

- Ready becomes NO
- return to Visual Pass

## Screenshot Gate Acceptance

Automated QA passed does not mean the level is visually ready.

Before `Ready for user playtest: YES`, the team must review a current in-game screenshot or equivalent playable-scene capture when the task affects visuals, camera, character, environment, layout, or scale.

Screenshot Gate fails if:

- background art is hidden
- scene looks like blockout
- selected visual direction is not visible
- player appears outside playable space
- player looks like an unintended abstract marker
- required interactions, player, goal, or walkable area are unreadable
- camera framing hides required gameplay space
- a layer-order problem is visible

If Screenshot Gate fails:

- Visual QA: FAIL
- Ready for user playtest: NO
- fix the visible issue before reporting completion

## Collision Alignment Acceptance

Collision space must match visible space.

Collision Alignment Gate fails if:

- no explicit walkable/blocked zones exist for the level
- foot-anchor movement levels do not expose editable walkable and no-feet layers, or an equivalent visible editor representation
- player can leave visible playable space
- player can pass through visible solid props, furniture, walls, terrain, or blockers
- player can stand on visible non-floor surfaces such as wall planes, doors, windows, furniture tops, shelves, or decorative vertical planes
- player cannot reach required interactions
- player cannot reach exit or progression target
- player start is outside visible playable space
- invisible walls block the main path in a way that contradicts the image
- automated collision QA only checks a few hand-picked points instead of dense coverage for no-feet zones

If Collision Alignment Gate fails:

- Collision QA: FAIL
- Ready for user playtest: NO
- fix collision only unless the visual layout is the root cause

## Scale Consistency Acceptance

Player scale must be believable against the environment.

Scale Consistency Gate fails if:

- player looks too small or too large compared to the level's scale anchors
- required interaction objects do not feel usable next to the player
- player contact cue does not ground the character
- player sprite/model is not anchored to the gameplay footprint/contact point
- player looks pasted over the background
- interaction distance looks absurd
- camera zoom or background scaling breaks scale

If Scale Consistency Gate fails:

- Visual QA: FAIL
- Ready for user playtest: NO
- adjust player scale, camera, art scale, or environment composition before proceeding

## Error Gate Acceptance

Engine/tool errors are blockers even if a test script prints PASS.

Blocking errors include:

- scene parse errors
- missing resources
- failed script compilation
- missing imports
- invalid node paths or missing scene references
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
