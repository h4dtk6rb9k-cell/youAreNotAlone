extends CanvasLayer

@export var enabled: bool = true

@onready var label: Label = $Label


func _ready() -> void:
	visible = enabled


func _process(_delta: float) -> void:
	if not enabled:
		return

	var focus_name := "none"
	if InteractionManager.focused_interactable != null:
		focus_name = InteractionManager.focused_interactable.name

	label.text = "Level: %s\nScreen off: %s\nInteract: %s" % [
		GameState.current_level_id,
		str(GameState.get_flag("screen_off", false)),
		focus_name
	]
