# tests/integration/test_dialogue_flow.gd
# Сквозные тесты: полный путь через диалоги → концовки
extends GutTest


func before_each() -> void:
	GameState.profile             = PlayerProfile.new()
	GameState.profile.first_name  = "Тест"
	GameState.profile_number      = "999-000000-TST-00"
	GameState.stats               = PlayerStats.new()


func _apply_choice_from_node(node_id: String, choice_id: String) -> void:
	var nodes  := AllDialogues.build()
	var node   : DialogueNodeData = nodes.get(node_id)
	assert_not_null(node, "Узел не найден: " + node_id)
	for c in node.choices:
		if c.id == choice_id:
			DialogueRunner.apply_choice(c, GameState.stats)
			return
	fail_test("Вариант %s не найден в узле %s" % [choice_id, node_id])


# ── Все 7 узлов существуют в реестре ─────────────────────────────────────

func test_all_seven_nodes_exist() -> void:
	var nodes := AllDialogues.build()
	for node_id in ["neighbor", "janitor", "activist", "girl",
	                "terminal_official", "terminal_hidden", "specialist"]:
		assert_true(nodes.has(node_id), "Отсутствует узел: " + node_id)


# ── Путь к Selfhood ★ ────────────────────────────────────────────────────

func test_selfhood_path_via_max_resistance_choices() -> void:
	# Путь: janitor B1 (+15) → activist A (+20) → activist_c C1 (+15)
	# → girl C (+10) + girl_c auto (+8) → specialist B (+25) → B1 (+15)
	# Итого identity: 50 + 15 + 20 + 15 + 10 + 8 + 25 + 15 = 158, clamped = 100 > 70 ✓
	# compliance: 30 + 0 = 30 — НЕ ниже 30, надо убедиться что compliance < 30
	# compliance: нет добавок в этом пути → 30, selfhood_unlocked = false
	# Нужен путь без compliance добавок
	GameState.stats = PlayerStats.new()
	_apply_choice_from_node("janitor",    "B")
	_apply_choice_from_node("janitor_b",  "B1")   # +15 identity
	_apply_choice_from_node("activist",   "A")    # +20 identity
	_apply_choice_from_node("girl",       "C")    # +10 identity
	_apply_choice_from_node("specialist", "B")    # +25 identity, -10 compliance
	_apply_choice_from_node("specialist_b", "B1") # +15 identity

	assert_gt(GameState.stats.identity,   70)
	assert_lt(GameState.stats.compliance, 30,
		"Compliance должен быть < 30 на пути Selfhood")
	assert_eq(EndingChecker.evaluate(GameState.stats), EndingChecker.Ending.SELFHOOD)


# ── Путь к Conformist ─────────────────────────────────────────────────────

func test_conformist_path_via_compliance_choices() -> void:
	GameState.stats = PlayerStats.new()
	_apply_choice_from_node("neighbor",         "A")  # +10 compliance
	_apply_choice_from_node("janitor",          "A")  # +5 compliance
	_apply_choice_from_node("activist",         "B")  # +15 compliance
	_apply_choice_from_node("terminal_official","A")  # +20 compliance, -10 identity
	_apply_choice_from_node("specialist",       "A")  # +20 compliance

	# 30 + 10 + 5 + 15 + 20 + 20 = 100 compliance
	assert_gte(GameState.stats.compliance, PlayerStats.CONFORMIST_THRESHOLD)
	assert_eq(EndingChecker.evaluate(GameState.stats), EndingChecker.Ending.CONFORMIST)


# ── Путь к Rebel ──────────────────────────────────────────────────────────

func test_rebel_path_via_high_suspicion() -> void:
	GameState.stats = PlayerStats.new()
	_apply_choice_from_node("neighbor",    "B")   # +5 suspicion
	_apply_choice_from_node("neighbor_b",  "B2")  # +10 suspicion
	_apply_choice_from_node("activist",    "C")   # +8 suspicion
	_apply_choice_from_node("activist_c",  "C1")  # +15 suspicion
	_apply_choice_from_node("specialist",  "B")   # +20 suspicion
	_apply_choice_from_node("specialist_b","B1")  # +15 suspicion

	# 0 + 5 + 10 + 8 + 15 + 20 + 15 = 73 suspicion ≥ 60 ✓
	assert_gte(GameState.stats.suspicion, PlayerStats.REBEL_THRESHOLD)
	assert_eq(EndingChecker.evaluate(GameState.stats), EndingChecker.Ending.REBEL)


# ── Дельты узлов совпадают со scenario_v1.md ────────────────────────────

func test_specialist_choice_b_gives_25_identity_minus_10_compliance() -> void:
	var nodes  := AllDialogues.build()
	var node   : DialogueNodeData = nodes["specialist"]
	var choice_b: DialogueChoice  = null
	for c in node.choices:
		if c.id == "B":
			choice_b = c
	assert_not_null(choice_b)
	assert_eq(choice_b.identity_delta,  25)
	assert_eq(choice_b.compliance_delta, -10)
	assert_eq(choice_b.suspicion_delta,  20)


func test_girl_choice_a_lie_gives_minus_5_identity() -> void:
	var nodes  := AllDialogues.build()
	var choice := nodes["girl"].choices[0]   # A — соврать
	assert_eq(choice.identity_delta, -5)


func test_terminal_hidden_x1_gives_plus_20_identity_minus_10_compliance() -> void:
	var nodes  := AllDialogues.build()
	var choice: DialogueChoice = null
	for c in nodes["terminal_hidden"].choices:
		if c.id == "X1":
			choice = c
	assert_not_null(choice)
	assert_eq(choice.identity_delta,   20)
	assert_eq(choice.compliance_delta, -10)
	assert_eq(choice.suspicion_delta,  20)
