extends Node

signal flag_changed(flag_name: String, value: Variant)
signal level_changed(level_id: String)

var current_level_id: String = "level_01_apartment"
var flags: Dictionary = {}
var visited_levels: Array[String] = []


func _ready() -> void:
	reset_for_new_game()


func reset_for_new_game() -> void:
	flags.clear()
	visited_levels.clear()
	current_level_id = "level_01_apartment"
	set_flag("screen_off", false)


func set_current_level(level_id: String) -> void:
	current_level_id = level_id
	if not visited_levels.has(level_id):
		visited_levels.append(level_id)
	level_changed.emit(level_id)


func set_flag(flag_name: String, value: Variant = true) -> void:
	flags[flag_name] = value
	flag_changed.emit(flag_name, value)


func get_flag(flag_name: String, default_value: Variant = false) -> Variant:
	return flags.get(flag_name, default_value)


func has_flag(flag_name: String) -> bool:
	return flags.has(flag_name)


func snapshot() -> Dictionary:
	return {
		"current_level_id": current_level_id,
		"flags": flags.duplicate(true),
		"visited_levels": visited_levels.duplicate()
	}


func restore(snapshot_data: Dictionary) -> void:
	current_level_id = snapshot_data.get("current_level_id", current_level_id)
	flags = snapshot_data.get("flags", {}).duplicate(true)
	visited_levels = snapshot_data.get("visited_levels", []).duplicate()
	level_changed.emit(current_level_id)
