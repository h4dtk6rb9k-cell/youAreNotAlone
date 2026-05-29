# tests/unit/test_localization.gd
extends GutTest


func _set_profile(first_name: String, number: String) -> void:
	GameState.profile              = PlayerProfile.new()
	GameState.profile.first_name   = first_name
	GameState.profile_number       = number


func test_replaces_name_tag() -> void:
	_set_profile("Иван", "")
	assert_eq(Localization.localize("Привет, [Имя]!"), "Привет, Иван!")


func test_replaces_number_tag() -> void:
	_set_profile("", "42-Б")
	assert_eq(Localization.localize("Гражданин [Номер]"), "Гражданин 42-Б")


func test_replaces_both_tags_in_one_string() -> void:
	_set_profile("Мария", "17-А")
	assert_eq(
		Localization.localize("[Имя], ваш номер: [Номер]."),
		"Мария, ваш номер: 17-А."
	)


func test_no_tags_returns_string_unchanged() -> void:
	_set_profile("Иван", "42")
	assert_eq(Localization.localize("Без тегов"), "Без тегов")


func test_empty_string_returns_empty_string() -> void:
	_set_profile("Иван", "42")
	assert_eq(Localization.localize(""), "")


func test_empty_name_leaves_tag_replaced_with_empty() -> void:
	_set_profile("", "")
	assert_eq(Localization.localize("Здравствуйте, [Имя]!"), "Здравствуйте, !")
