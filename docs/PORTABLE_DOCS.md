# Portable Docs Guide

The root `docs/` folder is intended to be reusable across projects.

## Portable Layer

These files should stay generic:

- `AUTO_LEVEL_PRODUCTION.md`
- `PIPELINE.md`
- `ACCEPTANCE_PROTOCOL.md`
- `VISUAL_BASELINE.md`
- `VISUAL_REFERENCE.md`
- `SCREENSHOT_WORKFLOW.md`
- `TEAM_ROLES.md`
- `LEVEL_TEMPLATE.md`
- `TASK_TEMPLATE.md`
- `PROJECT_PROFILE_TEMPLATE.md`

They must not contain:

- a specific game title
- specific level names
- specific props such as a required screen, door, bed, or sofa
- a mandatory camera style unless the project profile defines it
- a mandatory emotional theme unless the project profile defines it
- paths to project-only reference images except as examples

## Project Layer

Project-specific material belongs in:

`docs/project/`

Examples:

- game overview for the current game
- selected visual direction for a specific level
- reference images for the current game
- level-specific visual notes

## Copying To A New Project

1. Copy the portable root docs.
2. Replace `GAME_OVERVIEW.md`.
3. Create `PROJECT_PROFILE.md` from `PROJECT_PROFILE_TEMPLATE.md`.
4. Add new visual references under the new project's preferred reference folder.
5. Remove or replace anything under `docs/project/`.
6. Run a portability scan for old project names, level names, prop names, and reference paths.

## Portability Scan

Before using these docs in another project, search for:

- old game title
- old level names
- old character names
- old prop names
- old visual reference paths
- engine-specific commands if the engine changed

If any are found in portable docs, move them to `docs/project/` or replace them with profile-driven language.
