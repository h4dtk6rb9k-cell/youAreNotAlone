extends Node

signal focus_changed(interactable: Node)

var focused_interactable: Node = null


func set_focus(interactable: Node) -> void:
	if focused_interactable == interactable:
		return
	focused_interactable = interactable
	focus_changed.emit(focused_interactable)


func clear_focus(interactable: Node) -> void:
	if focused_interactable != interactable:
		return
	focused_interactable = null
	focus_changed.emit(null)


func try_interact(actor: Node) -> bool:
	if focused_interactable == null:
		return false
	if not focused_interactable.has_method("interact"):
		return false

	focused_interactable.interact(actor)
	return true
