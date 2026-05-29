# tests/unit/test_dialogue_runner.gd
extends GutTest


func before_each() -> void:
	GameState.profile              = PlayerProfile.new()
	GameState.profile.first_name   = "Алексей"
	GameState.profile_number       = "001-123456-INZ-07"
	GameState.stats                = PlayerStats.new()


func _get_node(node_id: String) -> DialogueNodeData:
	return AllDialogues.build().get(node_id)


# ── AC: дельты применяются корректно ──────────────────────────────────────

func test_neighbor_choice_a_adds_compliance_10() -> void:
	var node   := _get_node("neighbor")
	var choice := node.choices[0]   # A
	assert_eq(choice.compliance_delta, 10)
	assert_eq(choice.identity_delta,   0)
	assert_eq(choice.suspicion_delta,  0)


func test_neighbor_choice_b_adds_identity_10_suspicion_5() -> void:
	var node   := _get_node("neighbor")
	var choice := node.choices[1]   # B
	assert_eq(choice.identity_delta,  10)
	assert_eq(choice.suspicion_delta,  5)


func test_apply_choice_modifies_stats() -> void:
	var stats  := PlayerStats.new()
	var choice := DialogueChoice.make("test", "", 15, -5, 10)
	DialogueRunner.apply_choice(choice, stats)
	assert_eq(stats.identity,   65)
	assert_eq(stats.compliance, 25)
	assert_eq(stats.suspicion,  10)


# ── AC: ветка предмета в руке ─────────────────────────────────────────────

func test_item_branch_triggers_when_held_item_matches() -> void:
	var node  := _get_node("neighbor")
	var stats := PlayerStats.new()
	var triggered := DialogueRunner.apply_item_branch(node, "item_photo", stats)
	assert_true(triggered)
	assert_eq(stats.identity, PlayerStats.IDENTITY_START + 5)


func test_item_branch_does_not_trigger_for_wrong_item() -> void:
	var node    := _get_node("neighbor")
	var stats   := PlayerStats.new()
	var triggered := DialogueRunner.apply_item_branch(node, "item_badge", stats)
	assert_false(triggered)
	assert_eq(stats.identity, PlayerStats.IDENTITY_START)


func test_item_branch_does_not_trigger_when_no_item_held() -> void:
	var node    := _get_node("neighbor")
	var stats   := PlayerStats.new()
	var triggered := DialogueRunner.apply_item_branch(node, "", stats)
	assert_false(triggered)


# ── AC: значок МВД блокирует ветки сопротивления ─────────────────────────

func test_janitor_badge_blocks_choices_b_and_c() -> void:
	var node    := _get_node("janitor")
	var choices := DialogueRunner.get_choices(node, true, false)
	var ids     := choices.map(func(c): return c.id)
	assert_false("B" in ids)
	assert_false("C" in ids)
	assert_true("A"  in ids)


func test_janitor_without_badge_shows_all_choices() -> void:
	var node    := _get_node("janitor")
	var choices := DialogueRunner.get_choices(node, false, false)
	assert_eq(choices.size(), 3)


func test_activist_badge_silences_npc() -> void:
	var node    := _get_node("activist")
	var choices := DialogueRunner.get_choices(node, true, true)
	assert_eq(choices.size(), 0)


func test_activist_without_badge_shows_choices() -> void:
	var node    := _get_node("activist")
	var choices := DialogueRunner.get_choices(node, false, false)
	assert_eq(choices.size(), 3)


func test_activist_badge_applies_suspicion_minus_5() -> void:
	var node  := _get_node("activist")
	var stats := PlayerStats.new()
	DialogueRunner.apply_badge_silence(node, true, stats)
	assert_eq(stats.suspicion, PlayerStats.SUSPICION_START - 5)


# ── AC: ReadCooldown → «Мысли ещё не улеглись.» ──────────────────────────

func test_cannot_read_guide_immediately_after_reading() -> void:
	var rc := ReadCooldown.new()
	rc.on_read(GameState.stats.identity)
	assert_false(rc.can_read())


# ── Терминал: доступ к скрытому каналу ───────────────────────────────────

func test_hidden_terminal_accessible_when_low_suspicion() -> void:
	var stats := PlayerStats.new()
	stats.suspicion = 29
	assert_true(DialogueRunner.can_access_hidden_terminal(stats, false))


func test_hidden_terminal_blocked_when_high_suspicion_no_hint() -> void:
	var stats := PlayerStats.new()
	stats.suspicion = 30
	assert_false(DialogueRunner.can_access_hidden_terminal(stats, false))


func test_hidden_terminal_accessible_with_activist_hint_regardless_of_suspicion() -> void:
	var stats := PlayerStats.new()
	stats.suspicion = 99
	assert_true(DialogueRunner.can_access_hidden_terminal(stats, true))


# ── [Имя] подставляется через localize() ─────────────────────────────────

func test_specialist_opening_contains_localized_name_after_choice_b() -> void:
	var node    := _get_node("specialist_b")
	var raw     := node.choices[0].text   # «[Номер]. Но имя — [Имя].»
	var result  := DialogueRunner.format_text(raw)
	assert_true("Алексей" in result, "Имя должно подставиться: " + result)
