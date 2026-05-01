extends Node

signal screenshot_saved(path: String)
signal screenshot_failed(reason: String)

const EDITOR_OUTPUT_PATH := "res://docs/reference/current_level_screenshot.png"
const RELEASE_OUTPUT_PATH := "user://current_level_screenshot.png"
const CAPTURE_ARG := "--capture-screenshot"

@export var auto_capture_delay_seconds: float = 1.0

var output_path: String = ""
var auto_capture_requested: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	output_path = _default_output_path()
	auto_capture_requested = OS.get_cmdline_args().has(CAPTURE_ARG)
	if auto_capture_requested:
		_capture_after_delay()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("take_screenshot"):
		save_current_viewport()
		get_viewport().set_input_as_handled()


func save_current_viewport(path: String = "") -> void:
	output_path = path if not path.is_empty() else _default_output_path()
	call_deferred("_save_after_frame")


func _capture_after_delay() -> void:
	await get_tree().create_timer(auto_capture_delay_seconds).timeout
	save_current_viewport(output_path)


func _save_after_frame() -> void:
	await RenderingServer.frame_post_draw
	var viewport := get_viewport()
	if viewport == null:
		_fail("No viewport available.")
		return

	var texture := viewport.get_texture()
	if texture == null:
		_fail("Viewport texture is unavailable. Run Godot with a real graphics window, not headless.")
		return

	var image := texture.get_image()
	if image == null or image.is_empty():
		_fail("Viewport image is empty. Run Godot with a real graphics window, not headless.")
		return

	var result := image.save_png(output_path)
	if result != OK:
		_fail("Could not save screenshot to %s." % output_path)
		return

	print("Screenshot saved: %s" % output_path)
	screenshot_saved.emit(output_path)

	if auto_capture_requested:
		get_tree().quit()


func _fail(reason: String) -> void:
	push_error(reason)
	screenshot_failed.emit(reason)
	if auto_capture_requested:
		get_tree().quit(1)


func _default_output_path() -> String:
	if OS.has_feature("editor"):
		return EDITOR_OUTPUT_PATH
	push_warning("ScreenshotManager is running outside editor; saving screenshots to user://.")
	return RELEASE_OUTPUT_PATH
