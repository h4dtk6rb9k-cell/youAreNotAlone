extends CanvasLayer

@onready var panel: PanelContainer = $Panel
@onready var label: Label = $Panel/MarginContainer/Text
@onready var timer: Timer = $Timer


func _ready() -> void:
	panel.visible = false
	DialogueManager.line_requested.connect(_on_line_requested)
	DialogueManager.cleared.connect(_on_cleared)
	timer.timeout.connect(_on_timeout)


func _on_line_requested(text: String) -> void:
	label.text = text
	panel.visible = true
	timer.start()


func _on_cleared() -> void:
	panel.visible = false
	label.text = ""
	timer.stop()


func _on_timeout() -> void:
	DialogueManager.clear()
