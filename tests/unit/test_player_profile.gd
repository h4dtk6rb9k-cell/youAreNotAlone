# tests/unit/test_player_profile.gd
extends GutTest


func test_is_valid_returns_false_when_both_names_empty() -> void:
	var p := PlayerProfile.new()
	assert_false(p.is_valid())


func test_is_valid_returns_false_when_only_first_name_filled() -> void:
	var p := PlayerProfile.new()
	p.first_name = "Иван"
	assert_false(p.is_valid())


func test_is_valid_returns_false_when_only_last_name_filled() -> void:
	var p := PlayerProfile.new()
	p.last_name = "Петров"
	assert_false(p.is_valid())


func test_is_valid_returns_true_when_both_names_filled() -> void:
	var p := PlayerProfile.new()
	p.first_name = "Иван"
	p.last_name  = "Петров"
	assert_true(p.is_valid())


func test_is_valid_trims_whitespace() -> void:
	var p := PlayerProfile.new()
	p.first_name = "   "
	p.last_name  = "Петров"
	assert_false(p.is_valid())


func test_profession_count_is_eight() -> void:
	assert_eq(PlayerProfile.PROFESSION_NAMES.size(), 8)


func test_get_allowed_workplaces_engineer_contains_rzd() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_ENGINEER
	assert_true(PlayerProfile.WORKPLACE_RZD in p.get_allowed_workplaces())


func test_get_allowed_workplaces_law_contains_mvd_army_fsb() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_LAW
	var allowed := p.get_allowed_workplaces()
	assert_true(PlayerProfile.WORKPLACE_MVD  in allowed)
	assert_true(PlayerProfile.WORKPLACE_ARMY in allowed)
	assert_true(PlayerProfile.WORKPLACE_FSB  in allowed)


func test_get_allowed_workplaces_unemployed_only_none() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_UNEMPLOYED
	var allowed := p.get_allowed_workplaces()
	assert_eq(allowed.size(), 1)
	assert_eq(allowed[0], PlayerProfile.WORKPLACE_NONE)


func test_get_allowed_workplaces_retail_not_in_transport() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_TRANSPORT
	var allowed := p.get_allowed_workplaces()
	assert_false(PlayerProfile.WORKPLACE_UNITY  in allowed)
	assert_false(PlayerProfile.WORKPLACE_VECTOR in allowed)


func test_every_profession_has_at_least_one_workplace() -> void:
	for prof_idx in PlayerProfile.PROFESSION_NAMES.size():
		var p := PlayerProfile.new()
		p.profession = prof_idx
		assert_gt(p.get_allowed_workplaces().size(), 0,
			"Профессия %d не имеет рабочих мест" % prof_idx)


func test_medical_contains_city_hospital() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_MEDICAL
	assert_true(PlayerProfile.WORKPLACE_CITY_HOSPITAL in p.get_allowed_workplaces())


func test_medical_contains_army() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_MEDICAL
	assert_true(PlayerProfile.WORKPLACE_ARMY in p.get_allowed_workplaces())


func test_medical_allows_unemployed() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_MEDICAL
	assert_true(PlayerProfile.WORKPLACE_NONE in p.get_allowed_workplaces())


func test_teacher_contains_school() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_TEACHER
	assert_true(PlayerProfile.WORKPLACE_SCHOOL in p.get_allowed_workplaces())


func test_teacher_contains_fsb() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_TEACHER
	assert_true(PlayerProfile.WORKPLACE_FSB in p.get_allowed_workplaces())


func test_teacher_allows_unemployed() -> void:
	var p := PlayerProfile.new()
	p.profession = PlayerProfile.PROFESSION_TEACHER
	assert_true(PlayerProfile.WORKPLACE_NONE in p.get_allowed_workplaces())


func test_workplace_names_covers_all_indices() -> void:
	assert_eq(
		PlayerProfile.WORKPLACE_NAMES.size(),
		PlayerProfile.WORKPLACE_SCHOOL + 1
	)
