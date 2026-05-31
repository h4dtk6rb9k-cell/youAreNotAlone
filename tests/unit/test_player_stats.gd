# tests/unit/test_player_stats.gd
extends GutTest


func test_initial_values_match_scenario() -> void:
	var s := PlayerStats.new()
	assert_eq(s.identity,   50)
	assert_eq(s.compliance, 30)
	assert_eq(s.suspicion,  0)


func test_apply_delta_positive() -> void:
	var s := PlayerStats.new()
	s.apply_delta(10, 5, 3)
	assert_eq(s.identity,   60)
	assert_eq(s.compliance, 35)
	assert_eq(s.suspicion,  3)


func test_apply_delta_negative() -> void:
	var s := PlayerStats.new()
	s.apply_delta(-10, -5, 0)
	assert_eq(s.identity,   40)
	assert_eq(s.compliance, 25)


func test_identity_clamped_at_zero() -> void:
	var s := PlayerStats.new()
	s.apply_delta(-999, 0, 0)
	assert_eq(s.identity, 0)


func test_compliance_clamped_at_100() -> void:
	var s := PlayerStats.new()
	s.apply_delta(0, 999, 0)
	assert_eq(s.compliance, 100)


func test_suspicion_clamped_at_zero() -> void:
	var s := PlayerStats.new()
	s.apply_delta(0, 0, -999)
	assert_eq(s.suspicion, 0)


func test_identity_clamped_at_100() -> void:
	var s := PlayerStats.new()
	s.apply_delta(999, 0, 0)
	assert_eq(s.identity, 100)


func test_selfhood_not_unlocked_at_start() -> void:
	var s := PlayerStats.new()
	assert_false(s.selfhood_unlocked())


func test_selfhood_unlocked_when_identity_above_70_and_compliance_below_30() -> void:
	var s := PlayerStats.new()
	s.apply_delta(21, -1, 0)
	assert_true(s.selfhood_unlocked())


func test_selfhood_stays_unlocked_even_if_stats_reverse() -> void:
	var s := PlayerStats.new()
	s.apply_delta(21, -1, 0)
	s.apply_delta(-30, 50, 0)
	assert_true(s.selfhood_unlocked())


func test_selfhood_not_unlocked_when_compliance_exactly_30() -> void:
	var s := PlayerStats.new()
	s.apply_delta(21, 0, 0)
	assert_false(s.selfhood_unlocked())


func test_selfhood_not_unlocked_when_identity_exactly_70() -> void:
	var s := PlayerStats.new()
	s.apply_delta(20, -1, 0)
	assert_false(s.selfhood_unlocked())


func test_changed_signal_emitted_on_apply_delta() -> void:
	var s := PlayerStats.new()
	watch_signals(s)
	s.apply_delta(5, 0, 0)
	assert_signal_emitted(s, "stats_changed")


func test_selfhood_just_unlocked_signal_emitted_once() -> void:
	var s := PlayerStats.new()
	watch_signals(s)
	s.apply_delta(21, -1, 0)
	assert_signal_emitted(s, "selfhood_just_unlocked")
	var count := get_signal_emit_count(s, "selfhood_just_unlocked")
	s.apply_delta(1, 0, 0)
	assert_eq(get_signal_emit_count(s, "selfhood_just_unlocked"), count)


func test_reset_restores_initial_values() -> void:
	var s := PlayerStats.new()
	s.apply_delta(20, 20, 20)
	s.reset()
	assert_eq(s.identity,   50)
	assert_eq(s.compliance, 30)
	assert_eq(s.suspicion,  0)


func test_reset_clears_selfhood_unlock() -> void:
	var s := PlayerStats.new()
	s.apply_delta(21, -1, 0)
	s.reset()
	assert_false(s.selfhood_unlocked())
