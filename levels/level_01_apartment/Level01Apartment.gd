extends Node2D

const SCREEN_ON_COLOR := Color(0.35, 0.78, 0.94, 1.0)
const SCREEN_OFF_COLOR := Color(0.035, 0.045, 0.055, 1.0)
const DOOR_LOCKED_COLOR := Color(0.18, 0.2, 0.22, 1.0)
const DOOR_READY_COLOR := Color(0.78, 0.66, 0.42, 1.0)

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

var elapsed_time: float = 0.0
var silence_target_alpha: float = 0.0
var playable_polygon := PackedVector2Array([
	Vector2(204, 506),
	Vector2(362, 404),
	Vector2(644, 548),
	Vector2(656, 1002),
	Vector2(472, 1164),
	Vector2(188, 908),
	Vector2(178, 666)
])
var forbidden_polygons: Array[PackedVector2Array] = [
	PackedVector2Array([Vector2(102, 630), Vector2(260, 548), Vector2(392, 682), Vector2(224, 792)]),
	PackedVector2Array([Vector2(380, 650), Vector2(474, 598), Vector2(586, 704), Vector2(478, 778)]),
	PackedVector2Array([Vector2(458, 602), Vector2(548, 558), Vector2(646, 622), Vector2(548, 684)]),
	PackedVector2Array([Vector2(368, 394), Vector2(528, 452), Vector2(604, 542), Vector2(424, 534)]),
	PackedVector2Array([Vector2(156, 382), Vector2(368, 354), Vector2(386, 410), Vector2(164, 452)]),
	PackedVector2Array([Vector2(516, 826), Vector2(644, 760), Vector2(728, 854), Vector2(584, 950)]),
	PackedVector2Array([Vector2(330, 822), Vector2(452, 758), Vector2(546, 870), Vector2(408, 962)])
]


func _ready() -> void:
	GameState.set_current_level("level_01_apartment")
	AudioStateManager.set_atmosphere("apartment_screen_hum")
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
	if body.name != "Player":
		return
	InteractionManager.set_focus(area)
	_show_focus_line(str(area.get_meta("interaction_id", "")))


func _on_interaction_body_exited(body: Node, area: Area2D) -> void:
	if body.name != "Player":
		return
	InteractionManager.clear_focus(area)


func handle_interaction(interaction_id: String, _actor: Node) -> void:
	match interaction_id:
		"screen":
			if GameState.get_flag("screen_off", false):
				DialogueManager.show_line("стало тихо")
				return
			DialogueManager.show_line("стало тихо")
			GameState.set_flag("screen_off", true)
			AudioStateManager.enter_silence()
			_update_room_state()
		"door":
			if not GameState.get_flag("screen_off", false):
				DialogueManager.show_line("я ещё не готов выйти")
				return
			DialogueManager.show_line("выйти")
			SceneLoader.transition_to_message("Глава 1: Тихий сбой")


func _show_focus_line(interaction_id: String) -> void:
	match interaction_id:
		"screen":
			if not GameState.get_flag("screen_off", false):
				DialogueManager.show_line("лента движется сама по себе")
		"door":
			if GameState.get_flag("screen_off", false):
				DialogueManager.show_line("выйти")
			else:
				DialogueManager.show_line("я ещё не готов выйти")


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
