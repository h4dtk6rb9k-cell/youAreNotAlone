# tests/unit/test_ending_checker.gd
extends GutTest


func _make_stats(identity: int, compliance: int, suspicion: int) -> PlayerStats:
	var s := PlayerStats.new()
	s.identity   = identity
	s.compliance = compliance
	s.suspicion  = suspicion
	return s


# ── Selfhood ★ — приоритет наивысший ──────────────────────────────────────

func test_selfhood_when_identity_above_70_and_compliance_below_30() -> void:
	var s := _make_stats(71, 29, 0)
	assert_eq(EndingChecker.evaluate(s), EndingChecker.Ending.SELFHOOD)


func test_selfhood_beats_conformist() -> void:
	var s := _make_stats(71, 29, 0)   # оба порога выполнены — Selfhood приоритет
	# compliance=29 < 30, compliance<CONFORMIST(70) → только Selfhood применимо
	assert_eq(EndingChecker.evaluate(s), EndingChecker.Ending.SELFHOOD)


func test_selfhood_beats_rebel() -> void:
	# Теоретический кейс: identity>70, compliance<30, suspicion≥60
	var s := _make_stats(71, 29, 60)
	assert_eq(EndingChecker.evaluate(s), EndingChecker.Ending.SELFHOOD)


# ── Conformist ─────────────────────────────────────────────────────────────

func test_conformist_when_compliance_gte_70() -> void:
	var s := _make_stats(50, 70, 0)
	assert_eq(EndingChecker.evaluate(s), EndingChecker.Ending.CONFORMIST)


func test_conformist_not_triggered_below_70() -> void:
	var s := _make_stats(50, 69, 0)
	assert_ne(EndingChecker.evaluate(s), EndingChecker.Ending.CONFORMIST)


# ── Rebel ──────────────────────────────────────────────────────────────────

func test_rebel_when_suspicion_gte_60() -> void:
	var s := _make_stats(50, 30, 60)
	assert_eq(EndingChecker.evaluate(s), EndingChecker.Ending.REBEL)


func test_rebel_not_triggered_below_60() -> void:
	var s := _make_stats(50, 30, 59)
	assert_ne(EndingChecker.evaluate(s), EndingChecker.Ending.REBEL)


# ── NONE ───────────────────────────────────────────────────────────────────

func test_none_at_start_stats() -> void:
	var s := PlayerStats.new()
	assert_eq(EndingChecker.evaluate(s), EndingChecker.Ending.NONE)


# ── Тексты концовок не пустые ──────────────────────────────────────────────

func test_selfhood_text_not_empty() -> void:
	assert_ne(EndingChecker.get_text(EndingChecker.Ending.SELFHOOD), "")


func test_conformist_text_not_empty() -> void:
	assert_ne(EndingChecker.get_text(EndingChecker.Ending.CONFORMIST), "")


func test_rebel_text_not_empty() -> void:
	assert_ne(EndingChecker.get_text(EndingChecker.Ending.REBEL), "")
