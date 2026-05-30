# ui/ending_screen.gd
# Ожидаемые ноды:
#   %EndingTitle  — Label   (название концовки)
#   %EndingText   — RichTextLabel  (текст из scenario_v1.md)
#   %StarLabel    — Label   (★, visible только для Selfhood)
#   %RestartButton — Button
extends Control

const ENDING_TITLES := {
	EndingChecker.Ending.SELFHOOD:   "Самость ★",
	EndingChecker.Ending.CONFORMIST: "Конформист",
	EndingChecker.Ending.REBEL:      "Бунтарь",
}

@onready var _title:   Label         = %EndingTitle
@onready var _text:    RichTextLabel = %EndingText
@onready var _star:    Label         = %StarLabel
@onready var _restart: Button        = %RestartButton


func _ready() -> void:
	_restart.pressed.connect(_on_restart)
	visible = false


func show_ending(ending: EndingChecker.Ending) -> void:
	_title.text      = ENDING_TITLES.get(ending, "")
	_text.text       = EndingChecker.get_text(ending)
	_star.visible    = ending == EndingChecker.Ending.SELFHOOD
	visible          = true
	_animate_in()


func _animate_in() -> void:
	modulate   = Color(1, 1, 1, 0)
	var tw     := create_tween()
	tw.tween_property(self, "modulate", Color.WHITE, 1.2)


func _on_restart() -> void:
	GameState.stats   = PlayerStats.new()
	GameState.inventory = Inventory.new()
	get_tree().change_scene_to_file("res://scenes/character_creation.tscn")
