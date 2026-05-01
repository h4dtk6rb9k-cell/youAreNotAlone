extends Node

signal line_requested(text: String)
signal cleared()

var current_text: String = ""


func show_line(text: String) -> void:
	current_text = text
	line_requested.emit(text)


func clear() -> void:
	current_text = ""
	cleared.emit()
