extends Area2D


func interact(actor: Node) -> void:
	var level := get_tree().current_scene
	if level == null or not level.has_method("handle_interaction"):
		return

	level.handle_interaction(str(get_meta("interaction_id", "")), actor)
