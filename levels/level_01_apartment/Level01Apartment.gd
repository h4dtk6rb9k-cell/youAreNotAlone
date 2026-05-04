extends Node2D

const SCREEN_ON_COLOR := Color(0.35, 0.78, 0.94, 1.0)
const SCREEN_OFF_COLOR := Color(0.035, 0.045, 0.055, 1.0)
const DOOR_LOCKED_COLOR := Color(0.18, 0.2, 0.22, 1.0)
const DOOR_READY_COLOR := Color(0.78, 0.66, 0.42, 1.0)
const LEVEL_ID := "level_01_apartment"
const LEVEL_DATA_PATH := "res://levels/level_01_apartment/level_01_data.json"
const DIALOGUES_PATH := "res://data/dialogues.json"

@onready var screen_visual: Polygon2D = $Room/Props/Screen/ScreenVisual
@onready var screen_glow: Polygon2D = $Room/Props/Screen/ScreenGlow
@onready var screen_feed_lines: Node2D = $Room/Props/Screen/FeedLines
@onready var door_visual: Polygon2D = $Room/Props/Door/DoorVisual
@onready var door_light: Polygon2D = $Room/Props/Door/DoorLight
@onready var silence_overlay: ColorRect = $SilenceOverlay
@onready var cold_overlay: ColorRect = $ColdOverlay
@onready var screen_off_patch: Polygon2D = $ScreenOffPatch
@onready var door_locked_patch: Polygon2D = $DoorLockedPatch
@onready var door_unlocked_glow: Polygon2D = $DoorUnlockedGlow
@onready var screen_area: Area2D = $Room/Interactions/ScreenArea
@onready var door_area: Area2D = $Room/Interactions/DoorArea
@onready var player: CharacterBody2D = $Player
@onready var navigation_layer: Node2D = $Navigation

var elapsed_time: float = 0.0
var silence_target_alpha: float = 0.0
var playable_polygon: PackedVector2Array = PackedVector2Array()
var forbidden_polygons: Array[PackedVector2Array] = []
var dialogue_lines: Dictionary = {}


func _ready() -> void:
	GameState.set_current_level(LEVEL_ID)
	AudioStateManager.set_atmosphere("apartment_screen_hum")
	_load_level_data()
	_load_dialogue_data()
	_bind_interaction(screen_area, "screen")
	_bind_interaction(door_area, "door")
	if player.has_method("set_playable_polygon"):
		player.set_playable_polygon(playable_polygon)
	if player.has_method("set_forbidden_polygons"):
		player.set_forbidden_polygons(forbidden_polygons)
	_update_room_state()


func _process(delta: float) -> void:
	elapsed_time += delta
	if not GameState.get_flag("screen_off", false):
		var pulse := 0.46 + sin(elapsed_time * 7.0) * 0.08 + sin(elapsed_time * 15.0) * 0.04
		screen_glow.modulate.a = clamp(pulse, 0.22, 0.62)
		screen_feed_lines.position.y = fmod(elapsed_time * 12.0, 18.0)
	else:
		screen_glow.modulate.a = lerp(screen_glow.modulate.a, 0.0, delta * 4.0)

	silence_overlay.color.a = lerp(silence_overlay.color.a, silence_target_alpha, delta * 1.8)
	cold_overlay.color.a = 0.14 + sin(elapsed_time * 0.28) * 0.012


func _bind_interaction(area: Area2D, interaction_id: String) -> void:
	area.set_meta("interaction_id", interaction_id)
	area.body_entered.connect(_on_interaction_body_entered.bind(area))
	area.body_exited.connect(_on_interaction_body_exited.bind(area))


func _on_interaction_body_entered(body: Node, area: Area2D) -> void:
	if not body.is_in_group("player"):
		return
	InteractionManager.set_focus(area)
	_show_focus_line(str(area.get_meta("interaction_id", "")))


func _on_interaction_body_exited(body: Node, area: Area2D) -> void:
	if not body.is_in_group("player"):
		return
	InteractionManager.clear_focus(area)


