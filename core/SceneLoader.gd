extends Node

signal transition_started(message: String)

const LEVELS_PATH := "res://data/levels.json"

var level_index: Dictionary = {}


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

	GameState.set_current_level(level_id)
	get_tree().change_scene_to_file(scene_path)


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
