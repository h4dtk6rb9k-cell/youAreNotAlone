# Screenshot Workflow

Screenshot Gate requires an actual rendered view of the playable scene.

Use the capture method supported by the active project.

Document the active project's screenshot shortcut, command, and output path in `docs/PROJECT_PROFILE.md` or the task brief.

## Manual Capture

1. Run the project with a normal graphics window.
2. Use the project's screenshot shortcut or capture tool.
3. Save the image in the agreed review location.

## Automatic Capture

If the project supports automatic graphical capture, document the exact command in the active project profile.

Headless or dummy-renderer captures do not satisfy Screenshot Gate unless the project explicitly proves they render the real playable image.

For projects that provide a capture script, the team may use it as Screenshot Gate input only if it runs with a real graphics renderer and produces the agreed output file.

## Review Checklist

The screenshot must be reviewed for:

- selected visual direction
- layer order
- camera framing
- readable player
- believable player scale
- readable required interactions
- readable exit or progression target
- visible playable area
- collision/visual plausibility

If the screenshot exposes a visual, scale, collision, or framing bug:

`Ready for user playtest: NO`
