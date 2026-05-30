# core/dialogue_runner.gd
class_name DialogueRunner

const _AllDialogues  = preload("res://data/dialogues/all_dialogues.gd")
const _Localization  = preload("res://core/localization.gd")


# Хелпер: берёт badge-состояние из GameState.equipment
static func get_choices_from_game_state(node: DialogueNodeData) -> Array[DialogueChoice]:
	return get_choices(
		node,
		GameState.equipment.is_badge_equipped(),
		GameState.equipment.is_mvd_badge_equipped()
	)

# Возвращает доступные варианты выбора с учётом экипированного значка
static func get_choices(
	node: DialogueNodeData,
	badge_equipped: bool,
	badge_is_mvd: bool
) -> Array[DialogueChoice]:
	# Если активист и значок надет — диалог недоступен
	if node.badge_silences_npc and badge_equipped:
		return []

	var result: Array[DialogueChoice] = []
	for choice in node.choices:
		# Значок блокирует конкретные варианты (дворник: B и C)
		if badge_equipped and choice.id in node.badge_blocks_choice_ids:
			continue
		result.append(choice)
	return result


# Применяет ветку предмета если предмет в руке совпадает с триггером
static func apply_item_branch(
	node: DialogueNodeData,
	held_item_id: String,
	stats: PlayerStats
) -> bool:
	if node.item_branch_id == "" or held_item_id != node.item_branch_id:
		return false
	stats.apply_delta(
		node.item_branch_identity_delta,
		0,
		node.item_branch_suspicion_delta
	)
	return true


# Применяет ветку значка МВД (тихое срабатывание)
static func apply_badge_silence(
	node: DialogueNodeData,
	badge_equipped: bool,
	stats: PlayerStats
) -> bool:
	if not node.badge_silences_npc or not badge_equipped:
		return false
	stats.apply_delta(0, 0, node.badge_silence_suspicion_delta)
	return true


# Применяет дельты выбора к статам
static func apply_choice(choice: DialogueChoice, stats: PlayerStats) -> void:
	stats.apply_delta(choice.identity_delta, choice.compliance_delta, choice.suspicion_delta)


# Форматирует текст узла через Localization
static func format_text(raw: String) -> String:
	return _Localization.localize(raw)


# Проверяет доступность скрытого терминала
static func can_access_hidden_terminal(stats: PlayerStats, activist_gave_hint: bool) -> bool:
	return stats.suspicion < 30 or activist_gave_hint
