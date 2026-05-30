# ui/held_item_hud.gd
# Слот активного предмета в HUD.
# Ожидаемые ноды:
#   %HeldItemLabel — Label  (название предмета или «—»)
#   %ClearButton   — Button (вернуть в инвентарь / очистить)
extends Control


@onready var _label:       Label  = %HeldItemLabel
@onready var _clear_btn:   Button = %ClearButton


func _ready() -> void:
	GameState.held_item_changed.connect(_on_held_changed)
	_clear_btn.pressed.connect(_on_clear_pressed)
	_refresh(GameState.held_item_id)


func _on_held_changed(item_id: String) -> void:
	_refresh(item_id)


func _refresh(item_id: String) -> void:
	if item_id == "":
		_label.text      = "—"
		_clear_btn.visible = false
	else:
		var item := Item.make(item_id)
		_label.text      = item.display_name
		_clear_btn.visible = true


func _on_clear_pressed() -> void:
	GameState.clear_held_item()
