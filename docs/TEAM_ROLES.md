# Team Roles

## Game Director

Owns meaning and coherence. Protects the central emotional promise: living attention is rare and precious.

## Creative Director

Owns the overall creative shape across tone, visuals, pacing, and player feeling.

## Producer

Owns scope. Keeps each task small enough to finish and verifies that the team does not move into polish before the foundation works.

## Narrative Designer

Owns emotional arc, dialogue restraint, environmental storytelling, and the order of narrative beats.

## Level Designer

Owns playable layout, player start and end, reachable goals, interaction placement, collision boundaries, and readable navigation.

Also owns collision alignment: visible floors must be walkable, visible solid furniture must block movement, and required routes must remain reachable.

Also owns scale consistency in layout: doors, beds, tables, sofas, and walkable gaps must make sense for the player size.

## Technical Director

Owns architecture. Keeps core systems separate from game data, visuals, and level-specific implementation.

## Godot 4 Engineer

Owns scene setup, GDScript implementation, input, collision, signals, and Godot project health.

## Systems Architect

Owns reusable system boundaries, data formats, replaceability, state flow, and future save readiness.

## UX Designer

Owns input clarity, minimal UI, dialogue readability, mobile-first assumptions, and desktop test usability.

## Art Director

Owns visual quality. Ensures the world is clean, believable, isometric in language, emotionally coherent, and never beautiful but unplayable.

Must inspect actual in-game screenshots before approving Visual Pass. Blocks acceptance if the scene still looks like blockout, if the selected direction is not visible, or if the player does not visually belong.

Also blocks acceptance if the player scale does not match the environment or if the character looks pasted over the background.

## QA Lead

Owns testing. Confirms expected behavior through automated checks where possible and manual playtest instructions where needed.

Must separate Logic QA, Visual QA, Collision QA, and Feeling QA. Automated script PASS does not replace screenshot review or collision alignment checks.

Must include Scale QA whenever player art, camera zoom, background art, or room scale changes.

## Acceptance Manager

Owns Ready/NO decisions. Does not allow fake acceptance. Manual playtest remains the source of truth.

Must block Ready if there is no current screenshot for visual work, if Godot reports project errors, or if collision space does not match the visible scene.

Must block Ready if Scale Consistency Gate has not passed after visual or player changes.

## Debug Engineer

Owns technical blockers, reproduction steps, isolation of failing behavior, and focused fixes.

Owns layer-order, import, resource, camera, node path, and scene-loading failures. Must fix these before the task can be reported as ready.