func handle_interaction(interaction_id: String, _actor: Node) -> void:
	match interaction_id:
		"screen":
			if GameState.get_flag("screen_off", false):
				DialogueManager.show_line(_dialogue("screen_already_off"))
				return
			DialogueManager.show_line(_dialogue("screen_after"))
			GameState.set_flag("screen_off", true)
			AudioStateManager.enter_silence()
			_update_room_state()
		"door":
			if not GameState.get_flag("screen_off", false):
				DialogueManager.show_line(_dialogue("door_locked"))
				return
			DialogueManager.show_line(_dialogue("door_ready"))
			SceneLoader.transition_to_message(_dialogue("transition"))


func _show_focus_line(interaction_id: String) -> void:
	match interaction_id:
		"screen":
			if not GameState.get_flag("screen_off", false):
				DialogueManager.show_line(_dialogue("screen_before"))
		"door":
			if GameState.get_flag("screen_off", false):
				DialogueManager.show_line(_dialogue("door_ready"))
			else:
				DialogueManager.show_line(_dialogue("door_locked"))


func _update_room_state() -> void:
	var screen_off := bool(GameState.get_flag("screen_off", false))
	screen_visual.color = SCREEN_OFF_COLOR if screen_off else SCREEN_ON_COLOR
	screen_feed_lines.visible = not screen_off
	door_visual.color = DOOR_READY_COLOR if screen_off else DOOR_LOCKED_COLOR
	door_light.visible = screen_off
	screen_off_patch.visible = screen_off
	door_locked_patch.visible = not screen_off
	door_unlocked_glow.visible = screen_off
	silence_target_alpha = 0.24 if screen_off else 0.0


func _load_level_data() -> void:
	var level_data := _load_json(LEVEL_DATA_PATH)
	_load_navigation_from_scene()
	if playable_polygon.is_empty():
		_load_navigation_from_data(level_data)

	var start: Dictionary = level_data.get("player_start", {})
	if start.has("x") and start.has("y"):
		player.global_position = Vector2(float(start["x"]), float(start["y"]))


func _load_navigation_from_scene() -> void:
	playable_polygon.clear()
	forbidden_polygons.clear()

	var walkable_floor := navigation_layer.get_node_or_null("WalkableFloor") as Polygon2D
	if walkable_floor != null:
		playable_polygon = _polygon_to_global(walkable_floor)

	var no_feet_zones := navigation_layer.get_node_or_null("NoFeetZones")
	if no_feet_zones == null:
		return
	for child in no_feet_zones.get_children():
		var forbidden_zone := child as Polygon2D
		if forbidden_zone == null:
			continue
		var polygon := _polygon_to_global(forbidden_zone)
		if polygon.size() >= 3:
			forbidden_polygons.append(polygon)


func _load_navigation_from_data(level_data: Dictionary) -> void:
	var navigation: Dictionary = level_data.get("navigation", {})
	playable_polygon = _array_to_polygon(navigation.get("playable_polygon", []))
	forbidden_polygons.clear()
	for polygon_data in navigation.get("forbidden_polygons", []):
		var polygon := _array_to_polygon(polygon_data)
		if polygon.size() >= 3:
			forbidden_polygons.append(polygon)


func _load_dialogue_data() -> void:
	var all_dialogues := _load_json(DIALOGUES_PATH)
	var levels: Dictionary = all_dialogues.get("dialogues", {})
	dialogue_lines = levels.get(LEVEL_ID, {})


func _dialogue(key: String) -> String:
	return str(dialogue_lines.get(key, key))


func _array_to_polygon(points: Array) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for point in points:
		if point is Array and point.size() >= 2:
			polygon.append(Vector2(float(point[0]), float(point[1])))
	return polygon


func _polygon_to_global(source: Polygon2D) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for point in source.polygon:
		polygon.append(source.to_global(point))
	return polygon


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing JSON file: %s" % path)
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON dictionary: %s" % path)
		return {}
	return parsed
