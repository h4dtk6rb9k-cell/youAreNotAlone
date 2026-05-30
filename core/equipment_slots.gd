# core/equipment_slots.gd
# Управляет тремя слотами экипировки и применяет StatModifier при надевании/снятии.
class_name EquipmentSlots
extends RefCounted

enum Slot { HEAD, BODY, DOCUMENT }

signal item_equipped(slot: Slot, item: Item)
signal item_unequipped(slot: Slot, item: Item)
signal stat_modifier_applied(identity_delta: int)

var _slots: Dictionary = {
	Slot.HEAD:     null,
	Slot.BODY:     null,
	Slot.DOCUMENT: null,
}

# Ссылка на stats для применения модификаторов
var _stats: PlayerStats = null


func bind_stats(stats: PlayerStats) -> void:
	_stats = stats


# Возвращает подходящий слот для предмета (документы — в DOCUMENT)
static func slot_for(item: Item) -> Slot:
	match item.category:
		Item.Category.DOCUMENT: return Slot.DOCUMENT
		Item.Category.EQUIPMENT: return Slot.BODY
		_: return Slot.HEAD


func equip(item: Item) -> bool:
	if not item.is_equippable:
		return false
	var slot := slot_for(item)
	# Снять текущий предмет в слоте если есть
	if _slots[slot] != null:
		unequip(slot)
	_slots[slot] = item
	_apply_modifier(item.identity_delta_on_equip)
	item_equipped.emit(slot, item)
	return true


func unequip(slot: Slot) -> void:
	var item: Item = _slots[slot]
	if item == null:
		return
	_slots[slot] = null
	# Отменить модификатор — обратный delta
	_apply_modifier(-item.identity_delta_on_equip)
	item_unequipped.emit(slot, item)


func unequip_item(item: Item) -> void:
	for slot in _slots:
		if _slots[slot] == item:
			unequip(slot)
			return


func get_equipped(slot: Slot) -> Item:
	return _slots[slot]


func is_equipped(item_id: String) -> bool:
	for slot in _slots:
		var item: Item = _slots[slot]
		if item != null and item.id == item_id:
			return true
	return false


func is_badge_equipped() -> bool:
	return is_equipped(Item.ID_BADGE) or is_equipped(Item.ID_BADGE_MVD)


func is_mvd_badge_equipped() -> bool:
	return is_equipped(Item.ID_BADGE_MVD)


func _apply_modifier(delta: int) -> void:
	if _stats == null or delta == 0:
		return
	_stats.apply_delta(delta, 0, 0)
	stat_modifier_applied.emit(delta)
