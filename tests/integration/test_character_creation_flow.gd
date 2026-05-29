# tests/integration/test_character_creation_flow.gd
# Headless SceneTree integration тест.
# Проверяет сквозной поток: заполнение формы → сохранение → GameState.
extends GutTest


func before_each() -> void:
	GameState.profile        = PlayerProfile.new()
	GameState.profile_number = ""
	if FileAccess.file_exists(SaveManager.SAVE_PATH):
		DirAccess.remove_absolute(SaveManager.SAVE_PATH)


func after_each() -> void:
	if FileAccess.file_exists(SaveManager.SAVE_PATH):
		DirAccess.remove_absolute(SaveManager.SAVE_PATH)


# ── AC: имя подставляется в диалоги через Localize() ──────────────────────

func test_name_appears_in_dialogue_after_sign() -> void:
	var profile        := PlayerProfile.new()
	profile.first_name  = "Алексей"
	profile.last_name   = "Смирнов"
	SaveManager.save_profile(profile)
	GameState.profile = SaveManager.load_profile()

	var result := Localization.localize("Товарищ [Имя], пройдите регистрацию.")
	assert_eq(result, "Товарищ Алексей, пройдите регистрацию.")


# ── AC: 8 вариантов профессии ──────────────────────────────────────────────

func test_profession_list_has_eight_options() -> void:
	assert_eq(PlayerProfile.PROFESSION_NAMES.size(), 8)


# ── AC: workplace фильтруется под профессию ────────────────────────────────

func test_transport_profession_excludes_retail_workplaces() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_TRANSPORT
	var allowed  := p.get_allowed_workplaces()
	assert_false(PlayerProfile.WORKPLACE_UNITY  in allowed,
		"Торговая точка не должна быть доступна транспортнику")
	assert_false(PlayerProfile.WORKPLACE_VECTOR in allowed)


func test_unemployed_profession_has_only_none_workplace() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_UNEMPLOYED
	var allowed  := p.get_allowed_workplaces()
	assert_eq(allowed, [PlayerProfile.WORKPLACE_NONE])


func test_law_profession_has_three_force_workplaces() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_LAW
	var allowed  := p.get_allowed_workplaces()
	assert_true(PlayerProfile.WORKPLACE_MVD  in allowed)
	assert_true(PlayerProfile.WORKPLACE_ARMY in allowed)
	assert_true(PlayerProfile.WORKPLACE_FSB  in allowed)


func test_medical_profession_includes_city_hospital() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_MEDICAL
	assert_true(PlayerProfile.WORKPLACE_CITY_HOSPITAL in p.get_allowed_workplaces())


func test_teacher_profession_includes_school() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_TEACHER
	assert_true(PlayerProfile.WORKPLACE_SCHOOL in p.get_allowed_workplaces())


func test_medical_and_teacher_are_not_cross_contaminated() -> void:
	var med_allowed := PlayerProfile.new()
	med_allowed.profession = PlayerProfile.PROFESSION_MEDICAL
	assert_false(PlayerProfile.WORKPLACE_SCHOOL in med_allowed.get_allowed_workplaces())

	var tea_allowed := PlayerProfile.new()
	tea_allowed.profession = PlayerProfile.PROFESSION_TEACHER
	assert_false(PlayerProfile.WORKPLACE_CITY_HOSPITAL in tea_allowed.get_allowed_workplaces())


# ── AC: ProfileValid → sign button logic (unit-level без SceneTree) ────────

func test_profile_invalid_with_empty_names() -> void:
	var p := PlayerProfile.new()
	assert_false(p.is_valid())


func test_profile_valid_with_both_names() -> void:
	var p          := PlayerProfile.new()
	p.first_name    = "Анна"
	p.last_name     = "Кузнецова"
	assert_true(p.is_valid())


# ── Генерация стартовых предметов (через ItemFactory) ─────────────────────

func test_law_officer_gets_mvd_badge() -> void:
	var p          := PlayerProfile.new()
	p.profession    = PlayerProfile.PROFESSION_LAW
	p.has_children  = false
	var items      := ItemFactory.generate_start_items(p)
	assert_true(ItemFactory.ITEM_BADGE_MVD in items)
	assert_false(ItemFactory.ITEM_BADGE    in items)


func test_guide_always_in_start_items() -> void:
	for prof in PlayerProfile.PROFESSION_NAMES.size():
		var p         := PlayerProfile.new()
		p.profession   = prof
		var items     := ItemFactory.generate_start_items(p)
		assert_true(ItemFactory.ITEM_GUIDE in items,
			"Профессия %d: item_guide должен быть в стартовых предметах" % prof)


# ── Сохранение и загрузка профиля ─────────────────────────────────────────

func test_saved_profile_survives_reload() -> void:
	var original       := PlayerProfile.new()
	original.first_name = "Екатерина"
	original.last_name  = "Орлова"
	original.profession = PlayerProfile.PROFESSION_MEDICAL
	original.workplace  = PlayerProfile.WORKPLACE_ARMY

	SaveManager.save_profile(original)
	var loaded := SaveManager.load_profile()

	assert_eq(loaded.first_name, "Екатерина")
	assert_eq(loaded.profession, PlayerProfile.PROFESSION_MEDICAL)
	assert_eq(loaded.workplace,  PlayerProfile.WORKPLACE_ARMY)
