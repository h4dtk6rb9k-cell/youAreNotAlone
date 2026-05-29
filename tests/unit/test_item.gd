# tests/unit/test_item.gd
extends GutTest


func test_item_photo_pickup_delta_is_plus_8() -> void:
	var item := Item.make(Item.ID_PHOTO)
	assert_eq(item.identity_delta_on_pickup, 8)


func test_item_badge_equip_delta_is_minus_5() -> void:
	var item := Item.make(Item.ID_BADGE)
	assert_eq(item.identity_delta_on_equip, -5)


func test_item_badge_mvd_equip_delta_is_minus_10() -> void:
	var item := Item.make(Item.ID_BADGE_MVD)
	assert_eq(item.identity_delta_on_equip, -10)


func test_item_guide_is_not_droppable() -> void:
	var item := Item.make(Item.ID_GUIDE)
	assert_false(item.is_droppable)


func test_item_photo_is_droppable() -> void:
	var item := Item.make(Item.ID_PHOTO)
	assert_true(item.is_droppable)


func test_item_badge_is_equippable() -> void:
	var item := Item.make(Item.ID_BADGE)
	assert_true(item.is_equippable)


func test_item_guide_is_readable() -> void:
	var item := Item.make(Item.ID_GUIDE)
	assert_true(item.is_readable)


func test_item_photo_is_not_equippable() -> void:
	var item := Item.make(Item.ID_PHOTO)
	assert_false(item.is_equippable)
