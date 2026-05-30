# tests/integration/test_e2e_pilot_smoke.gd
# AcceptanceSmokeTest: три сквозных сценария пилота.
# Симулирует полный путь от старта до концовки без SceneTree.
# Каждый сценарий верифицирует финальные параметры и результат EndingChecker.
extends GutTest


# ── Хелперы ────────────────────────────────────────────────────────────────

func _reset_game_state() -> void:
	GameState.profile             = PlayerProfile.new()
	GameState.profile.first_name  = "Алексей"
	GameState.profile_number      = "777-010101-ENG-01"
	GameState.stats               = PlayerStats.new()
	GameState.inventory           = Inventory.new()
	GameState.inventory.bind_stats(GameState.stats)
	GameState.equipment           = EquipmentSlots.new()
	GameState.equipment.bind_stats(GameState.stats)
	GameState.held_item_id        = ""
	GameState.flags               = {}


func _pickup(item_id: String) -> void:
	var item := Item.make(item_id)
	GameState.inventory.add_item(item)   # применяет passive_bonus


func _choice(node_id: String, choice_id: String) -> void:
	var nodes := AllDialogues.build()
	var node  : DialogueNodeData = nodes.get(node_id)
	assert_not_null(node, "Узел не найден: " + node_id)
	for c in node.choices:
		if c.id == choice_id:
			DialogueRunner.apply_choice(c, GameState.stats)
			return
	fail_test("Выбор '%s' не найден в узле '%s'" % [choice_id, node_id])


# ════════════════════════════════════════════════════════════════════════════
# СЦЕНАРИЙ C — Conformist
# Путь: badge → Activist B → Terminal A → Specialist A
# Ожидается: C ≥ 70, Selfhood невозможен (I низкий)
# ════════════════════════════════════════════════════════════════════════════

func test_conformist_path_stats_and_ending() -> void:
	_reset_game_state()
	# Квартира: подобрать значок (passive_bonus=0)
	_pickup(Item.ID_BADGE)
	assert_eq(GameState.stats.identity,   50,  "Badge не меняет Identity при pickup")
	assert_eq(GameState.stats.compliance, 30)

	# Двор: Activist B → Compliance+15
	_choice("activist", "B")
	assert_eq(GameState.stats.identity,   50)
	assert_eq(GameState.stats.compliance, 45)

	# Двор: Terminal official A → I−10, C+20
	_choice("terminal_official", "A")
	assert_eq(GameState.stats.identity,   40)
	assert_eq(GameState.stats.compliance, 65)

	# Центр: Specialist A (назвать номер) → I−10, C+20
	_choice("specialist", "A")
	assert_eq(GameState.stats.identity,   30)
	assert_eq(GameState.stats.compliance, 85)
	assert_eq(GameState.stats.suspicion,   0)

	# Финальная проверка
	assert_false(GameState.stats.selfhood_unlocked(),
		"Selfhood не должен быть разблокирован (Identity=30)")
	var ending := EndingChecker.evaluate(GameState.stats)
	assert_eq(ending, EndingChecker.Ending.CONFORMIST,
		"Compliance=85 ≥ 70 → Conformist")
	assert_ne(EndingChecker.get_text(ending), "")


func test_conformist_path_no_softlock() -> void:
	_reset_game_state()
	_pickup(Item.ID_BADGE)
	_choice("activist", "B")
	_choice("terminal_official", "A")
	_choice("specialist", "A")
	# Нет флага, блокирующего переход — Центр должен быть достижим
	assert_true(GameState.stats.compliance >= PlayerStats.CONFORMIST_THRESHOLD)


# ════════════════════════════════════════════════════════════════════════════
# СЦЕНАРИЙ R — Rebel
# Путь: book → Neighbor A → Janitor A → Girl A → Activist C→C1 →
#        Terminal B → Specialist B→B1
# Ожидается: S ≥ 60, Selfhood НЕ разблокирован (C ≥ 30 на протяжении всего пути)
# ════════════════════════════════════════════════════════════════════════════

