# tests/unit/test_inventory.gd
extends GutTest

var _inv: Inventory


func before_each() -> void:
	_inv = Inventory.new()


# ── AC: ровно 3 предмета ───────────────────────────────────────────────────

func test_start_inventory_has_three_items_for_any_profile() -> void:
	var p := PlayerProfile.new()
	p.first_name = "Тест"
	p.last_name  = "Тестов"
	p.profession  = PlayerProfile.PROFESSION_ENGINEER
	p.has_children = false
	var ids := ItemFactory.generate_start_items(p)
	assert_eq(ids.size(), 3)


func test_add_item_increases_count() -> void:
	_inv.add_item(Item.make(Item.ID_PHOTO))
	assert_eq(_inv.count(), 1)


func test_has_item_true_after_add() -> void:
	_inv.add_item(Item.make(Item.ID_GUIDE))
	assert_true(_inv.has_item(Item.ID_GUIDE))


func test_has_item_false_before_add() -> void:
	assert_false(_inv.has_item(Item.ID_PHOTO))


# ── AC: item_guide нельзя удалить ─────────────────────────────────────────

func test_guide_cannot_be_removed() -> void:
	var guide := Item.make(Item.ID_GUIDE)
	_inv.add_item(guide)
	var result := _inv.remove_item(guide)
	assert_false(result)
	assert_eq(_inv.count(), 1)


func test_droppable_item_can_be_removed() -> void:
	var photo := Item.make(Item.ID_PHOTO)
	_inv.add_item(photo)
	var result := _inv.remove_item(photo)
	assert_true(result)
	assert_eq(_inv.count(), 0)


# ── AC: экипировка значка меняет Identity ─────────────────────────────────

func test_equip_badge_applies_identity_delta() -> void:
	var stats  := PlayerStats.new()
	var badge  := Item.make(Item.ID_BADGE)
	_inv.add_item(badge)
	_inv.equip(badge)
	stats.apply_delta(badge.identity_delta_on_equip, 0, 0)
	assert_eq(stats.identity, PlayerStats.IDENTITY_START - 5)


func test_equip_mvd_badge_applies_minus_10_identity() -> void:
	var stats    := PlayerStats.new()
	var badge    := Item.make(Item.ID_BADGE_MVD)
	_inv.add_item(badge)
	_inv.equip(badge)
	stats.apply_delta(badge.identity_delta_on_equip, 0, 0)
	assert_eq(stats.identity, PlayerStats.IDENTITY_START - 10)


func test_equip_non_equippable_returns_false() -> void:
	var photo := Item.make(Item.ID_PHOTO)
	_inv.add_item(photo)
	assert_false(_inv.equip(photo))


func test_equip_item_not_in_inventory_returns_false() -> void:
	var badge := Item.make(Item.ID_BADGE)
	assert_false(_inv.equip(badge))


func test_equipped_item_is_reported() -> void:
	var badge := Item.make(Item.ID_BADGE)
	_inv.add_item(badge)
	_inv.equip(badge)
	assert_true(_inv.is_equipped(Item.ID_BADGE))


func test_unequip_clears_equipped() -> void:
	var badge := Item.make(Item.ID_BADGE)
	_inv.add_item(badge)
	_inv.equip(badge)
	_inv.unequip()
	assert_false(_inv.is_equipped(Item.ID_BADGE))


func test_equipping_second_badge_replaces_first() -> void:
	var badge     := Item.make(Item.ID_BADGE)
	var badge_mvd := Item.make(Item.ID_BADGE_MVD)
	_inv.add_item(badge)
	_inv.add_item(badge_mvd)
	_inv.equip(badge)
	_inv.equip(badge_mvd)
	assert_false(_inv.is_equipped(Item.ID_BADGE))
	assert_true(_inv.is_equipped(Item.ID_BADGE_MVD))
