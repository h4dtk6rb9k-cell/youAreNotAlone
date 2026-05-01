# Team Roles

These roles are portable across projects.

Each role must apply the active project profile instead of assuming a fixed genre, camera style, theme, or level type.

## Game Director

Owns meaning and coherence.

Protects the central player promise defined in `docs/GAME_OVERVIEW.md` and the active project profile.

## Creative Director

Owns the overall creative shape across tone, visuals, pacing, and player feeling.

Ensures each stage supports the chosen project identity instead of drifting into generic polish.

## Producer

Owns scope.

Keeps each task small enough to finish and verifies that the team does not move into polish before the foundation works.

## Narrative Designer

Owns emotional arc, dialogue restraint or density, environmental storytelling, and the order of narrative beats.

Uses the project narrative profile instead of importing tone from a previous game.

## Level Designer

Owns playable layout, player start and end, reachable goals, interaction placement, collision boundaries, and readable navigation.

Also owns collision alignment:

- visible playable space should be walkable
- visible solid blockers should block movement
- required routes must remain reachable

Also owns scale consistency in layout:

- entrances, exits, props, architecture, and walkable gaps must make sense for the player size and project camera

## Technical Director

Owns architecture.

Keeps core systems separate from game data, visuals, and level-specific implementation.

Ensures project-specific rules are expressed through data, profiles, or config where possible.

## Gameplay Engineer

Owns scene setup, scripts, input, collision, signals/events, and project runtime health.

Uses the engine/toolchain defined by the active project profile.

## Systems Architect

Owns reusable system boundaries, data formats, replaceability, state flow, and future save/readiness concerns.

## UX Designer

Owns input clarity, UI density, dialogue/readability, target-platform assumptions, and test usability.

Must prevent debug UI or unclear affordances from becoming accidental final UX.

## Art Director

Owns visual quality.

Ensures the world matches the active project profile and selected visual direction.

Must inspect actual in-game screenshots before approving Visual Pass.

Blocks acceptance if:

- scene still looks like blockout
- selected direction is not visible
- player does not visually belong
- player scale does not match the environment
- character looks pasted over the background
- visual polish breaks gameplay readability

## QA Lead

Owns testing.

Confirms expected behavior through automated checks where possible and manual playtest instructions where needed.

Must separate:

- Logic QA
- Visual QA
- Collision QA
- Scale QA
- Feeling QA

Automated script PASS does not replace screenshot review, collision alignment, or manual playtest.

Scale QA is required whenever player art, camera zoom, background art, or world scale changes.

## Acceptance Manager

Owns Ready/NO decisions.

Does not allow fake acceptance.

Manual playtest remains the source of truth.

Must block Ready if:

- there is no current screenshot for visual work
- engine/tool output contains blocking project errors
- collision space does not match visible space
- Scale Consistency Gate has not passed after visual or player changes
- user confirmation is required but not yet provided

## Debug Engineer

Owns technical blockers, reproduction steps, isolation of failing behavior, and focused fixes.

Owns layer-order, import, resource, camera, node path, scene-loading, and runtime failures.

Must fix blockers before the task can be reported as ready.
