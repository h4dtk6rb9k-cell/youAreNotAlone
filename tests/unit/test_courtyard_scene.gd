# tests/unit/test_courtyard_scene.gd
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
	GameState.flags               = {}


# ── Данные сцены ────────────────────────────────────────────────────────────

func test_tilemap_dimensions() -> void:
	assert_eq(CourtyardData.TILEMAP_WIDTH,  20)
	assert_eq(CourtyardData.TILEMAP_HEIGHT, 8)


func test_three_npcs_in_courtyard() -> void:
	assert_eq(CourtyardData.get_npc_spawns().size(), 3)


func test_janitor_npc_present() -> void:
	var npcs := CourtyardData.get_npc_spawns()
	var jan := npcs.filter(func(n): return n.npc_id == "janitor")
	assert_eq(jan.size(), 1)
	assert_eq(jan[0].dialogue_node_id, "janitor")


func test_activist_npc_present() -> void:
	var npcs := CourtyardData.get_npc_spawns()
	var act := npcs.filter(func(n): return n.npc_id == "activist")
	assert_eq(act.size(), 1)
	assert_eq(act[0].dialogue_node_id, "activist")


func test_girl_npc_present() -> void:
	var npcs := CourtyardData.get_npc_spawns()
	var girl := npcs.filter(func(n): return n.npc_id == "girl")
	assert_eq(girl.size(), 1)
	assert_eq(girl[0].dialogue_node_id, "girl")


func test_next_scene_is_profile_center() -> void:
	assert_true("profile_center" in CourtyardData.NEXT_SCENE)


func test_prev_scene_is_apartment() -> void:
	assert_true("apartment" in CourtyardData.PREV_SCENE)


# ── AC: значок надет → только вариант A у дворника ────────────────────────

func test_badge_blocks_janitor_b_and_c() -> void:
	GameState.equipment.equip(Item.make(Item.ID_BADGE))
	var node    := AllDialogues.build()["janitor"] as DialogueNodeData
	var choices := DialogueRunner.get_choices_from_game_state(node)
	var ids     := choices.map(func(c): return c.id)
	assert_false("B" in ids)
	assert_false("C" in ids)
	assert_true("A"  in ids)


func test_no_badge_shows_all_janitor_choices() -> void:
	var node    := AllDialogues.build()["janitor"] as DialogueNodeData
	var choices := DialogueRunner.get_choices_from_game_state(node)
	assert_eq(choices.size(), 3)


# ── AC: значок МВД → активист молчит, Suspicion −5 ──────────────────────

func test_mvd_badge_silences_activist() -> void:
	GameState.equipment.equip(Item.make(Item.ID_BADGE_MVD))
	var node    := AllDialogues.build()["activist"] as DialogueNodeData
	var choices := DialogueRunner.get_choices_from_game_state(node)
	assert_eq(choices.size(), 0)


func test_mvd_badge_activist_applies_suspicion_minus_5() -> void:
	GameState.equipment.equip(Item.make(Item.ID_BADGE_MVD))
	var node := AllDialogues.build()["activist"] as DialogueNodeData
	DialogueRunner.apply_badge_silence(node, true, GameState.stats)
	assert_eq(GameState.stats.suspicion, PlayerStats.SUSPICION_START - 5)


# ── AC: ветка C1 активиста → скрытый терминал доступен ───────────────────

func test_hidden_terminal_accessible_after_activist_hint() -> void:
	GameState.set_flag(CourtyardData.FLAG_ACTIVIST_GAVE_HINT)
	var accessible := DialogueRunner.can_access_hidden_terminal(
		GameState.stats,
		GameState.get_flag(CourtyardData.FLAG_ACTIVIST_GAVE_HINT)
	)
	assert_true(accessible)


func test_hidden_terminal_blocked_high_suspicion_no_hint() -> void:
	GameState.stats.suspicion = 30
	var accessible := DialogueRunner.can_access_hidden_terminal(
		GameState.stats, false
	)
	assert_false(accessible)


# ── AC: item_photo в руке → ветка девочки доступна ───────────────────────

func test_photo_triggers_girl_item_branch() -> void:
	var node  := AllDialogues.build()["girl"] as DialogueNodeData
	var triggered := DialogueRunner.apply_item_branch(node, Item.ID_PHOTO, GameState.stats)
	assert_true(triggered)
	assert_gt(GameState.stats.identity, PlayerStats.IDENTITY_START)


# ── AC: после любого тапа на терминал → переход в Центр разблокирован ─────

func test_terminal_use_sets_center_unlocked_flag() -> void:
	assert_false(GameState.get_flag(CourtyardData.FLAG_CENTER_UNLOCKED))
	GameState.set_flag(CourtyardData.FLAG_CENTER_UNLOCKED)
	assert_true(GameState.get_flag(CourtyardData.FLAG_CENTER_UNLOCKED))


func test_center_not_unlocked_before_terminal() -> void:
	assert_false(GameState.get_flag(CourtyardData.FLAG_CENTER_UNLOCKED))


# ── Диалоги: все три NPC с полными ветками ────────────────────────────────

func test_janitor_has_three_choices() -> void:
	var node := AllDialogues.build()["janitor"] as DialogueNodeData
	assert_eq(node.choices.size(), 3)


func test_activist_has_three_choices() -> void:
	var node := AllDialogues.build()["activist"] as DialogueNodeData
	assert_eq(node.choices.size(), 3)


func test_girl_has_three_choices() -> void:
	var node := AllDialogues.build()["girl"] as DialogueNodeData
	assert_eq(node.choices.size(), 3)


func test_terminal_official_has_two_choices() -> void:
	var node := AllDialogues.build()["terminal_official"] as DialogueNodeData
	assert_eq(node.choices.size(), 2)


func test_terminal_hidden_has_two_choices() -> void:
	var node := AllDialogues.build()["terminal_hidden"] as DialogueNodeData
	assert_eq(node.choices.size(), 2)
