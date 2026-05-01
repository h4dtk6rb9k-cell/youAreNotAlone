extends Node

signal transition_started(message: String)

const LEVELS_PATH := "res://data/levels.json"

var level_index: Dictionary = {}
var fade_layer: CanvasLayer = null
var fade_rect: ColorRect = null


func _ready() -> void:
	level_index = _load_json(LEVELS_PATH)


func transition_to_message(message: String) -> void:
	transition_started.emit(message)
	DialogueManager.show_line(message)


func change_level(level_id: String) -> void:
	if level_index.is_empty():
		level_index = _load_json(LEVELS_PATH)

	var levels: Dictionary = level_index.get("levels", {})
	if not levels.has(level_id):
		push_error("Unknown level id: %s" % level_id)
		return

	var scene_path: String = levels[level_id].get("scene", "")
	if scene_path.is_empty():
		push_error("Level has no scene path: %s" % level_id)
		return

	await fade_out()
	GameState.set_current_level(level_id)
	var result := get_tree().change_scene_to_file(scene_path)
	if result != OK:
		push_error("Could not change scene to: %s" % scene_path)
		await fade_in()
		return
	await get_tree().process_frame
	await fade_in()


func fade_out(duration: float = 0.35) -> void:
	await _fade_to(1.0, duration)


func fade_in(duration: float = 0.35) -> void:
	await _fade_to(0.0, duration)


func _fade_to(target_alpha: float, duration: float) -> void:
	_ensure_fade_layer()
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", target_alpha, duration)
	await tween.finished


func _ensure_fade_layer() -> void:
	if fade_layer != null and is_instance_valid(fade_layer):
		return
	fade_layer = CanvasLayer.new()
	fade_layer.layer = 100
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_layer.add_child(fade_rect)
	add_child(fade_layer)


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("Missing JSON file: %s" % path)
		return {}

	var text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Invalid JSON dictionary: %s" % path)
		return {}

	return parsed
