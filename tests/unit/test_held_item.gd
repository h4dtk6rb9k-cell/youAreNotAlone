# tests/unit/test_held_item.gd
extends GutTest


func before_each() -> void:
	GameState.stats               = PlayerStats.new()
	GameState.inventory           = Inventory.new()
	GameState.inventory.bind_stats(GameState.stats)
	GameState.equipment           = EquipmentSlots.new()
	GameState.equipment.bind_stats(GameState.stats)
	GameState.held_item_id        = ""


# ── AC: set_held_item / clear_held_item ───────────────────────────────────

func test_held_item_starts_empty() -> void:
	assert_eq(GameState.held_item_id, "")


func test_set_held_item_updates_id() -> void:
	GameState.set_held_item(Item.ID_PHOTO)
	assert_eq(GameState.held_item_id, Item.ID_PHOTO)


func test_clear_held_item_resets_to_empty() -> void:
	GameState.set_held_item(Item.ID_PHOTO)
	GameState.clear_held_item()
	assert_eq(GameState.held_item_id, "")


func test_set_held_item_emits_signal() -> void:
	watch_signals(GameState)
	GameState.set_held_item(Item.ID_BADGE)
	assert_signal_emitted(GameState, "held_item_changed")


func test_swapping_item_replaces_previous() -> void:
	GameState.set_held_item(Item.ID_PHOTO)
	GameState.set_held_item(Item.ID_BOOK_ATLAS)
	assert_eq(GameState.held_item_id, Item.ID_BOOK_ATLAS)


# ── AC: DialogueSystem читает held_item ──────────────────────────────────

func test_photo_in_hand_triggers_neighbor_branch() -> void:
	GameState.set_held_item(Item.ID_PHOTO)
	var node      := AllDialogues.build()["neighbor"] as DialogueNodeData
	var triggered := DialogueRunner.apply_item_branch(node, GameState.held_item_id, GameState.stats)
	assert_true(triggered)
	assert_eq(GameState.stats.identity, PlayerStats.IDENTITY_START + 5)


func test_no_item_no_branch() -> void:
	var node      := AllDialogues.build()["neighbor"] as DialogueNodeData
	var triggered := DialogueRunner.apply_item_branch(node, GameState.held_item_id, GameState.stats)
	assert_false(triggered)
	assert_eq(GameState.stats.identity, PlayerStats.IDENTITY_START)


func test_badge_does_not_trigger_neighbor_branch() -> void:
	GameState.set_held_item(Item.ID_BADGE)
	var node      := AllDialogues.build()["neighbor"] as DialogueNodeData
	var triggered := DialogueRunner.apply_item_branch(node, GameState.held_item_id, GameState.stats)
	assert_false(triggered)


func test_unnamed_book_triggers_specialist_branch() -> void:
	GameState.set_held_item(Item.ID_BOOK_UNNAMED)
	var node := AllDialogues.build()["specialist"] as DialogueNodeData
	assert_eq(node.item_branch_id, Item.ID_BOOK_UNNAMED)
	# item_branch существует — ветка доступна
	assert_true(node.item_branch_id == GameState.held_item_id)


func test_photo_triggers_girl_branch() -> void:
	GameState.set_held_item(Item.ID_PHOTO)
	var node      := AllDialogues.build()["girl"] as DialogueNodeData
	var triggered := DialogueRunner.apply_item_branch(node, GameState.held_item_id, GameState.stats)
	assert_true(triggered)
	assert_gt(GameState.stats.identity, PlayerStats.IDENTITY_START)


# ── AC: нет предмета → ветки недоступны ──────────────────────────────────

func test_no_held_item_specialist_branch_not_triggered() -> void:
	# held_item_id = "" — ветка книги у специалиста не срабатывает
	var node      := AllDialogues.build()["specialist"] as DialogueNodeData
	var triggered := DialogueRunner.apply_item_branch(node, "", GameState.stats)
	assert_false(triggered)
