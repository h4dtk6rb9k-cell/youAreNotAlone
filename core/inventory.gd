# core/inventory.gd
class_name Inventory
extends RefCounted

signal item_added(item: Item)
signal item_removed(item: Item)
signal item_equipped(item: Item)
signal item_unequipped(item: Item)

var _items:   Array[Item] = []
var _equipped: Item = null   # одновременно экипирован только один предмет-значок


func add_item(item: Item) -> void:
	_items.append(item)
	item_added.emit(item)


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
