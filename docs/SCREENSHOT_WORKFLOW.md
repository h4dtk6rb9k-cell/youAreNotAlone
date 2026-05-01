# Screenshot Workflow

Screenshot Gate requires an actual rendered view of the playable scene.

## Manual Capture

1. Run the project in Godot with a normal graphics window.
2. Press `F12`.
3. The project saves:

`res://docs/reference/current_level_screenshot.png`

## Automatic Capture

Run the project graphically with:

```bash
Godot --path . --capture-screenshot
```

The game waits briefly, saves:

`res://docs/reference/current_level_screenshot.png`

Then exits.

## Important

Headless Godot does not satisfy Screenshot Gate because it can use a dummy renderer and may not produce the real game image.

The screenshot must be reviewed for:

- selected visual direction
- layer order
- camera framing
- readable player
- believable player scale
- readable door and screen
- visible playable area
- collision/visual plausibility
