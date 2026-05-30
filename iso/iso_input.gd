# iso/iso_input.gd — ADR-003
class_name IsoInput
extends Node

signal on_world_tap(world_pos: Vector2)
signal on_object_tap(body: Node)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed:
			return
	elif event is InputEventScreenTouch:
		if not event.pressed:
			return
	else:
		return

	var screen_pos: Vector2 = event.position
	var world_pos: Vector2  = get_viewport().get_canvas_transform().affine_inverse() * screen_pos

	var space := get_viewport().world_2d.direct_space_state
	var query  := PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	var hits := space.intersect_point(query)

	if hits.size() > 0:
		on_object_tap.emit(hits[0].collider)
	else:
		on_world_tap.emit(world_pos)
