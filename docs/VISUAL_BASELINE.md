## VISUAL TARGET (MANDATORY)

Every level must visually match the reference style:

- isometric 45-degree composition
- cinematic lighting
- warm interior lights vs cold ambient exterior
- soft shadows
- visible depth layers
- material definition (floor, walls, objects must feel real)
- no flat colors
- no abstract rectangles as final output

---

## FORBIDDEN VISUAL STATE

The following is NOT acceptable as final level:

- blockout geometry
- flat colored shapes
- debug-looking scene
- top-down feel
- lack of depth
- player floating in empty space

If scene looks like a prototype → Ready = NO

---

## ACCEPTANCE: VISUAL QUALITY

Level is accepted ONLY if:

- screenshot looks like concept art
- scene has mood (not just visibility)
- player fits the world visually
- lighting creates focus
- space feels real, not schematic

If not:
→ continue visual pass

## Mandatory Screenshot Standard

Visual quality is judged from the actual playable scene, not from files or intent.

Before a visual stage can be accepted, the team must inspect a current screenshot or equivalent capture.

The screenshot must show:

- selected visual direction clearly present
- background art visible and not hidden by a layer
- isometric / 45-degree composition
- warm light against cold ambient tone
- readable floor, walls, screen, door, and player
- player grounded in the scene
- visible walkable area

If the screenshot looks like a prototype:
→ Ready = NO

## Player Visual Baseline

During Visual Pass, the player cannot be a cursor, arrow, diamond, capsule, or abstract marker.

The player placeholder must have:

- readable human silhouette
- believable scale against furniture
- grounded feet or shadow
- enough contrast to be found without HUD
- visual style that can plausibly become final character art

If the player does not visually read as a person:
→ Ready = NO

## Scale Consistency

The player must feel like a human-sized person inside the environment.

Check the player against:

- door height and width
- bed length and pillow size
- sofa/chair height
- table height
- TV/screen size
- window height
- shelves and small props
- room footprint

Scale is accepted only if:

- the player could plausibly use the bed, chair, table, door, and screen
- the player is neither toy-sized nor giant-sized
- the player feet/shadow ground correctly on the floor
- the player sprite uses a foot-anchor: visual feet, shadow, and collision footprint align to the same origin
- camera zoom does not make the player feel detached from the art
- interaction distance feels physically plausible

If player scale feels wrong:
→ Ready = NO

## Player Technical Grounding

The player scene must treat its origin as the feet/ground contact point.

Required:

- `Player` origin = foot anchor.
- Character visual bottom aligns to origin.
- Shadow is centered on origin.
- Collision shape represents the floor footprint, not the whole drawn body.
- Level uses explicit walkable and forbidden foot-anchor zones.
- Furniture and wall collisions block the foot anchor before the visual body appears to stand on objects.

If the sprite is centered visually instead of foot-anchored:
→ Ready = NO

## Collision / Visual Match

The visible scene defines player expectations.

The player must not:

- leave the visible room/floor
- walk through bed
- walk through sofa
- walk through tables
- walk through TV console
- walk through shelves or major solid props

The player must be able to:

- reach the screen
- reach the door
- navigate the main path without absurd invisible blockers

If visual space and collision space disagree:
→ Ready = NO
