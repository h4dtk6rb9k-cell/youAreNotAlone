# Production Pipeline

This is a generic level-production pipeline.

Project-specific rules come from:

- `docs/GAME_OVERVIEW.md`
- `docs/PROJECT_PROFILE.md` if present
- active level brief
- selected visual direction

## A. Level Brief

Define:

- Emotional goal.
- Gameplay goal.
- Narrative beat.
- Player start.
- Player end or progression target.
- Required interactions.
- Acceptance criteria.

## B. Blockout + Logic First

Must prove:

- player start location
- walkable area
- blocked area
- required goal or exit
- required interactions
- collision boundaries
- no absurd positioning

## C. Manual Playtest Preparation

Must provide steps that prove:

- player moves
- player cannot leave playable area
- player can reach the goal
- interactions work
- lock/unlock or state changes work where relevant

## D. Readability Review

Must prove:

- scene is readable without debug UI
- player is readable
- required interactions are readable
- goal or exit is readable
- walkable and blocked spaces are understandable

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
- How it fits the active project profile.
- Required assets or placeholder techniques.
- Risks or limitations.

The 3 options must be meaningfully different in:

- lighting
- mood
- composition
- color
- player focus

All options must follow:

- `docs/VISUAL_BASELINE.md`
- `docs/VISUAL_REFERENCE.md`
- the active project profile

The team must stop and wait for user selection.

Visual Pass cannot begin until the user chooses one direction.

## F. Visual Pass

Only after:

- blockout passed
- manual playtest preparation passed
- readability review passed
- user selected one visual direction

The visual pass must not break gameplay.

The selected visual direction must be followed strictly.

Must preserve:

- layout
- collision boundaries
- player start
- exit or progression target
- required interactions
- readability

Must improve:

- lighting
- depth
- material or surface clarity
- atmosphere
- visual focus

If the level still looks like blockout or prototype, Visual Pass is not complete.

Visual Pass has two required sub-passes.

## F1. Background / Lighting / Composition

Must prove:

- actual in-game background is visible
- selected visual direction is present
- lighting has clear intent
- materials or surfaces support the chosen style
- space has readable depth
- scene does not look like abstract geometry unless that is the approved final style

## F2. Gameplay Integration

Must prove:

- player visually belongs in the scene
- player representation matches the project profile
- player scale matches the environment
- required interactions match their visible objects or locations
- visible boundaries match gameplay boundaries
- visible solid blockers block movement
- required path remains open

Visual Pass is not complete until both F1 and F2 pass.

## G. Scale Consistency Pass

Run after Visual Pass and before Collision Alignment Pass.

Must prove:

- player size is believable against the level's scale anchors
- interaction objects appear usable
- entrances, exits, props, and architecture are coherent with the player
- player contact cue grounds the character
- player does not look pasted onto the background
- interaction distance feels plausible

If player scale and environment scale do not match:

`Return to Visual Pass or player visual adjustment.`

## H. Collision Alignment Pass

Run after Visual Pass and after every meaningful visual layout change.

Must prove:

- level has explicit walkable and blocked gameplay zones
- player cannot leave visible playable space
- player cannot pass through visible solid objects
- player start is inside visible playable space
- required interactions are reachable
- exit or progression target is reachable
- no major invisible blocker interrupts the main route

If collision space and visual space do not match:

`Return to Collision Alignment Pass.`

## I. Screenshot Gate

Before Final QA, inspect the current playable scene as an image when visual quality is involved.

Accepted sources:

- project screenshot
- user screenshot
- equivalent editor/game capture

Headless or dummy-renderer captures do not count for Screenshot Gate.

Must prove:

- background art is visible
- selected visual direction is visible
- player is visible and grounded
- required interactions and walkable area are readable
- no layer-order issue hides the scene
- no obvious camera/framing problem exists

If no screenshot was reviewed:

`Ready for user playtest: NO`

## J. Feeling Pass

Add sound, silence, pacing, text, animation, or atmosphere after the level already works and after Visual Pass is accepted.

Feeling Pass must not add new major mechanics unless the task explicitly asks for them.

## K. Final QA

Run a regression check after each meaningful change.

Confirm:

- no scene/resource/script/import/parse/runtime errors
- no core behavior was broken by visual, narrative, or pacing edits
- player can still move
- player cannot leave playable space
- player cannot pass through visible solid blockers
- player scale matches environment scale
- required interactions still work
- exit or progression condition still works
- debug UI can be hidden
- the level no longer looks like raw blockout
- Screenshot Gate passed when visual work was involved
- Collision Alignment Pass passed
- Scale Consistency Pass passed

Automated QA only proves technical checks. It does not replace Screenshot Gate or manual playtest.