func test_rebel_path_stats_and_ending() -> void:
	_reset_game_state()
	# Квартира: подобрать книгу (Атлас) — passive Identity+5
	_pickup(Item.ID_BOOK_ATLAS)
	assert_eq(GameState.stats.identity, 55, "Atlas passive bonus +5")

	# Квартира → Двор: Neighbor A → Compliance+10
	_choice("neighbor", "A")
	assert_eq(GameState.stats.compliance, 40)

	# Двор: Janitor A → Compliance+5
	_choice("janitor", "A")
	assert_eq(GameState.stats.compliance, 45)

	# Двор: Girl A (соврать) → Identity−5, Compliance+5
	_choice("girl", "A")
	assert_eq(GameState.stats.identity,   50)
	assert_eq(GameState.stats.compliance, 50)

	# Двор: Activist C → Identity+10, Suspicion+8
	_choice("activist", "C")
	assert_eq(GameState.stats.identity,   60)
	assert_eq(GameState.stats.suspicion,   8)
	# Активист C → ветка C1
	_choice("activist_c", "C1")
	assert_eq(GameState.stats.identity,   75)
	assert_eq(GameState.stats.suspicion,  23)
	assert_eq(GameState.stats.compliance, 50,   "Compliance не изменился")
	assert_false(GameState.stats.selfhood_unlocked(),
		"Selfhood не разблокирован: C=50 ≥ 30")

	# Двор: Terminal official B (отмена) → Suspicion+5
	_choice("terminal_official", "B")
	assert_eq(GameState.stats.suspicion, 28)

	# Центр: Specialist B → Identity+25, Compliance−10, Suspicion+20
	_choice("specialist", "B")
	assert_eq(GameState.stats.identity,   100)  # clamped
	assert_eq(GameState.stats.compliance,  40)
	assert_eq(GameState.stats.suspicion,   48)
	assert_false(GameState.stats.selfhood_unlocked(),
		"Selfhood не разблокирован: C=40 ≥ 30")

	# Центр: Specialist B1 → Compliance+5, Suspicion+15
	_choice("specialist_b", "B1")
	assert_eq(GameState.stats.compliance, 45)
	assert_eq(GameState.stats.suspicion,  63)
	assert_false(GameState.stats.selfhood_unlocked(),
		"Selfhood не разблокирован на финале: C=45 ≥ 30")

	# Финальная проверка
	var ending := EndingChecker.evaluate(GameState.stats)
	assert_eq(ending, EndingChecker.Ending.REBEL,
		"Suspicion=63 ≥ 60 → Rebel (Selfhood=false, Conformist=false)")
	assert_ne(EndingChecker.get_text(ending), "")


func test_rebel_path_selfhood_never_triggered() -> void:
	_reset_game_state()
	_pickup(Item.ID_BOOK_ATLAS)
	_choice("neighbor", "A")
	_choice("janitor", "A")
	_choice("girl", "A")
	_choice("activist", "C")
	_choice("activist_c", "C1")
	_choice("terminal_official", "B")
	_choice("specialist", "B")
	_choice("specialist_b", "B1")
	assert_false(GameState.stats.selfhood_unlocked(),
		"На пути Rebel Selfhood не должен разблокироваться")


# ════════════════════════════════════════════════════════════════════════════
# СЦЕНАРИЙ S — Selfhood ★
# Путь: photo + book → Activist A → Specialist B
# Ожидается: Selfhood разблокируется внутри Specialist B (I>70, C<30)
# ════════════════════════════════════════════════════════════════════════════

