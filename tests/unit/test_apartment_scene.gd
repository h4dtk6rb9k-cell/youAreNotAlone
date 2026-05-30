# tests/unit/test_apartment_scene.gd
extends GutTest


func before_each() -> void:
	GameState.profile             = PlayerProfile.new()
	GameState.profile.first_name  = "Тест"
	GameState.profile_number      = "000-000000-TST-00"
	GameState.stats               = PlayerStats.new()
	GameState.inventory           = Inventory.new()
	GameState.inventory.bind_stats(GameState.stats)
	GameState.equipment           = EquipmentSlots.new()
	GameState.equipment.bind_stats(GameState.stats)


# ── AC: позиции по спецификации GDD ──────────────────────────────────────

func test_player_start_tile() -> void:
	assert_eq(ApartmentData.PLAYER_START, Vector2i(-2, -2))


func test_tilemap_dimensions() -> void:
	assert_eq(ApartmentData.TILEMAP_WIDTH,  25)
	assert_eq(ApartmentData.TILEMAP_HEIGHT, 8)
	assert_eq(ApartmentData.TILEMAP_ORIGIN, Vector2i(-12, -4))


func test_door_tile_position() -> void:
	assert_eq(ApartmentData.DOOR_TILE, Vector2i(10, -1))


func test_neighbor_npc_at_correct_tile() -> void:
	var npcs := ApartmentData.get_npc_spawns()
	var neighbor := npcs.filter(func(n): return n.npc_id == "neighbor")
	assert_eq(neighbor.size(), 1)
	assert_eq(neighbor[0].tile_pos, Vector2i(7, -1))
	assert_eq(neighbor[0].facing_dir, "sw")
	assert_eq(neighbor[0].dialogue_node_id, "neighbor")


func test_three_items_in_apartment() -> void:
	assert_eq(ApartmentData.get_item_spawns().size(), 3)


func test_photo_at_correct_tile() -> void:
	var spawns := ApartmentData.get_item_spawns()
	var photo := spawns.filter(func(s): return s.item_id == Item.ID_PHOTO)
	assert_eq(photo.size(), 1)
	assert_eq(photo[0].tile_pos, Vector2i(-2, 2))


func test_badge_at_correct_tile() -> void:
	var spawns := ApartmentData.get_item_spawns()
	var badge := spawns.filter(func(s): return s.item_id == Item.ID_BADGE)
	assert_eq(badge.size(), 1)
	assert_eq(badge[0].tile_pos, Vector2i(0, 2))


func test_book_at_correct_tile() -> void:
	var spawns := ApartmentData.get_item_spawns()
	var book := spawns.filter(func(s): return s.item_id == Item.ID_BOOK_ATLAS)
	assert_eq(book.size(), 1)
	assert_eq(book[0].tile_pos, Vector2i(2, 2))


func test_all_item_spawns_have_voice_text() -> void:
	for spawn in ApartmentData.get_item_spawns():
		assert_ne(spawn.voice_text, "",
			"Предмет %s должен иметь текст голоса" % spawn.item_id)


# ── AC: предмет подбирается → попадает в инвентарь ────────────────────────

func test_pickup_adds_item_to_inventory() -> void:
	var spawn := ApartmentData.get_item_spawns()[0]   # photo
	var item  := Item.make(spawn.item_id)
	GameState.inventory.add_item(item)
	assert_true(GameState.inventory.has_item(spawn.item_id))


# ── AC: item_photo в руке → ветка соседки доступна ────────────────────────

func test_photo_triggers_neighbor_item_branch() -> void:
	var nodes := AllDialogues.build()
	var node  : DialogueNodeData = nodes["neighbor"]
	var stats  := PlayerStats.new()
	var triggered := DialogueRunner.apply_item_branch(node, Item.ID_PHOTO, stats)
	assert_true(triggered)
	assert_eq(stats.identity, PlayerStats.IDENTITY_START + 5)


func test_badge_does_not_trigger_neighbor_item_branch() -> void:
	var nodes := AllDialogues.build()
	var node  : DialogueNodeData = nodes["neighbor"]
	var stats  := PlayerStats.new()
	var triggered := DialogueRunner.apply_item_branch(node, Item.ID_BADGE, stats)
	assert_false(triggered)


# ── AC: диалог neighbor содержит все ветки сценария ───────────────────────

func test_neighbor_has_three_main_choices() -> void:
	var node := AllDialogues.build()["neighbor"] as DialogueNodeData
	assert_eq(node.choices.size(), 3)


func test_neighbor_choice_b_leads_to_neighbor_b() -> void:
	var node := AllDialogues.build()["neighbor"] as DialogueNodeData
	var choice_b: DialogueChoice = null
	for c in node.choices:
		if c.id == "B":
			choice_b = c
	assert_not_null(choice_b)
	assert_eq(choice_b.next_node_id, "neighbor_b")


func test_neighbor_b_has_two_choices() -> void:
	var node := AllDialogues.build()["neighbor_b"] as DialogueNodeData
	assert_eq(node.choices.size(), 2)


# ── AC: переход через дверь → NEXT_SCENE задан ────────────────────────────

func test_next_scene_is_courtyard() -> void:
	assert_ne(ApartmentData.NEXT_SCENE, "")
	assert_true("courtyard" in ApartmentData.NEXT_SCENE)
