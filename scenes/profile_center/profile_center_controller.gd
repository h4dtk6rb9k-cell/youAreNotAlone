# scenes/profile_center/profile_center_controller.gd
# Сцена: scenes/profile_center/profile_center.tscn
#
# Ожидаемые ноды:
#   %TileMapLayer  — TileMapLayer (16×7)
#   %ObjectsLayer  — Node2D
#   %Player        — IsoCharacter
#   %IsoInput      — IsoInput
#   %VoiceLabel    — Label
#   %DialogueBox   — Control
#   %EndingScreen  — Control (EndingScreen, hidden until needed)
extends Node2D

const _ProfileCenterData = preload("res://scenes/profile_center/profile_center_data.gd")

@onready var _player:    IsoCharacter  = %Player
@onready var _input:     IsoInput      = %IsoInput
@onready var _voice:     Label         = %VoiceLabel
@onready var _dlg_box:   Control       = %DialogueBox
@onready var _ending_ui: Control       = %EndingScreen   # EndingScreen node

var _npc_spawns: Dictionary = {}
var _specialist_done: bool  = false


func _ready() -> void:
	_place_npcs()
	_input.on_world_tap.connect(_on_world_tap)
	_input.on_object_tap.connect(_on_object_tap)
	GameState.set_current_level(_ProfileCenterData.SCENE_ID)


func _place_npcs() -> void:
	for spawn in _ProfileCenterData.get_npc_spawns():
		_npc_spawns[spawn.tile_pos] = spawn


func _on_world_tap(world_pos: Vector2) -> void:
	var tile := IsoGrid.world_to_tile(world_pos)
	if _npc_spawns.has(tile):
		_start_specialist_dialogue(_npc_spawns[tile])
		return
	if not _specialist_done:
		_player.move_to(world_pos)


func _on_object_tap(body: Node) -> void:
	if body.has_meta("dialogue_node_id"):
		var node_id: String = body.get_meta("dialogue_node_id")
		_open_dialogue_by_id(node_id)


# ── Диалог специалиста ────────────────────────────────────────────────────

func _start_specialist_dialogue(spawn: SceneNpcSpawn) -> void:
	_open_dialogue_by_id(spawn.dialogue_node_id)


func _open_dialogue_by_id(node_id: String) -> void:
	var node := AllDialogues.build().get(node_id) as DialogueNodeData
	if node == null:
		return

	# Применяем item_branch (книга «без названия» в руке)
	DialogueRunner.apply_item_branch(node, GameState.held_item_id, GameState.stats)

	# Применяем badge-ветку (МВД → Suspicion не начисляется за молчание)
	var badge_equipped := GameState.equipment.is_badge_equipped()
	DialogueRunner.apply_badge_silence(node, badge_equipped, GameState.stats)

	var choices := DialogueRunner.get_choices_from_game_state(node)
	# DialogueBox сигнализирует когда выбор сделан
	_dlg_box.show_node(node, choices)

	# Подключаем обработчик финального выбора
	if not _dlg_box.choice_made.is_connected(_on_choice_made):
		_dlg_box.choice_made.connect(_on_choice_made)


func _on_choice_made(choice: DialogueChoice) -> void:
	DialogueRunner.apply_choice(choice, GameState.stats)

	# Если следующий узел существует — показываем его
	if choice.next_node_id != "" and not _specialist_done:
		_open_dialogue_by_id(choice.next_node_id)
		return

	# Диалог завершён → EndingResolver
	_on_specialist_dialogue_finished()


func _on_specialist_dialogue_finished() -> void:
	if _specialist_done:
		return
	_specialist_done = true
	GameState.set_flag(_ProfileCenterData.FLAG_SPECIALIST_DONE)
	_trigger_ending()


func _trigger_ending() -> void:
	var ending := EndingChecker.evaluate(GameState.stats)
	if ending == EndingChecker.Ending.NONE:
		# Нет условий — показываем Conformist как дефолт (игрок прошёл процедуру)
		ending = EndingChecker.Ending.CONFORMIST
	_ending_ui.show_ending(ending)
