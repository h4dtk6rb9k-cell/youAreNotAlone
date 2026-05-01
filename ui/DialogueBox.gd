extends CanvasLayer

@onready var panel: PanelContainer = $Panel
@onready var label: Label = $Panel/MarginContainer/Text
@onready var timer: Timer = $Timer

var line_queue: Array[String] = []


func _ready() -> void:
	panel.visible = false
	DialogueManager.line_requested.connect(_on_line_requested)
	DialogueManager.cleared.connect(_on_cleared)
	timer.timeout.connect(_on_timeout)


func _on_line_requested(text: String) -> void:
	if panel.visible and label.text != "":
		line_queue.append(text)
		return
	label.text = text
	panel.visible = true
	timer.start()


func _on_cleared() -> void:
	panel.visible = false
	label.text = ""
	line_queue.clear()
	timer.stop()


func _on_timeout() -> void:
	if not line_queue.is_empty():
		label.text = line_queue.pop_front()
		timer.start()
		return
	DialogueManager.clear()
