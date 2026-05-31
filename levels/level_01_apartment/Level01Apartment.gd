extends Node2D
# US-16: Изометрический рендер квартиры (ADR-003).
# Пол, пропсы и предметы строятся процедурно из IsoGrid.
# Отклонения от HANDOFF (задокументированы для arch review):
#   - Пол: Sprite2D-сетка вместо TileMapLayer (TileSet требует GUI-редактора;
#     ADR-003 build_floor сам заполняет пол кодом).
#   - Пропсы: код вместо 5 .tscn (единообразно + закрывает отсутствующий Wardrobe).

const LEVEL_ID := "level_01_apartment"
const ART := "res://assets/art/generated/"

# Тайлмап 25×8, origin (-12,-4)
const FLOOR_ORIGIN := Vector2i(-12, -4)
const FLOOR_WIDTH := 25
const FLOOR_HEIGHT := 8

const PLAYER_START_TILE := Vector2i(-2, -2)
const DOOR_TILE := Vector2i(10, -1)

# [имя png, тайл, размер px (w,h)]
const PROPS := [
	["prop_bed",      Vector2i(-8, 0),  Vector2i(96, 64)],
	["prop_wardrobe", Vector2i(-4, 1),  Vector2i(80, 64)],
	["prop_desk",     Vector2i(3, 0),   Vector2i(80, 56)],
	["prop_plant",    Vector2i(6, 2),   Vector2i(48, 80)],
	["prop_door",     Vector2i(10, -1), Vector2i(48, 80)],
]

# [item_id, png, тайл]
const ITEMS := [
	["item_photo", "item_photo", Vector2i(-2, 2)],
	["item_book",  "item_book",  Vector2i(2, 2)],
	["item_badge", "item_badge", Vector2i(0, 2)],
]

@onready var floor_layer: Node2D = $FloorLayer
@onready var props_layer: Node2D = $Props
@onready var items_layer: Node2D = $Items
@onready var player: CharacterBody2D = $Player

var _picked_items: Dictionary = {}


func _ready() -> void:
	if DisplayServer.is_touchscreen_available():
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	GameState.set_current_level(LEVEL_ID)
	_build_floor()
	_build_props()
	_build_items()
	_place_player()
	_set_walkable_polygon()


# ── Пол: паркет A/B по (tx+ty)%2 ───────────────────────────────────────────

func _build_floor() -> void:
	for tx in range(FLOOR_ORIGIN.x, FLOOR_ORIGIN.x + FLOOR_WIDTH):
		for ty in range(FLOOR_ORIGIN.y, FLOOR_ORIGIN.y + FLOOR_HEIGHT):
			var variant := "tile_floor_a" if (tx + ty) % 2 == 0 else "tile_floor_b"
			var tex := _load_tex(variant)
			if tex == null:
				continue
			var spr := Sprite2D.new()
			spr.texture = tex
			spr.position = IsoGrid.tile_to_world(tx, ty)
			spr.scale = Vector2(1.02, 1.02)  # микро-overlap против субпиксельных швов
			spr.z_index = -100
			floor_layer.add_child(spr)


# ── Пропсы: спрайт + коллизия, pivot bottom-center, z = sort_order ─────────

func _build_props() -> void:
	for entry in PROPS:
		var png: String = entry[0]
		var tile: Vector2i = entry[1]
		var sz: Vector2i = entry[2]
		var tex := _load_tex(png)
		if tex == null:
			print("US-16: missing texture ", png)
			continue
		var body := StaticBody2D.new()
		body.position = IsoGrid.tile_to_world(tile.x, tile.y)
		body.z_index = IsoGrid.sort_order(tile.x, tile.y)

		var spr := Sprite2D.new()
		spr.texture = tex
		spr.scale = Vector2(1.4, 1.4)          # крупнее относительно пола
		spr.modulate = Color(1.25, 1.25, 1.25) # ярче (DALL-E пропсы темноваты)
		# pivot bottom-center: смещаем вверх на половину высоты (с учётом scale)
		spr.offset = Vector2(0, -float(sz.y) * 0.5)
		body.add_child(spr)

		var col := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(float(sz.x) * 0.6, float(sz.y) * 0.35)
		col.shape = shape
		col.position = Vector2(0, -float(sz.y) * 0.2)
		body.add_child(col)

		props_layer.add_child(body)


# ── Предметы на полу ───────────────────────────────────────────────────────

func _build_items() -> void:
	for entry in ITEMS:
		var item_id: String = entry[0]
		var png: String = entry[1]
		var tile: Vector2i = entry[2]
		var tex := _load_tex(png)
		if tex == null:
			continue
		var spr := Sprite2D.new()
		spr.texture = tex
		spr.position = IsoGrid.tile_to_world(tile.x, tile.y)
		spr.z_index = IsoGrid.sort_order(tile.x, tile.y) + 1
		spr.set_meta("item_id", item_id)
		spr.set_meta("tile", tile)
		items_layer.add_child(spr)


# ── Игрок ──────────────────────────────────────────────────────────────────

func _place_player() -> void:
	player.global_position = IsoGrid.tile_to_world(
		PLAYER_START_TILE.x, PLAYER_START_TILE.y
	)


func _set_walkable_polygon() -> void:
	# Диамант пола в world-координатах (4 угла тайлмапа)
	var o := FLOOR_ORIGIN
	var corners := [
		IsoGrid.tile_to_world(o.x, o.y),
		IsoGrid.tile_to_world(o.x + FLOOR_WIDTH - 1, o.y),
		IsoGrid.tile_to_world(o.x + FLOOR_WIDTH - 1, o.y + FLOOR_HEIGHT - 1),
		IsoGrid.tile_to_world(o.x, o.y + FLOOR_HEIGHT - 1),
	]
	var poly := PackedVector2Array(corners)
	if player.has_method("set_playable_polygon"):
		player.set_playable_polygon(poly)
	if player.has_method("set_forbidden_polygons"):
		player.set_forbidden_polygons([] as Array[PackedVector2Array])


# ── Подбор предмета / дверь: проверяем дистанцию игрока каждый кадр ─────────

func _process(_delta: float) -> void:
	var p_tile := IsoGrid.world_to_tile(player.global_position)

	# Дверь
	if p_tile == DOOR_TILE and GameState.get_flag("screen_off", true):
		_go_to_courtyard()
		return

	# Предметы
	for spr in items_layer.get_children():
		if not spr is Sprite2D:
			continue
		var item_id: String = spr.get_meta("item_id", "")
		if _picked_items.has(item_id):
			continue
		var tile: Vector2i = spr.get_meta("tile", Vector2i.ZERO)
		if p_tile == tile:
			_pickup(item_id, spr)


func _pickup(item_id: String, node: Sprite2D) -> void:
	_picked_items[item_id] = true
	node.visible = false
	if GameState.inventory != null:
		GameState.inventory.add_item(Item.make(item_id))


func _go_to_courtyard() -> void:
	set_process(false)
	SceneLoader.transition_to_message("Дверь. За ней — двор.")


func _load_tex(png_name: String) -> Texture2D:
	var path := "%s%s.png" % [ART, png_name]
	if ResourceLoader.exists(path):
		return load(path)
	return null
