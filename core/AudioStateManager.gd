extends Node

signal atmosphere_changed(state_id: String)

var current_state: String = "apartment_screen_hum"
var silence_active: bool = false


func set_atmosphere(state_id: String) -> void:
	current_state = state_id
	silence_active = state_id == "silence"
	atmosphere_changed.emit(state_id)


func enter_silence() -> void:
	set_atmosphere("silence")
