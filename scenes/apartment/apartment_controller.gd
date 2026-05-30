# scenes/apartment/apartment_controller.gd
# Подключается к корневой ноде сцены Квартиры.
# Сцена: scenes/apartment/apartment.tscn
#
# Ожидаемые ноды:
#   %TileMapLayer      — TileMapLayer (64×32, Diamond, y_sort)
#   %ObjectsLayer      — Node2D (y_sort_enabled=true)
#   %Player            — IsoCharacter
#   %IsoInput          — IsoInput
#   %VoiceLabel        — Label (внутренний голос, auto-hide через таймер)
#   %DialogueBox       — Control (DialogueBox UI)
extends Node2D

signal scene_exit_requested(next_scene: String)

const _ApartmentData = preload("res://scenes/apartment/apartment_data.gd")

@onready var _tilemap:    TileMapLayer = %TileMapLayer
@onready var _objects:    Node2D       = %ObjectsLayer
@onready var _player:     IsoCharacter = %Player
@onready var _iso_input:  IsoInput     = %IsoInput
@onready var _voice:      Label        = %VoiceLabel
@onready var _dlg_box:    Control      = %DialogueBox

# Словарь tile_pos → item_id (предметы ещё не подобраны)
var _item_spawns: Dictionary = {}
# Словарь tile_pos → dialogue_node_id
var _npc_spawns:  Dictionary = {}

var _held_item_id: String = ""   # предмет «в руке»
var _voice_timer:  SceneTreeTimer = null


func _ready() -> void:
	_place_items()
	_place_npcs()
	_place_player()
	_iso_input.on_world_tap.connect(_on_world_tap)
	_iso_input.on_object_tap.connect(_on_object_tap)
	_show_intro_voice()


# ── Инициализация ──────────────────────────────────────────────────────────

func _place_items() -> void:
	for spawn in _ApartmentData.get_item_spawns():
		_item_spawns[spawn.tile_pos] = spawn


func _place_npcs() -> void:
	for spawn in _ApartmentData.get_npc_spawns():
		_npc_spawns[spawn.tile_pos] = spawn


func _place_player() -> void:
	_player.global_position = IsoGrid.tile_to_world(
		_ApartmentData.PLAYER_START.x,
		_ApartmentData.PLAYER_START.y
	)


func _show_intro_voice() -> void:
	_voice.text    = _ApartmentData.INTRO_VOICE_1
	_voice.visible = true
	await get_tree().create_timer(4.0).timeout
	_voice.text = _ApartmentData.INTRO_VOICE_2
	await get_tree().create_timer(3.0).timeout
	_voice.visible = false


# ── Тап по миру (движение / подбор / взаимодействие) ─────────────────────

func _on_world_tap(world_pos: Vector2) -> void:
	var tile := IsoGrid.world_to_tile(world_pos)

	# Дверь → переход в Двор
	if tile == _ApartmentData.DOOR_TILE:
		_exit_to_courtyard()
		return

	# NPC
	if _npc_spawns.has(tile):
		_start_dialogue(_npc_spawns[tile])
		return

	# Предмет
	if _item_spawns.has(tile):
		_pickup_item(_item_spawns[tile])
		return

	# Движение
	_player.move_to(world_pos)


func _on_object_tap(body: Node) -> void:
	# Прямой тап по физическому телу (NPC, предмет-коллайдер)
	if body.has_meta("dialogue_node_id"):
		var dialogue_node_id: String = body.get_meta("dialogue_node_id")
		var node := AllDialogues.build().get(dialogue_node_id) as DialogueNodeData
		if node:
			_open_dialogue_node(node)
	elif body.has_meta("item_id"):
		var tile := IsoGrid.world_to_tile(body.global_position)
		if _item_spawns.has(tile):
			_pickup_item(_item_spawns[tile])


# ── Подбор предмета ────────────────────────────────────────────────────────

func _pickup_item(spawn: SceneItemSpawn) -> void:
	var item := Item.make(spawn.item_id)
	GameState.inventory.add_item(item)
	_item_spawns.erase(spawn.tile_pos)
	# Предмет «в руке» для диалоговых веток
	_held_item_id = spawn.item_id
	if spawn.voice_text != "":
		_show_voice(spawn.voice_text)


func _show_voice(text: String) -> void:
	_voice.text    = Localization.localize(text)
	_voice.visible = true
	if _voice_timer != null and not _voice_timer.is_stopped():
		pass   # перезапустим по окончанию
	_voice_timer = get_tree().create_timer(3.5)
	_voice_timer.timeout.connect(func(): _voice.visible = false)


# ── Диалог ─────────────────────────────────────────────────────────────────

func _start_dialogue(spawn: SceneNpcSpawn) -> void:
	var node := AllDialogues.build().get(spawn.dialogue_node_id) as DialogueNodeData
	if node:
		_open_dialogue_node(node)


func _open_dialogue_node(node: DialogueNodeData) -> void:
	# Применяем item_branch если предмет «в руке» совпадает
	DialogueRunner.apply_item_branch(node, _held_item_id, GameState.stats)
	# Применяем badge_silence если нужно
	DialogueRunner.apply_badge_silence(
		node,
		GameState.equipment.is_badge_equipped(),
		GameState.stats
	)
	# Передаём в DialogueBox (UI подключается отдельно)
	var choices := DialogueRunner.get_choices_from_game_state(node)
	_dlg_box.show_node(node, choices)


# ── Переход ────────────────────────────────────────────────────────────────

func _exit_to_courtyard() -> void:
	GameState.set_current_level("courtyard")
	get_tree().change_scene_to_file(_ApartmentData.NEXT_SCENE)
