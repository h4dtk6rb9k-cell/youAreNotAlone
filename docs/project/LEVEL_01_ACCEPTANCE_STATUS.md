# Level 01 Acceptance Status

Current status is honest, not optimistic.

## Automated QA

Status: PASS required before user playtest.

Automated QA must cover:

- scene loads without project errors
- player starts in valid walkable space
- player remains inside `WalkableFloor`
- player is pushed out of every `NoFeetZones` polygon
- dense no-feet sampling passes
- non-floor patrol samples around walls, window, and door pass
- screen and door interactions work

Automated QA does not accept the final visual quality by itself.

## Collision QA

Status: IN PROGRESS until user retest confirms no new reachable wall, door, window, or furniture-top standing points.

Latest internal change:

- `WalkableFloor` was tightened so the upper wall/window/door area is no longer broadly treated as floor.
- required route samples now must remain valid foot positions, not merely unblocked physics points.

Known class of bug:

- player foot anchor can appear on visual non-floor surfaces if `WalkableFloor` or `NoFeetZones` do not match the rendered scene

Required response:

- add or adjust editable navigation zones
- add a QA patrol sample or dense coverage rule for the discovered class
- rerun automated QA
- request user playtest confirmation

## Visual QA

Status: FAIL for finished-level acceptance.

Reason:

- current scene is readable and playable, but still differs significantly from the selected visual direction
- selected direction requires a richer apartment with believable architecture, warm window focus, coherent door/corridor logic, stronger material detail, and less blockout-like geometry
- current scene remains too flat and symbolic compared with the approved reference target

Latest internal change:

- added stronger warm window glow, wall depth shading, additional floor boards, warmer floor reflections, door-frame depth, and window sill/frame accents
- added wall baseboards, wall/floor contact shadows, a door threshold, and extra bed/sofa surface detail
- visual direction is closer than before, but still not accepted as finished

This does not block technical playtest, but it blocks `Ready as finished level: YES`.

## Current Readiness

- Ready for user playtest: YES only after current automated QA passes and a fresh screenshot is reviewed.
- Ready as finished level: NO until Visual QA and user manual playtest pass.
