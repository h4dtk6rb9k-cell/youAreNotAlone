# scenes/courtyard/courtyard_controller.gd
# Сцена: scenes/courtyard/courtyard.tscn
#
# Ожидаемые ноды:
#   %TileMapLayer  — TileMapLayer
#   %ObjectsLayer  — Node2D (y_sort)
#   %Player        — IsoCharacter
#   %IsoInput      — IsoInput
#   %VoiceLabel    — Label
#   %DialogueBox   — Control
#   %TerminalPanel — Control  (UI терминала, скрыт по умолч.)
extends Node2D

const _CourtyardData = preload("res://scenes/courtyard/courtyard_data.gd")

@onready var _player:   IsoCharacter = %Player
@onready var _input:    IsoInput     = %IsoInput
@onready var _voice:    Label        = %VoiceLabel
@onready var _dlg_box:  Control      = %DialogueBox
@onready var _terminal: Control      = %TerminalPanel

var _npc_spawns: Dictionary = {}
var _held_item_id: String   = ""
# Счётчик тапов по углу экрана терминала (для скрытого режима)
var _terminal_corner_taps: int = 0


func _ready() -> void:
	_place_npcs()
	_input.on_world_tap.connect(_on_world_tap)
	_input.on_object_tap.connect(_on_object_tap)
	# Синхронизируем held_item из инвентаря (взяли в Квартире)
	_sync_held_item()


func _place_npcs() -> void:
	for spawn in _CourtyardData.get_npc_spawns():
		_npc_spawns[spawn.tile_pos] = spawn


func _sync_held_item() -> void:
	# Если в инвентаре одна книга «без названия» — считаем её «в руке»
	if GameState.inventory.has_item(Item.ID_BOOK_UNNAMED):
		_held_item_id = Item.ID_BOOK_UNNAMED
	elif GameState.inventory.has_item(Item.ID_PHOTO):
		_held_item_id = Item.ID_PHOTO


# ── Тап ───────────────────────────────────────────────────────────────────

func _on_world_tap(world_pos: Vector2) -> void:
	var tile := IsoGrid.world_to_tile(world_pos)

	# Переход в Центр (разблокируется после терминала)
	if tile == _CourtyardData.EXIT_TO_CENTER_TILE:
		if GameState.get_flag(_CourtyardData.FLAG_CENTER_UNLOCKED):
			_go_to_center()
		return

	# Возврат в Квартиру
	if tile == _CourtyardData.EXIT_TO_APART_TILE:
		get_tree().change_scene_to_file(_CourtyardData.PREV_SCENE)
		return

	# Терминал
	if tile == _CourtyardData.TERMINAL_TILE:
		_open_terminal_official()
		return

	# NPC
	if _npc_spawns.has(tile):
		_start_dialogue(_npc_spawns[tile])
		return

	_player.move_to(world_pos)


func _on_object_tap(body: Node) -> void:
	if body.has_meta("dialogue_node_id"):
		var node_id: String = body.get_meta("dialogue_node_id")
		_open_dialogue_by_id(node_id)


# ── Терминал ──────────────────────────────────────────────────────────────

func _open_terminal_official() -> void:
	_open_dialogue_by_id("terminal_official")
	_unlock_center()


func open_terminal_hidden() -> void:
	# Вызывается из UI терминала при 3 тапах в угол
	if not DialogueRunner.can_access_hidden_terminal(
		GameState.stats,
		GameState.get_flag(_CourtyardData.FLAG_ACTIVIST_GAVE_HINT)
	):
		return
	_open_dialogue_by_id("terminal_hidden")


func on_terminal_corner_tap() -> void:
	_terminal_corner_taps += 1
	if _terminal_corner_taps >= 3:
		_terminal_corner_taps = 0
		open_terminal_hidden()


func _unlock_center() -> void:
	GameState.set_flag(_CourtyardData.FLAG_CENTER_UNLOCKED)
	GameState.set_flag(_CourtyardData.FLAG_TERMINAL_USED)


# ── Диалог ────────────────────────────────────────────────────────────────

func _start_dialogue(spawn: SceneNpcSpawn) -> void:
	_open_dialogue_by_id(spawn.dialogue_node_id)


func _open_dialogue_by_id(node_id: String) -> void:
	var node := AllDialogues.build().get(node_id) as DialogueNodeData
	if node == null:
		return
	DialogueRunner.apply_item_branch(node, _held_item_id, GameState.stats)
	DialogueRunner.apply_badge_silence(
		node,
		GameState.equipment.is_badge_equipped(),
		GameState.stats
	)
	var choices := DialogueRunner.get_choices_from_game_state(node)
	_dlg_box.show_node(node, choices)


# ── Переход ────────────────────────────────────────────────────────────────

func _go_to_center() -> void:
	GameState.set_current_level("profile_center")
	get_tree().change_scene_to_file(_CourtyardData.NEXT_SCENE)
