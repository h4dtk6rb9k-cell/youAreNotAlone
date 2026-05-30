# core/inventory.gd
class_name Inventory
extends RefCounted

signal item_added(item: Item)
signal item_removed(item: Item)
signal item_equipped(item: Item)
signal item_unequipped(item: Item)
signal passive_bonus_applied(item: Item, delta: int)

var _items:    Array[Item] = []
var _equipped: Item        = null
# Ссылка на stats для применения пассивных бонусов (устанавливается через bind_stats)
var _stats: PlayerStats    = null


func bind_stats(stats: PlayerStats) -> void:
	_stats = stats


func add_item(item: Item) -> void:
	_items.append(item)
	_apply_passive_bonus(item)
	item_added.emit(item)


func _apply_passive_bonus(item: Item) -> void:
	if _stats == null or item.passive_identity_bonus == 0:
		return
	_stats.apply_delta(item.passive_identity_bonus, 0, 0)
	passive_bonus_applied.emit(item, item.passive_identity_bonus)


func remove_item(item: Item) -> bool:
	if not item.is_droppable:
		return false
	var idx := _items.find(item)
	if idx == -1:
		return false
	if _equipped == item:
		unequip()
	_items.remove_at(idx)
	item_removed.emit(item)
	return true


func equip(item: Item) -> bool:
	if not item.is_equippable:
		return false
	if _items.find(item) == -1:
		return false
	if _equipped != null:
		unequip()
	_equipped = item
	item_equipped.emit(item)
	return true


func unequip() -> void:
	if _equipped == null:
		return
	var prev := _equipped
	_equipped = null
	item_unequipped.emit(prev)


func has_item(item_id: String) -> bool:
	for item in _items:
		if item.id == item_id:
			return true
	return false


func get_item(item_id: String) -> Item:
	for item in _items:
		if item.id == item_id:
			return item
	return null


func is_equipped(item_id: String) -> bool:
	return _equipped != null and _equipped.id == item_id


func get_equipped() -> Item:
	return _equipped


func get_all() -> Array[Item]:
	return _items.duplicate()


func count() -> int:
	return _items.size()


# Возвращает предметы указанной категории
func get_by_category(cat: Item.Category) -> Array[Item]:
	var result: Array[Item] = []
	for item in _items:
		if item.category == cat:
			result.append(item)
	return result


# Словарь category → Array[Item] для UI
func get_grouped() -> Dictionary:
	var groups: Dictionary = {}
	for item in _items:
		if not groups.has(item.category):
			groups[item.category] = [] as Array[Item]
		groups[item.category].append(item)
	return groups


func can_read(item: Item, cooldown: ReadCooldown) -> bool:
	if not item.is_readable:
		return false
	if item.id == Item.ID_GUIDE:
		return cooldown.can_read()
	return true
