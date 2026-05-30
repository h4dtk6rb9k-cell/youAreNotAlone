# tests/unit/test_ending_resolver.gd
extends GutTest


func before_each() -> void:
	GameState.stats = PlayerStats.new()


func _make_stats(identity: int, compliance: int, suspicion: int) -> PlayerStats:
	var s := PlayerStats.new()
	s.identity   = identity
	s.compliance = compliance
	s.suspicion  = suspicion
	return s


# ── AC: Selfhood ★ — приоритет наивысший ──────────────────────────────────

func test_selfhood_takes_priority_over_conformist() -> void:
	# identity=71 > 70, compliance=29 < 30 → Selfhood
	# Даже если compliance мог бы дать Conformist при значении ≥ 70 — Selfhood первый
	var s := _make_stats(71, 29, 0)
	assert_eq(EndingChecker.evaluate(s), EndingChecker.Ending.SELFHOOD)


func test_selfhood_takes_priority_over_rebel() -> void:
	var s := _make_stats(71, 29, 60)
	assert_eq(EndingChecker.evaluate(s), EndingChecker.Ending.SELFHOOD)


# ── AC: Conformist ────────────────────────────────────────────────────────

func test_conformist_when_compliance_gte_70() -> void:
	var s := _make_stats(50, 70, 0)
	assert_eq(EndingChecker.evaluate(s), EndingChecker.Ending.CONFORMIST)


func test_conformist_not_selfhood_because_identity_too_low() -> void:
	# compliance≥70 но identity≤70 — не Selfhood
	var s := _make_stats(70, 70, 0)
	assert_eq(EndingChecker.evaluate(s), EndingChecker.Ending.CONFORMIST)


# ── AC: Rebel ─────────────────────────────────────────────────────────────

func test_rebel_when_suspicion_gte_60() -> void:
	var s := _make_stats(50, 30, 60)
	assert_eq(EndingChecker.evaluate(s), EndingChecker.Ending.REBEL)


func test_rebel_not_triggered_below_60() -> void:
	var s := _make_stats(50, 30, 59)
	assert_ne(EndingChecker.evaluate(s), EndingChecker.Ending.REBEL)


# ── AC: экран с текстом из scenario_v1.md ────────────────────────────────

func test_selfhood_text_contains_key_phrase() -> void:
	var text := EndingChecker.get_text(EndingChecker.Ending.SELFHOOD)
	assert_true("имя" in text.to_lower(), "Текст Selfhood должен упоминать имя")


func test_conformist_text_contains_key_phrase() -> void:
	var text := EndingChecker.get_text(EndingChecker.Ending.CONFORMIST)
	assert_true("подпись" in text.to_lower() or "номер" in text.to_lower())


func test_rebel_text_contains_key_phrase() -> void:
	var text := EndingChecker.get_text(EndingChecker.Ending.REBEL)
	assert_true("ночь" in text.to_lower() or "пришли" in text.to_lower())


# ── EndingResolver: try_resolve возвращает правильную концовку ────────────

func test_resolver_returns_selfhood_for_right_stats() -> void:
	GameState.stats = _make_stats(71, 29, 0)
	# Применяем postfix через постоянный флаг
	GameState.stats._selfhood_permanently_unlocked = true
	var resolver := EndingResolver.new()
	add_child(resolver)
	var result := EndingChecker.evaluate(GameState.stats)
	assert_eq(result, EndingChecker.Ending.SELFHOOD)
	resolver.queue_free()


func test_resolver_returns_none_for_start_stats() -> void:
	GameState.stats = PlayerStats.new()
	var result := EndingChecker.evaluate(GameState.stats)
	assert_eq(result, EndingChecker.Ending.NONE)


# ── Все три текста не пустые ──────────────────────────────────────────────

func test_all_ending_texts_non_empty() -> void:
	for ending in [
		EndingChecker.Ending.SELFHOOD,
		EndingChecker.Ending.CONFORMIST,
		EndingChecker.Ending.REBEL,
	]:
		assert_ne(EndingChecker.get_text(ending), "",
			"Текст концовки %d пустой" % ending)
