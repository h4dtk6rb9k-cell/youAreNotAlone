extends CharacterBody2D

@export var speed: float = 180.0
@export var mobile_input_vector: Vector2 = Vector2.ZERO

@onready var visual: Node2D = $Visual

var playable_polygon: PackedVector2Array = PackedVector2Array()
var forbidden_polygons: Array[PackedVector2Array] = []


func _ready() -> void:
	add_to_group("player")


func _physics_process(_delta: float) -> void:
	var keyboard_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input_vector := keyboard_vector

	if input_vector == Vector2.ZERO:
		input_vector = mobile_input_vector

	velocity = input_vector.normalized() * speed
	move_and_slide()
	_apply_navigation_constraints()

	if velocity.x < -1.0:
		visual.scale.x = -1.0
	elif velocity.x > 1.0:
		visual.scale.x = 1.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if InteractionManager.try_interact(self):
			get_viewport().set_input_as_handled()


func set_mobile_input(vector: Vector2) -> void:
	mobile_input_vector = vector


func set_playable_polygon(polygon: PackedVector2Array) -> void:
	playable_polygon = polygon


func set_forbidden_polygons(polygons: Array[PackedVector2Array]) -> void:
	forbidden_polygons = polygons


func _keep_inside_playable_polygon() -> void:
	if playable_polygon.size() < 3:
		return
	if Geometry2D.is_point_in_polygon(global_position, playable_polygon):
		return

	var closest_point := playable_polygon[0]
	var closest_distance := INF
	for index in playable_polygon.size():
		var start := playable_polygon[index]
		var end := playable_polygon[(index + 1) % playable_polygon.size()]
		var point := Geometry2D.get_closest_point_to_segment(global_position, start, end)
		var distance := global_position.distance_squared_to(point)
		if distance < closest_distance:
			closest_distance = distance
			closest_point = point

	global_position = closest_point


func _apply_navigation_constraints() -> void:
	for _pass_index in 8:
		_keep_inside_playable_polygon()
		_keep_out_of_forbidden_polygons()
		if Geometry2D.is_point_in_polygon(global_position, playable_polygon) and not _is_inside_any_forbidden_polygon():
			return


func _keep_out_of_forbidden_polygons() -> void:
	for _pass_index in 8:
		var moved := false
		for polygon in forbidden_polygons:
			if polygon.size() < 3:
				continue
			if not Geometry2D.is_point_in_polygon(global_position, polygon):
				continue
			_push_out_of_forbidden_polygon(polygon)
			moved = true
		if not moved or not _is_inside_any_forbidden_polygon():
			return


func _push_out_of_forbidden_polygon(polygon: PackedVector2Array) -> void:
	var origin := global_position
	var best_candidate := origin
	var best_candidate_distance := INF
	for index in polygon.size():
		var start := polygon[index]
		var end := polygon[(index + 1) % polygon.size()]
		var point := Geometry2D.get_closest_point_to_segment(origin, start, end)
		var push_direction := (point - origin).normalized()
		if push_direction == Vector2.ZERO:
			push_direction = Vector2.DOWN

		for distance in [6.0, 12.0, 24.0, 48.0, 96.0, 128.0]:
			var candidate: Vector2 = point + push_direction * float(distance)
			if not _is_valid_navigation_point(candidate):
				continue
			var candidate_distance := origin.distance_squared_to(candidate)
			if candidate_distance < best_candidate_distance:
				best_candidate_distance = candidate_distance
				best_candidate = candidate

	if best_candidate_distance < INF:
		global_position = best_candidate
		return

	global_position = origin


func _is_inside_any_forbidden_polygon() -> bool:
	for polygon in forbidden_polygons:
		if polygon.size() >= 3 and Geometry2D.is_point_in_polygon(global_position, polygon):
			return true
	return false


func _is_valid_navigation_point(point: Vector2) -> bool:
	if playable_polygon.size() >= 3 and not Geometry2D.is_point_in_polygon(point, playable_polygon):
		return false
	for polygon in forbidden_polygons:
		if polygon.size() >= 3 and Geometry2D.is_point_in_polygon(point, polygon):
			return false
	return true
