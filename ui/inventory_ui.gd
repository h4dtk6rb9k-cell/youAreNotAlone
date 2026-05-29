# ui/inventory_ui.gd
# Ожидаемые ноды:
#   %Slot1Label  — Label
#   %Slot2Label  — Label
#   %Slot3Label  — Label
#   %EquipButton — Button  (активна когда выбран экипируемый предмет)
extends Control

const _Inventory = preload("res://core/inventory.gd")

@onready var _slot_labels: Array = [%Slot1Label, %Slot2Label, %Slot3Label]
@onready var _equip_button: Button = %EquipButton

var _inventory: _Inventory = null


func bind(inventory: _Inventory) -> void:
	_inventory = inventory
	_inventory.item_added.connect(_refresh)
	_inventory.item_removed.connect(_refresh)
	_inventory.item_equipped.connect(_refresh)
	_inventory.item_unequipped.connect(_refresh)
	_refresh()


func _refresh(_item = null) -> void:
	if _inventory == null:
		return
	var items := _inventory.get_all()
	for i in _slot_labels.size():
		if i < items.size():
			var item = items[i]
			var equipped_mark := " [надет]" if _inventory.is_equipped(item.id) else ""
			var drop_mark     := "" if item.is_droppable else " 🔒"
			_slot_labels[i].text = item.display_name + equipped_mark + drop_mark
		else:
			_slot_labels[i].text = "—"
