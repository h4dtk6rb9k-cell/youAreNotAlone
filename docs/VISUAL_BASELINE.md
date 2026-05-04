# Visual Baseline

This file defines generic visual acceptance rules.

Project-specific style is defined by:

- `docs/GAME_OVERVIEW.md`
- `docs/PROJECT_PROFILE.md` if present
- `docs/VISUAL_REFERENCE.md`
- project-specific files under `docs/project/`

## Mandatory Visual Standard

Every playable level must visually match the active project profile.

The team must confirm:

- the camera/view style matches the project profile
- the scene has intentional composition, not accidental placement
- lighting supports player focus and mood
- foreground, midground, and background are readable where relevant
- materials or surfaces are legible enough for the chosen art style
- important gameplay objects are readable without debug labels
- the player avatar visually belongs to the environment
- visual boundaries and gameplay boundaries agree

## Forbidden Final State

The following is not acceptable as a finished level unless the project profile explicitly defines it as the final art style:

- raw blockout geometry
- flat debug-colored shapes
- placeholder markers used as final characters
- unclear camera angle
- missing depth or grounding cues
- player floating in empty space
- beautiful art that breaks movement, collision, or interaction clarity

If the scene still reads as a prototype:

`Ready = NO`

## Screenshot Standard

Visual quality is judged from the actual playable scene, not from intent or isolated art files.

Before a visual stage can be accepted, the team must inspect a current screenshot or equivalent capture.

The screenshot must show:

- selected visual direction clearly present
- background and gameplay space visible
- camera/view style matching the project profile
- player readable and grounded
- required interactions readable
- exit/progression target readable
- walkable area understandable
- no layer-order problem hiding the scene

If no current screenshot was reviewed:

`Visual QA = FAIL`

## Player Visual Baseline

During Visual Pass, the player cannot be only a cursor, arrow, diamond, capsule, or abstract marker unless that is the approved final character language.

The player representation must have:

- readable identity or silhouette
- believable scale against the environment
- grounded feet, shadow, or equivalent contact cue
- enough contrast to be found without HUD
- style compatibility with the environment

If the player does not visually read as the intended playable character:

`Ready = NO`

## Scale Consistency

The player must feel correctly sized inside the environment.

Check the player against the level's scale anchors, such as:

- entrances and exits
- furniture or large props
- interaction objects
- architectural elements
- vehicles, machines, or natural landmarks
- small props that imply human scale
- room, street, arena, or terrain footprint

Scale is accepted only if:

- the player could plausibly use required interactable objects
- the player is neither toy-sized nor giant-sized relative to the intended world
- the player contact point is grounded correctly
- camera zoom does not detach the player from the art
- interaction distance feels physically plausible

If player scale feels wrong:

`Ready = NO`

## Player Technical Grounding

The player scene must define a clear gameplay contact point.

For 2D character games, the preferred implementation is:

- player origin = foot/contact anchor
- character visual bottom aligns to origin
- shadow/contact cue is centered on origin
- collision shape represents the gameplay footprint
- walkability is judged by the contact anchor

If the project uses another movement model, document the equivalent contact/grounding rule in `docs/PROJECT_PROFILE.md`.

## Collision / Visual Match

The visible scene defines player expectations.

The player must not:

- leave visible playable space
- pass through visible solid blockers
- stand on objects that visually should block movement
- stand with their foot/contact anchor on wall art, doors, windows, furniture tops, shelves, decorative planes, or any surface that does not read as floor
- be blocked by invisible walls that contradict the visual scene

The player must be able to:

- reach every required interaction
- reach the required exit or progression target
- navigate the main path without absurd invisible blockers

If visual space and collision space disagree:

`Ready = NO`
