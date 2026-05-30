# ui/inventory_panel.gd
# Ожидаемые ноды:
#   %CategoriesContainer — VBoxContainer (дочерние — по одному CategoryRow)
#   %ReadHint            — Label  (текст «Мысли ещё не улеглись.», hidden по умолч.)
# Динамически создаёт CategoryRow для каждой непустой категории
extends Control

const _Inventory    = preload("res://core/inventory.gd")
const _ReadCooldown = preload("res://core/read_cooldown.gd")

@onready var _container: VBoxContainer = %CategoriesContainer
@onready var _read_hint:  Label        = %ReadHint

var _inventory:    _Inventory    = null
var _cooldown:     _ReadCooldown = null


func bind(inventory: _Inventory, cooldown: _ReadCooldown) -> void:
	_inventory = inventory
	_cooldown  = cooldown
	_inventory.item_added.connect(_refresh)
	_inventory.item_removed.connect(_refresh)
	_inventory.item_equipped.connect(_refresh)
	_inventory.item_unequipped.connect(_refresh)
	_refresh()


func _refresh(_item = null) -> void:
	for child in _container.get_children():
		child.queue_free()
	_read_hint.visible = false

	if _inventory == null:
		return

	var groups := _inventory.get_grouped()
	for cat in Item.Category.values():
		if not groups.has(cat):
			continue
		var items: Array = groups[cat]
		var header := Label.new()
		header.text = Item.CATEGORY_NAMES[cat]
		header.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		_container.add_child(header)

		for item in items:
			var row := HBoxContainer.new()
			var lbl := Label.new()
			var equipped_mark := " ✓" if _inventory.is_equipped(item.id) else ""
			var lock_mark     := " 🔒" if not item.is_droppable else ""
			lbl.text = item.display_name + equipped_mark + lock_mark
			row.add_child(lbl)

			if item.is_readable:
				var btn := Button.new()
				btn.text = "Читать"
				var can := _inventory.can_read(item, _cooldown) if _cooldown else item.is_readable
				btn.disabled = not can
				if not can and item.id == Item.ID_GUIDE:
					_read_hint.visible = true
				btn.pressed.connect(_on_read_pressed.bind(item))
				row.add_child(btn)

			if item.is_equippable:
				var btn := Button.new()
				btn.text = "Снять" if _inventory.is_equipped(item.id) else "Надеть"
				btn.pressed.connect(_on_equip_pressed.bind(item))
				row.add_child(btn)

			if item.is_droppable:
				var btn := Button.new()
				btn.text = "Выбросить"
				btn.pressed.connect(_on_drop_pressed.bind(item))
				row.add_child(btn)

			_container.add_child(row)


func _on_read_pressed(item: Item) -> void:
	if _cooldown and item.id == Item.ID_GUIDE:
		if not _cooldown.can_read():
			_read_hint.visible = true
			return
		_cooldown.on_read(GameState.stats.identity)
	# TODO(US-05): открыть BookReader для item


func _on_equip_pressed(item: Item) -> void:
	if _inventory.is_equipped(item.id):
		_inventory.unequip()
	else:
		_inventory.equip(item)


func _on_drop_pressed(item: Item) -> void:
	_inventory.remove_item(item)
