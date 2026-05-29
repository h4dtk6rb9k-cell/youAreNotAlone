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


func test_selfhood_unlocked_when_identity_above_70_and_compliance_below_30() -> void:
	var s := PlayerStats.new()
	s.identity   = 71
	s.compliance = 29
	assert_true(s.selfhood_unlocked())


func test_selfhood_not_unlocked_when_compliance_too_high() -> void:
	var s := PlayerStats.new()
	s.identity   = 71
	s.compliance = 30
	assert_false(s.selfhood_unlocked())


func test_selfhood_not_unlocked_when_identity_too_low() -> void:
	var s := PlayerStats.new()
	s.identity   = 70
	s.compliance = 29
	assert_false(s.selfhood_unlocked())


func test_reset_restores_initial_values() -> void:
	var s := PlayerStats.new()
	s.apply_delta(20, 20, 20)
	s.reset()
	assert_eq(s.identity,   50)
	assert_eq(s.compliance, 30)
	assert_eq(s.suspicion,  0)