func test_selfhood_path_stats_and_ending() -> void:
	_reset_game_state()
	# Квартира: фотография (passive +8) + книга (passive +5)
	_pickup(Item.ID_PHOTO)
	assert_eq(GameState.stats.identity, 58, "Photo passive bonus +8")
	_pickup(Item.ID_BOOK_ATLAS)
	assert_eq(GameState.stats.identity, 63, "Atlas passive bonus +5")
	assert_eq(GameState.stats.compliance, 30, "Compliance не тронут")

	# Двор: Activist A → Identity+20, Suspicion+5
	_choice("activist", "A")
	assert_eq(GameState.stats.identity,   83)
	assert_eq(GameState.stats.suspicion,   5)
	assert_eq(GameState.stats.compliance, 30)
	# I=83>70 но C=30 NOT <30 → Selfhood не разблокирован ещё
	assert_false(GameState.stats.selfhood_unlocked(),
		"C=30 (не <30) → Selfhood пока не разблокирован")

	# Центр: Specialist B → I+25 (→100), C−10=20, S+20
	# Внутри apply_delta: I=100>70, C=20<30 → Selfhood разблокируется!
	_choice("specialist", "B")
	assert_eq(GameState.stats.identity,   100)  # clamped
	assert_eq(GameState.stats.compliance,  20)
	assert_eq(GameState.stats.suspicion,   25)
	assert_true(GameState.stats.selfhood_unlocked(),
		"После Specialist B: I=100>70, C=20<30 → Selfhood разблокирован")

	# Финальная проверка — Selfhood приоритет над всеми
	var ending := EndingChecker.evaluate(GameState.stats)
	assert_eq(ending, EndingChecker.Ending.SELFHOOD,
		"Selfhood ★ должен быть финальной концовкой")
	assert_ne(EndingChecker.get_text(ending), "")
	assert_true("имя" in EndingChecker.get_text(ending).to_lower())


func test_selfhood_path_unlocked_permanently() -> void:
	_reset_game_state()
	_pickup(Item.ID_PHOTO)
	_pickup(Item.ID_BOOK_ATLAS)
	_choice("activist", "A")
	_choice("specialist", "B")
	assert_true(GameState.stats.selfhood_unlocked())
	# Даже если stats падают — Selfhood остаётся
	GameState.stats.apply_delta(-50, 50, 0)   # I=50, C=70 — условие нарушено
	assert_true(GameState.stats.selfhood_unlocked(),
		"Selfhood остаётся разблокированным навсегда")
	assert_eq(EndingChecker.evaluate(GameState.stats), EndingChecker.Ending.SELFHOOD)


# ════════════════════════════════════════════════════════════════════════════
# Приоритет концовок
# ════════════════════════════════════════════════════════════════════════════

func test_selfhood_beats_conformist_when_both_conditions_met() -> void:
	_reset_game_state()
	# Разблокируем Selfhood
	GameState.stats.apply_delta(21, -1, 0)   # I=71, C=29
	assert_true(GameState.stats.selfhood_unlocked())
	# Искусственно поднимаем Compliance ≥ 70 (но Selfhood уже locked)
	GameState.stats.compliance = 70
	var ending := EndingChecker.evaluate(GameState.stats)
	assert_eq(ending, EndingChecker.Ending.SELFHOOD,
		"Selfhood приоритетнее Conformist")


func test_conformist_beats_rebel_when_both_met() -> void:
	_reset_game_state()
	GameState.stats.compliance = 70
	GameState.stats.suspicion  = 60
	# Selfhood не разблокирован (I=50 ≤ 70)
	var ending := EndingChecker.evaluate(GameState.stats)
	assert_eq(ending, EndingChecker.Ending.CONFORMIST,
		"Conformist приоритетнее Rebel")


# ════════════════════════════════════════════════════════════════════════════
# Проверка что ни один сценарий не softlock-ится
# (Все переходы и диалоги доступны на своём пути)
# ════════════════════════════════════════════════════════════════════════════

func test_conformist_path_all_dialogue_nodes_reachable() -> void:
	_reset_game_state()
	var nodes := AllDialogues.build()
	assert_true(nodes.has("activist"),         "activist доступен")
	assert_true(nodes.has("terminal_official"),"terminal_official доступен")
	assert_true(nodes.has("specialist"),        "specialist доступен")


func test_rebel_path_terminal_accessible_after_activist_hint() -> void:
	_reset_game_state()
	# После ветки C1 активиста → скрытый терминал доступен
	GameState.set_flag(CourtyardData.FLAG_ACTIVIST_GAVE_HINT)
	var accessible := DialogueRunner.can_access_hidden_terminal(
		GameState.stats, true
	)
	assert_true(accessible, "Terminal hidden доступен с подсказкой активиста")


func test_all_three_endings_have_texts() -> void:
	for ending in [
		EndingChecker.Ending.SELFHOOD,
		EndingChecker.Ending.CONFORMIST,
		EndingChecker.Ending.REBEL,
	]:
		assert_ne(EndingChecker.get_text(ending), "",
			"Концовка %d должна иметь текст" % ending)
