# tests/unit/test_inventory_categories.gd
extends GutTest

var _inv: Inventory
var _stats: PlayerStats


func before_each() -> void:
	_stats = PlayerStats.new()
	_inv   = Inventory.new()
	_inv.bind_stats(_stats)


# ── AC: предметы сгруппированы по категориям ──────────────────────────────

func test_photo_has_category_memory() -> void:
	assert_eq(Item.make(Item.ID_PHOTO).category, Item.Category.MEMORY)


func test_badge_has_category_document() -> void:
	assert_eq(Item.make(Item.ID_BADGE).category, Item.Category.DOCUMENT)


func test_guide_has_category_special() -> void:
	assert_eq(Item.make(Item.ID_GUIDE).category, Item.Category.SPECIAL)


func test_get_by_category_returns_only_matching() -> void:
	_inv.add_item(Item.make(Item.ID_PHOTO))
	_inv.add_item(Item.make(Item.ID_BADGE))
	_inv.add_item(Item.make(Item.ID_GUIDE))
	var memories := _inv.get_by_category(Item.Category.MEMORY)
	assert_eq(memories.size(), 1)
	assert_eq(memories[0].id, Item.ID_PHOTO)


func test_get_grouped_returns_all_categories_present() -> void:
	_inv.add_item(Item.make(Item.ID_PHOTO))
	_inv.add_item(Item.make(Item.ID_BADGE))
	_inv.add_item(Item.make(Item.ID_GUIDE))
	var groups := _inv.get_grouped()
	assert_true(groups.has(Item.Category.MEMORY))
	assert_true(groups.has(Item.Category.DOCUMENT))
	assert_true(groups.has(Item.Category.SPECIAL))
	assert_false(groups.has(Item.Category.WEAPON))


# ── AC: пассивный бонус Identity применяется при add ─────────────────────

func test_photo_applies_passive_identity_bonus_on_add() -> void:
	var before := _stats.identity
	_inv.add_item(Item.make(Item.ID_PHOTO))
	assert_eq(_stats.identity, before + 8)


func test_atlas_applies_passive_identity_bonus_on_add() -> void:
	var before := _stats.identity
	_inv.add_item(Item.make(Item.ID_BOOK_ATLAS))
	assert_eq(_stats.identity, before + 5)


func test_badge_no_passive_bonus() -> void:
	var before := _stats.identity
	_inv.add_item(Item.make(Item.ID_BADGE))
	assert_eq(_stats.identity, before)


func test_passive_bonus_not_applied_without_bound_stats() -> void:
	var inv_unbound := Inventory.new()   # без bind_stats
	inv_unbound.add_item(Item.make(Item.ID_PHOTO))
	# не должно упасть — просто ничего не происходит


# ── AC: item_guide выбросить невозможно ───────────────────────────────────

func test_guide_remove_returns_false() -> void:
	var guide := Item.make(Item.ID_GUIDE)
	_inv.add_item(guide)
	assert_false(_inv.remove_item(guide))
	assert_eq(_inv.count(), 1)


# ── AC: can_read для руководства проверяет ReadCooldown ──────────────────

func test_can_read_guide_initially_true() -> void:
	var guide    := Item.make(Item.ID_GUIDE)
	var cooldown := ReadCooldown.new()
	assert_true(_inv.can_read(guide, cooldown))


func test_can_read_guide_false_after_reading() -> void:
	var guide    := Item.make(Item.ID_GUIDE)
	var cooldown := ReadCooldown.new()
	cooldown.on_read(_stats.identity)
	assert_false(_inv.can_read(guide, cooldown))


func test_can_read_atlas_always_true_no_cooldown() -> void:
	var atlas    := Item.make(Item.ID_BOOK_ATLAS)
	var cooldown := ReadCooldown.new()
	cooldown.on_read(_stats.identity)   # cooldown активен
	assert_true(_inv.can_read(atlas, cooldown))   # книги без cooldown


func test_cannot_read_non_readable_item() -> void:
	var badge    := Item.make(Item.ID_BADGE)
	var cooldown := ReadCooldown.new()
	assert_false(_inv.can_read(badge, cooldown))
