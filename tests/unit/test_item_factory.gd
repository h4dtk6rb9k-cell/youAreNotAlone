# tests/unit/test_item_factory.gd
extends GutTest


func _make_profile(profession: int, has_children: bool) -> PlayerProfile:
	var p := PlayerProfile.new()
	p.profession   = profession
	p.has_children = has_children
	return p


func test_generates_exactly_three_items() -> void:
	var items := ItemFactory.generate_start_items(_make_profile(0, false))
	assert_eq(items.size(), 3)


func test_slot1_is_photo_when_has_children() -> void:
	var items := ItemFactory.generate_start_items(_make_profile(0, true))
	assert_eq(items[0], ItemFactory.ITEM_PHOTO)


func test_slot1_is_book_when_no_children() -> void:
	var items := ItemFactory.generate_start_items(_make_profile(0, false))
	assert_eq(items[0], ItemFactory.ITEM_BOOK)


func test_slot2_is_badge_mvd_for_law_profession() -> void:
	var items := ItemFactory.generate_start_items(
		_make_profile(PlayerProfile.PROFESSION_LAW, false)
	)
	assert_eq(items[1], ItemFactory.ITEM_BADGE_MVD)


func test_slot2_is_regular_badge_for_non_law_professions() -> void:
	var non_law := [
		PlayerProfile.PROFESSION_ENGINEER,
		PlayerProfile.PROFESSION_MEDICAL,
		PlayerProfile.PROFESSION_TEACHER,
		PlayerProfile.PROFESSION_TRANSPORT,
		PlayerProfile.PROFESSION_GOVERNMENT,
		PlayerProfile.PROFESSION_RETAIL,
		PlayerProfile.PROFESSION_UNEMPLOYED,
	]
	for prof in non_law:
		var items := ItemFactory.generate_start_items(_make_profile(prof, false))
		assert_eq(items[1], ItemFactory.ITEM_BADGE,
			"Профессия %d должна давать item_badge" % prof)


func test_slot3_is_always_guide() -> void:
	for prof in PlayerProfile.PROFESSION_NAMES.size():
		var items := ItemFactory.generate_start_items(_make_profile(prof, false))
		assert_eq(items[2], ItemFactory.ITEM_GUIDE,
			"Профессия %d: слот 3 должен быть item_guide" % prof)


func test_guide_is_always_last_regardless_of_children() -> void:
	var with_children    := ItemFactory.generate_start_items(_make_profile(0, true))
	var without_children := ItemFactory.generate_start_items(_make_profile(0, false))
	assert_eq(with_children[2],    ItemFactory.ITEM_GUIDE)
	assert_eq(without_children[2], ItemFactory.ITEM_GUIDE)
