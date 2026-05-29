# tests/integration/test_start_items_flow.gd
# Сквозной тест: профиль → стартовые предметы → инвентарь → экипировка
extends GutTest


func _make_inventory(profession: int, has_children: bool) -> Inventory:
	var p := PlayerProfile.new()
	p.profession   = profession
	p.has_children = has_children
	var ids := ItemFactory.generate_start_items(p)
	var inv := Inventory.new()
	for item_id in ids:
		inv.add_item(Item.make(item_id))
	return inv


# ── AC: ровно 3 предмета ───────────────────────────────────────────────────

func test_exactly_three_items_in_inventory() -> void:
	var inv := _make_inventory(PlayerProfile.PROFESSION_ENGINEER, false)
	assert_eq(inv.count(), 3)


# ── AC: слот 1 с детьми = item_photo ──────────────────────────────────────

func test_slot1_is_photo_when_has_children() -> void:
	var inv := _make_inventory(PlayerProfile.PROFESSION_ENGINEER, true)
	assert_true(inv.has_item(Item.ID_PHOTO))


# ── AC: слот 1 без детей = книга ──────────────────────────────────────────

func test_slot1_is_book_when_no_children() -> void:
	var inv := _make_inventory(PlayerProfile.PROFESSION_ENGINEER, false)
	assert_true(
		inv.has_item(Item.ID_BOOK_ATLAS) or inv.has_item(Item.ID_BOOK_UNNAMED),
		"Должна быть книга (атлас или без названия)"
	)


# ── AC: слот 2 МВД = badge_mvd ────────────────────────────────────────────

func test_slot2_is_badge_mvd_for_law_profession() -> void:
	var inv := _make_inventory(PlayerProfile.PROFESSION_LAW, false)
	assert_true(inv.has_item(Item.ID_BADGE_MVD))
	assert_false(inv.has_item(Item.ID_BADGE))


# ── AC: слот 2 остальные = badge ──────────────────────────────────────────

func test_slot2_is_badge_for_non_law_professions() -> void:
	for prof in [
		PlayerProfile.PROFESSION_ENGINEER,
		PlayerProfile.PROFESSION_MEDICAL,
		PlayerProfile.PROFESSION_TEACHER,
		PlayerProfile.PROFESSION_TRANSPORT,
		PlayerProfile.PROFESSION_GOVERNMENT,
		PlayerProfile.PROFESSION_RETAIL,
		PlayerProfile.PROFESSION_UNEMPLOYED,
	]:
		var inv := _make_inventory(prof, false)
		assert_true(inv.has_item(Item.ID_BADGE),
			"Профессия %d: должен быть item_badge" % prof)


# ── AC: слот 3 = item_guide всегда ────────────────────────────────────────

func test_slot3_is_guide_for_all_professions() -> void:
	for prof in PlayerProfile.PROFESSION_NAMES.size():
		var inv := _make_inventory(prof, false)
		assert_true(inv.has_item(Item.ID_GUIDE),
			"Профессия %d: item_guide должен быть в инвентаре" % prof)


# ── AC: item_guide нельзя выбросить ───────────────────────────────────────

func test_guide_cannot_be_dropped_from_start_inventory() -> void:
	var inv   := _make_inventory(PlayerProfile.PROFESSION_ENGINEER, false)
	var guide := inv.get_item(Item.ID_GUIDE)
	assert_not_null(guide)
	var result := inv.remove_item(guide)
	assert_false(result)
	assert_true(inv.has_item(Item.ID_GUIDE))


# ── AC: экипировка значка меняет Identity ─────────────────────────────────

func test_equipping_badge_applies_identity_delta() -> void:
	var inv   := _make_inventory(PlayerProfile.PROFESSION_ENGINEER, false)
	var stats := PlayerStats.new()
	var badge := inv.get_item(Item.ID_BADGE)
	assert_not_null(badge)
	inv.equip(badge)
	stats.apply_delta(badge.identity_delta_on_equip, 0, 0)
	assert_eq(stats.identity, PlayerStats.IDENTITY_START + badge.identity_delta_on_equip)


func test_equipping_mvd_badge_applies_minus_10() -> void:
	var inv   := _make_inventory(PlayerProfile.PROFESSION_LAW, false)
	var stats := PlayerStats.new()
	var badge := inv.get_item(Item.ID_BADGE_MVD)
	inv.equip(badge)
	stats.apply_delta(badge.identity_delta_on_equip, 0, 0)
	assert_eq(stats.identity, PlayerStats.IDENTITY_START - 10)
