# tests/unit/test_save_manager.gd
extends GutTest

func before_each() -> void:
	if FileAccess.file_exists(SaveManager.SAVE_PATH):
		DirAccess.remove_absolute(SaveManager.SAVE_PATH)


func after_each() -> void:
	if FileAccess.file_exists(SaveManager.SAVE_PATH):
		DirAccess.remove_absolute(SaveManager.SAVE_PATH)


func _make_full_profile() -> PlayerProfile:
	var p := PlayerProfile.new()
	p.first_name     = "Иван"
	p.last_name      = "Петров"
	p.patronymic     = "Сергеевич"
	p.gender         = 0
	p.age            = 35
	p.education      = 2
	p.marital_status = 1
	p.has_children   = true
	p.profession     = PlayerProfile.PROFESSION_ENGINEER
	p.workplace      = PlayerProfile.WORKPLACE_RZD
	p.favorite_book  = ""
	return p


func test_roundtrip_preserves_first_and_last_name() -> void:
	var original := _make_full_profile()
	SaveManager.save_profile(original)
	var loaded := SaveManager.load_profile()
	assert_eq(loaded.first_name, original.first_name)
	assert_eq(loaded.last_name,  original.last_name)


func test_roundtrip_preserves_all_fields() -> void:
	var original := _make_full_profile()
	SaveManager.save_profile(original)
	var loaded := SaveManager.load_profile()
	assert_eq(loaded.patronymic,     original.patronymic)
	assert_eq(loaded.gender,         original.gender)
	assert_eq(loaded.age,            original.age)
	assert_eq(loaded.education,      original.education)
	assert_eq(loaded.marital_status, original.marital_status)
	assert_eq(loaded.has_children,   original.has_children)
	assert_eq(loaded.profession,     original.profession)
	assert_eq(loaded.workplace,      original.workplace)


func test_load_returns_default_profile_when_no_file() -> void:
	var loaded := SaveManager.load_profile()
	assert_eq(loaded.first_name, "")
	assert_eq(loaded.profession, 0)


func test_has_saved_profile_false_before_save() -> void:
	assert_false(SaveManager.has_saved_profile())


func test_has_saved_profile_true_after_save() -> void:
	SaveManager.save_profile(_make_full_profile())
	assert_true(SaveManager.has_saved_profile())


func test_save_overwrites_previous_profile() -> void:
	var first := _make_full_profile()
	first.first_name = "Иван"
	SaveManager.save_profile(first)

	var second := _make_full_profile()
	second.first_name = "Мария"
	SaveManager.save_profile(second)

	var loaded := SaveManager.load_profile()
	assert_eq(loaded.first_name, "Мария")
