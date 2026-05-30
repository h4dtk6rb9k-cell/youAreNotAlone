# iso/iso_camera.gd — ADR-003
class_name IsoCamera
extends Camera2D


func _ready() -> void:
	zoom                      = Vector2(1.0, 1.0)
	position_smoothing_enabled = false


func _process(_delta: float) -> void:
	# Pixel-snap: избегает субпиксельных артефактов
	global_position = global_position.round()
