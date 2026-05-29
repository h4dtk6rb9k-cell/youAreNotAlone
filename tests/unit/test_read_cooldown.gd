# tests/unit/test_read_cooldown.gd
extends GutTest


func before_each() -> void:
	GameState.stats = PlayerStats.new()


func test_can_read_at_game_start() -> void:
	var rc := ReadCooldown.new()
	assert_true(rc.can_read())


func test_cannot_read_immediately_after_reading() -> void:
	var rc := ReadCooldown.new()
	rc.on_read(GameState.stats.identity)
	assert_false(rc.can_read())


func test_can_read_after_quest_completed() -> void:
	var rc := ReadCooldown.new()
	rc.on_read(GameState.stats.identity)
	rc.on_quest_completed()
	assert_true(rc.can_read())


func test_can_read_after_combat() -> void:
	var rc := ReadCooldown.new()
	rc.on_read(GameState.stats.identity)
	rc.on_combat_occurred()
	assert_true(rc.can_read())


func test_can_read_after_identity_grows_15() -> void:
	var rc := ReadCooldown.new()
	rc.on_read(GameState.stats.identity)
	GameState.stats.identity += ReadCooldown.IDENTITY_DELTA_REQUIRED
	assert_true(rc.can_read())


func test_cannot_read_after_identity_grows_only_14() -> void:
	var rc := ReadCooldown.new()
	rc.on_read(GameState.stats.identity)
	GameState.stats.identity += ReadCooldown.IDENTITY_DELTA_REQUIRED - 1
	assert_false(rc.can_read())


func test_flags_reset_after_second_read() -> void:
	var rc := ReadCooldown.new()
	rc.on_read(0)
	rc.on_quest_completed()
	rc.on_read(0)          # второе чтение сбрасывает флаги
	assert_false(rc.can_read())
