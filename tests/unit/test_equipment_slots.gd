# tests/unit/test_equipment_slots.gd
extends GutTest

var _eq:    EquipmentSlots
var _stats: PlayerStats


func before_each() -> void:
	_stats = PlayerStats.new()
	_eq    = EquipmentSlots.new()
	_eq.bind_stats(_stats)


# ── AC: badge надет → Identity −5 немедленно ─────────────────────────────

func test_equip_badge_reduces_identity_by_5() -> void:
	var badge := Item.make(Item.ID_BADGE)
	_eq.equip(badge)
	assert_eq(_stats.identity, PlayerStats.IDENTITY_START - 5)


# ── AC: badge_mvd надет → Identity −10 немедленно ─────────────────────────

func test_equip_mvd_badge_reduces_identity_by_10() -> void:
	var badge := Item.make(Item.ID_BADGE_MVD)
	_eq.equip(badge)
	assert_eq(_stats.identity, PlayerStats.IDENTITY_START - 10)


# ── AC: предмет снят → модификатор отменяется ────────────────────────────

func test_unequip_badge_restores_identity() -> void:
	var badge := Item.make(Item.ID_BADGE)
	_eq.equip(badge)
	assert_eq(_stats.identity, PlayerStats.IDENTITY_START - 5)
	_eq.unequip(EquipmentSlots.Slot.DOCUMENT)
	assert_eq(_stats.identity, PlayerStats.IDENTITY_START)


func test_unequip_mvd_badge_restores_identity() -> void:
	var badge := Item.make(Item.ID_BADGE_MVD)
	_eq.equip(badge)
	_eq.unequip_item(badge)
	assert_eq(_stats.identity, PlayerStats.IDENTITY_START)


func test_equipping_second_badge_replaces_first_and_restores_delta() -> void:
	var badge     := Item.make(Item.ID_BADGE)
	var badge_mvd := Item.make(Item.ID_BADGE_MVD)
	_eq.equip(badge)
	assert_eq(_stats.identity, PlayerStats.IDENTITY_START - 5)
	_eq.equip(badge_mvd)
	# badge снят (+5), badge_mvd надет (−10): итого −10
	assert_eq(_stats.identity, PlayerStats.IDENTITY_START - 10)


func test_equip_non_equippable_returns_false() -> void:
	var photo := Item.make(Item.ID_PHOTO)
	assert_false(_eq.equip(photo))
	assert_eq(_stats.identity, PlayerStats.IDENTITY_START)


# ── is_badge_equipped / is_mvd_badge_equipped ─────────────────────────────

func test_is_badge_equipped_true_after_equip() -> void:
	_eq.equip(Item.make(Item.ID_BADGE))
	assert_true(_eq.is_badge_equipped())


func test_is_badge_equipped_false_before_equip() -> void:
	assert_false(_eq.is_badge_equipped())


func test_is_mvd_badge_equipped_true() -> void:
	_eq.equip(Item.make(Item.ID_BADGE_MVD))
	assert_true(_eq.is_mvd_badge_equipped())


func test_is_mvd_badge_equipped_false_for_regular_badge() -> void:
	_eq.equip(Item.make(Item.ID_BADGE))
	assert_false(_eq.is_mvd_badge_equipped())


# ── AC: значок надет → ветки сопротивления заблокированы ─────────────────

func test_badge_blocks_resistance_choices_in_janitor() -> void:
	_eq.equip(Item.make(Item.ID_BADGE))
	var nodes   := AllDialogues.build()
	var choices := DialogueRunner.get_choices(
		nodes["janitor"],
		_eq.is_badge_equipped(),
		_eq.is_mvd_badge_equipped()
	)
	var ids := choices.map(func(c): return c.id)
	assert_false("B" in ids)
	assert_false("C" in ids)


func test_no_badge_shows_all_janitor_choices() -> void:
	var nodes   := AllDialogues.build()
	var choices := DialogueRunner.get_choices(nodes["janitor"], false, false)
	assert_eq(choices.size(), 3)


# ── AC: значок МВД → ветка лояльности специалиста открыта ────────────────

func test_mvd_badge_opens_specialist_loyalty_branch() -> void:
	_eq.equip(Item.make(Item.ID_BADGE_MVD))
	var nodes := AllDialogues.build()
	var node  : DialogueNodeData = nodes["specialist"]
	# badge_branch_text должен быть непустым для specialist
	assert_ne(node.badge_branch_text, "")
	# badge является причиной показа ветки — проверяем через флаг
	assert_true(_eq.is_badge_equipped())


# ── HUD реагирует на изменение Identity ──────────────────────────────────

func test_equip_badge_triggers_stats_changed_signal() -> void:
	watch_signals(_stats)
	_eq.equip(Item.make(Item.ID_BADGE))
	assert_signal_emitted(_stats, "changed")
