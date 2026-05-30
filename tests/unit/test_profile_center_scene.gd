# tests/unit/test_profile_center_scene.gd
extends GutTest


func before_each() -> void:
	GameState.profile             = PlayerProfile.new()
	GameState.profile.first_name  = "Тест"
	GameState.profile_number      = "001-010101-ENG-07"
	GameState.stats               = PlayerStats.new()
	GameState.inventory           = Inventory.new()
	GameState.inventory.bind_stats(GameState.stats)
	GameState.equipment           = EquipmentSlots.new()
	GameState.equipment.bind_stats(GameState.stats)
	GameState.held_item_id        = ""
	GameState.flags               = {}


# ── Данные сцены ────────────────────────────────────────────────────────────

func test_tilemap_dimensions() -> void:
	assert_eq(ProfileCenterData.TILEMAP_WIDTH,  16)
	assert_eq(ProfileCenterData.TILEMAP_HEIGHT, 7)


func test_specialist_tile_position() -> void:
	assert_eq(ProfileCenterData.SPECIALIST_TILE, Vector2i(3, -1))


func test_one_npc_specialist() -> void:
	var npcs := ProfileCenterData.get_npc_spawns()
	assert_eq(npcs.size(), 1)
	assert_eq(npcs[0].npc_id, "specialist")
	assert_eq(npcs[0].facing_dir, "sw")


func test_no_prev_scene_door_locked() -> void:
	assert_eq(ProfileCenterData.PREV_SCENE, "")


# ── AC: specialist все ветки ────────────────────────────────────────────────

func test_specialist_has_three_main_choices() -> void:
	var node := AllDialogues.build()["specialist"] as DialogueNodeData
	assert_eq(node.choices.size(), 3)


func test_specialist_choice_b_gives_correct_deltas() -> void:
	var node := AllDialogues.build()["specialist"] as DialogueNodeData
	var choice_b: DialogueChoice = null
	for c in node.choices:
		if c.id == "B":
			choice_b = c
	assert_not_null(choice_b)
	assert_eq(choice_b.identity_delta,   25)
	assert_eq(choice_b.compliance_delta, -10)
	assert_eq(choice_b.suspicion_delta,  20)
	assert_eq(choice_b.next_node_id, "specialist_b")


func test_specialist_choice_a_gives_correct_deltas() -> void:
	var node := AllDialogues.build()["specialist"] as DialogueNodeData
	var choice_a: DialogueChoice = null
	for c in node.choices:
		if c.id == "A":
			choice_a = c
	assert_not_null(choice_a)
	assert_eq(choice_a.identity_delta,   -10)
	assert_eq(choice_a.compliance_delta, 20)


func test_specialist_choice_c_silent_gives_correct_deltas() -> void:
	var node := AllDialogues.build()["specialist"] as DialogueNodeData
	var choice_c: DialogueChoice = null
	for c in node.choices:
		if c.id == "C":
			choice_c = c
	assert_not_null(choice_c)
	assert_eq(choice_c.identity_delta,  10)
	assert_eq(choice_c.suspicion_delta, 15)


func test_specialist_b_has_two_sub_choices() -> void:
	var node := AllDialogues.build()["specialist_b"] as DialogueNodeData
	assert_eq(node.choices.size(), 2)


# ── AC: вариант B — «Меня зовут [Имя]» содержит имя из профиля ────────────

func test_specialist_choice_b_text_localized() -> void:
	var node := AllDialogues.build()["specialist"] as DialogueNodeData
	var choice_b: DialogueChoice = null
	for c in node.choices:
		if c.id == "B":
			choice_b = c
	var localized := DialogueRunner.format_text(choice_b.text)
	# Текст содержит [Имя] → должен быть заменён (пустой профиль или имя)
	assert_false("[Имя]" in localized, "Тег [Имя] должен быть заменён")


# ── AC: книга «без названия» в руке → ветка книги доступна ────────────────

func test_unnamed_book_triggers_specialist_item_branch() -> void:
	GameState.held_item_id = Item.ID_BOOK_UNNAMED
	var node      := AllDialogues.build()["specialist"] as DialogueNodeData
	var triggered := DialogueRunner.apply_item_branch(node, GameState.held_item_id, GameState.stats)
	assert_true(triggered)


func test_no_book_no_specialist_item_branch() -> void:
	var node      := AllDialogues.build()["specialist"] as DialogueNodeData
	var triggered := DialogueRunner.apply_item_branch(node, "", GameState.stats)
	assert_false(triggered)


# ── AC: МВД-значок → ветка лояльности, Suspicion не начисляется за молчание

func test_mvd_badge_opens_loyalty_branch_text() -> void:
	GameState.equipment.equip(Item.make(Item.ID_BADGE_MVD))
	var node := AllDialogues.build()["specialist"] as DialogueNodeData
	assert_ne(node.badge_branch_text, "")


func test_mvd_badge_no_silence_at_specialist() -> void:
	# Специалист НЕ silences_npc — МВД-значок только открывает ветку
	GameState.equipment.equip(Item.make(Item.ID_BADGE_MVD))
	var node    := AllDialogues.build()["specialist"] as DialogueNodeData
	var choices := DialogueRunner.get_choices_from_game_state(node)
	# Все варианты доступны (badge не блокирует specialist)
	assert_gt(choices.size(), 0)


# ── AC: EndingResolver срабатывает после диалога ──────────────────────────

func test_ending_checker_selfhood_after_high_identity_low_compliance() -> void:
	GameState.stats.apply_delta(21, -1, 0)   # I=71, C=29 → Selfhood unlocked
	var ending := EndingChecker.evaluate(GameState.stats)
	assert_eq(ending, EndingChecker.Ending.SELFHOOD)


func test_ending_checker_conformist_path() -> void:
	GameState.stats.apply_delta(0, 40, 0)   # C=70
	var ending := EndingChecker.evaluate(GameState.stats)
	assert_eq(ending, EndingChecker.Ending.CONFORMIST)


func test_ending_checker_rebel_path() -> void:
	GameState.stats.apply_delta(0, 0, 60)   # S=60
	var ending := EndingChecker.evaluate(GameState.stats)
	assert_eq(ending, EndingChecker.Ending.REBEL)
