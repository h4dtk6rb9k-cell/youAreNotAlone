# core/ending_resolver.gd
# Вызывается после завершения узла specialist_form.
# Проверяет приоритет концовок и запускает экран.
class_name EndingResolver
extends Node

const ENDING_SCENE := "res://scenes/ending.tscn"

signal ending_triggered(ending: EndingChecker.Ending)


# Вызвать после любого финального диалогового выбора
func try_resolve() -> EndingChecker.Ending:
	var ending := EndingChecker.evaluate(GameState.stats)
	if ending != EndingChecker.Ending.NONE:
		ending_triggered.emit(ending)
		_go_to_ending_scene(ending)
	return ending


func _go_to_ending_scene(ending: EndingChecker.Ending) -> void:
	# Передаём концовку через GameState.flags, сцена читает и показывает экран
	GameState.set_flag("pending_ending", ending)
	get_tree().change_scene_to_file(ENDING_SCENE)
