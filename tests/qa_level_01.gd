extends SceneTree

const LEVEL_PATH := "res://levels/level_01_apartment/Level01Apartment.tscn"
const REQUIRED_PROP_SCENES := [
	"res://levels/common/props/Bed.tscn",
	"res://levels/common/props/Nightstand.tscn",
	"res://levels/common/props/Sofa.tscn",
	"res://levels/common/props/Screen.tscn",
	"res://levels/common/props/TVConsole.tscn",
	"res://levels/common/props/CoffeeTable.tscn",
	"res://levels/common/props/Door.tscn"
]
const REQUIRED_DECOR_SCENES := [
	"res://levels/common/decor/WallShelf.tscn",
	"res://levels/common/decor/TallPlant.tscn",
	"res://levels/common/decor/WarmWindow.tscn",
	"res://levels/common/decor/FadedPortraits.tscn"
]
const FORBIDDEN_ZONE_SAMPLE_STEP := 18.0


func _initialize() -> void:
	call_deferred("_run_checks")


func _run_checks() -> void:
	var errors: Array[String] = []
	var scene := load(LEVEL_PATH)
	_check_required_prop_scenes(errors)
	_check_required_decor_scenes(errors)

	if scene == null:
		errors.append("Level 01 scene could not be loaded.")
	else:
		var level: Node = scene.instantiate()
		root.add_child(level)
		await process_frame
		_check_node(level, "Player", errors)
		_check_node(level, "Room/Walls", errors)
		_check_node(level, "Room/Interactions/ScreenArea", errors)
		_check_node(level, "Room/Interactions/DoorArea", errors)
		_check_node(level, "Navigation/WalkableFloor", errors)
		_check_node(level, "Navigation/NoFeetZones", errors)
		_check_node(level, "Room/Props/Screen/FeedLines", errors)
		_check_node(level, "Room/Props/Door/DoorLight", errors)
		_check_node(level, "BackgroundArt", errors)
		_check_node(level, "Room/Props/Bed", errors)
		_check_node(level, "Room/Props/Nightstand", errors)
		_check_node(level, "Room/Props/Sofa", errors)
		_check_node(level, "Room/Props/TVConsole", errors)
		_check_node(level, "Room/Props/CoffeeTable", errors)
		_check_node(level, "Room/WallShelf", errors)
		_check_node(level, "Room/TallPlant", errors)
		_check_node(level, "Room/WarmWindow", errors)
		_check_node(level, "Room/FadedPortraits", errors)
		_check_node(level, "Player/Visual", errors)
		_check_node(level, "Player/Visual/FeetAnchor", errors)
		_check_node(level, "Player/Visual/CharacterSprite", errors)
		_check_node(level, "SilenceOverlay", errors)
		_check_object_map_enabled(level, errors)
		_check_navigation_layer(level, errors)
		_check_debug_disabled(level, errors)
		_check_player_scale_metadata(level, errors)
		_check_player_foot_anchor(level, errors)
		_check_player_bounds(level, errors)
		_check_forbidden_zone_coverage(level, errors)
		await _check_navigation_samples(level, errors)
		_check_level_logic(level, errors)
		level.queue_free()

	for action in ["move_left", "move_right", "move_up", "move_down", "interact"]:
		if not InputMap.has_action(action):
			errors.append("Missing input action: %s" % action)

	if errors.is_empty():
		print("QA Level 01: PASS")
		quit(0)
	else:
		for error in errors:
			push_error(error)
		print("QA Level 01: FAIL")
		quit(1)


func _check_node(root_node: Node, path: NodePath, errors: Array[String]) -> void:
	if root_node.get_node_or_null(path) == null:
		errors.append("Missing node: %s" % str(path))


func _check_required_prop_scenes(errors: Array[String]) -> void:
	for path in REQUIRED_PROP_SCENES:
		if not ResourceLoader.exists(path):
			errors.append("Missing reusable prop scene: %s" % path)
			continue
		if load(path) == null:
			errors.append("Reusable prop scene could not be loaded: %s" % path)


func _check_required_decor_scenes(errors: Array[String]) -> void:
	for path in REQUIRED_DECOR_SCENES:
		if not ResourceLoader.exists(path):
			errors.append("Missing reusable decor scene: %s" % path)
			continue
		if load(path) == null:
			errors.append("Reusable decor scene could not be loaded: %s" % path)


func _check_debug_disabled(level: Node, errors: Array[String]) -> void:
	var debug_overlay := level.get_node_or_null("DebugOverlay")
	if debug_overlay == null:
		errors.append("Missing node: DebugOverlay")
		return
	if debug_overlay.get("enabled") != false:
		errors.append("Debug overlay is not disabled for playable level.")


func _check_object_map_enabled(level: Node, errors: Array[String]) -> void:
	var background_art := level.get_node_or_null("BackgroundArt")
	if background_art == null:
		errors.append("Missing BackgroundArt reference node.")
	elif background_art.visible:
		errors.append("BackgroundArt is visible; level must be assembled from objects, not a flat background image.")

	var room := level.get_node_or_null("Room")
	if room == null:
		errors.append("Missing object-built Room node.")
	elif not room.visible:
		errors.append("Object-built Room is hidden.")

	for path in ["Room/Props/Bed", "Room/Props/Nightstand", "Room/Props/Sofa", "Room/Props/TVConsole", "Room/Props/CoffeeTable"]:
		var body := level.get_node_or_null(path)
		if body == null:
			continue
		if int(body.get("collision_layer")) == 0:
			errors.append("Object prop has no collision layer: %s" % path)


func _check_navigation_layer(level: Node, errors: Array[String]) -> void:
	var navigation := level.get_node_or_null("Navigation")
	if navigation == null:
		errors.append("Missing editable Navigation layer.")
		return
	if navigation.visible:
		errors.append("Navigation layer must be hidden in playable level.")

	var walkable_floor := level.get_node_or_null("Navigation/WalkableFloor") as Polygon2D
	if walkable_floor == null:
		errors.append("Missing Navigation/WalkableFloor polygon.")
	elif walkable_floor.polygon.size() < 3:
		errors.append("WalkableFloor polygon is too small.")

	var no_feet_zones := level.get_node_or_null("Navigation/NoFeetZones")
	if no_feet_zones == null:
		errors.append("Missing Navigation/NoFeetZones.")
		return
	var polygon_count := 0
	for child in no_feet_zones.get_children():
		var polygon := child as Polygon2D
		if polygon == null:
			errors.append("NoFeetZones child is not a Polygon2D: %s" % child.name)
			continue
		if polygon.polygon.size() < 3:
			errors.append("NoFeetZones polygon is too small: %s" % child.name)
		polygon_count += 1
	if polygon_count < 8:
		errors.append("Expected at least eight no-feet polygons for furniture, door, window, and wall planes.")


func _check_player_bounds(level: Node, errors: Array[String]) -> void:
	var player := level.get_node_or_null("Player")
	if player == null:
		errors.append("Missing player for bounds check.")
		return
	if not player.has_method("set_playable_polygon"):
		errors.append("Player does not support playable polygon bounds.")
		return
	if not player.has_method("set_forbidden_polygons"):
		errors.append("Player does not support forbidden foot polygons.")
		return
	if not player.has_method("_apply_navigation_constraints"):
		errors.append("Player does not expose unified navigation constraints for QA.")
		return

	var outside_point := Vector2(690, 1120)
	player.global_position = outside_point
	player.call("_apply_navigation_constraints")
	if player.global_position == outside_point or not _point_is_valid_player_foot_position(player):
		errors.append("Player was not clamped back into playable room bounds.")

	var tv_point := Vector2(350, 614)
	player.global_position = tv_point
	player.call("_apply_navigation_constraints")
	if player.global_position.distance_to(tv_point) < 1.0 or not _point_is_valid_player_foot_position(player):
		errors.append("Player foot anchor was not pushed out of TV console forbidden zone.")

	var window_wall_point := Vector2(570, 548)
	player.global_position = window_wall_point
	player.call("_apply_navigation_constraints")
	if player.global_position.distance_to(window_wall_point) < 1.0 or not _point_is_valid_player_foot_position(player):
		errors.append("Player foot anchor was not pushed out of window/wall forbidden zone.")

	var door_plane_point := Vector2(630, 548)
	player.global_position = door_plane_point
	player.call("_apply_navigation_constraints")
	if player.global_position.distance_to(door_plane_point) < 1.0 or not _point_is_valid_player_foot_position(player):
		errors.append("Player foot anchor was not pushed out of door plane forbidden zone.")

	var upper_window_point := Vector2(628, 470)
	player.global_position = upper_window_point
	player.call("_apply_navigation_constraints")
	if player.global_position.distance_to(upper_window_point) < 1.0 or not _point_is_valid_player_foot_position(player):
		errors.append("Player foot anchor was not pushed out of upper window/wall forbidden zone.")


func _check_player_scale_metadata(level: Node, errors: Array[String]) -> void:
	var player := level.get_node_or_null("Player")
	if player == null:
		return
	var visual_height: Variant = player.get_meta("visual_height_px", 0)
	if int(visual_height) < 122 or int(visual_height) > 138:
		errors.append("Player visual height metadata is outside believable range for object-built room.")


func _check_player_foot_anchor(level: Node, errors: Array[String]) -> void:
	var sprite := level.get_node_or_null("Player/Visual/CharacterSprite")
	if sprite == null:
		return
	var texture: Texture2D = sprite.texture
	if texture == null:
		errors.append("Player sprite has no texture.")
		return

	var expected_y: float = -float(texture.get_height()) * sprite.scale.y * 0.5
	if abs(sprite.position.y - expected_y) > 0.75:
		errors.append("Player sprite bottom is not aligned to foot anchor.")

	var shadow := level.get_node_or_null("Player/Shadow")
	if shadow == null:
		errors.append("Player shadow missing.")
		return
	if shadow.position.length() > 1.0:
		errors.append("Player shadow is not centered on foot anchor.")


func _check_navigation_samples(level: Node, errors: Array[String]) -> void:
	var player := level.get_node_or_null("Player")
	if player == null:
		return

	var direct_state := root.world_2d.direct_space_state
	var checks := {
		"start": Vector2(338, 740),
		"screen_route": Vector2(250, 560),
		"door_route": Vector2(586, 690),
		"window_light_floor": Vector2(404, 650),
		"door_threshold": Vector2(604, 688)
	}

	for label in checks.keys():
		var params := PhysicsPointQueryParameters2D.new()
		params.position = checks[label]
		params.collision_mask = 1
		params.collide_with_bodies = true
		params.collide_with_areas = false
		var hits := direct_state.intersect_point(params, 8)
		if not hits.is_empty():
			errors.append("Navigation sample blocked by collision: %s" % label)

	var furniture_checks := {
		"bed": Vector2(216, 668),
		"nightstand": Vector2(302, 584),
		"sofa": Vector2(452, 758),
		"tv_console": Vector2(350, 614),
		"coffee_table": Vector2(442, 840)
	}

	for label in furniture_checks.keys():
		var params := PhysicsPointQueryParameters2D.new()
		params.position = furniture_checks[label]
		params.collision_mask = 1
		params.collide_with_bodies = true
		params.collide_with_areas = false
		var hits := direct_state.intersect_point(params, 8)
		if hits.is_empty():
			errors.append("Furniture sample is not blocked by collision: %s" % label)

	var forbidden_foot_checks := {
		"window_wall": Vector2(570, 548),
		"upper_window_plane": Vector2(610, 586),
		"door_top_plane": Vector2(630, 548),
		"door_mid_plane": Vector2(642, 604),
		"upper_window_wall": Vector2(628, 470),
		"upper_right_wall_edge": Vector2(654, 512)
	}

	for label in forbidden_foot_checks.keys():
		player.global_position = forbidden_foot_checks[label]
		player.call("_apply_navigation_constraints")
		if player.global_position.distance_to(forbidden_foot_checks[label]) < 1.0 or not _point_is_valid_player_foot_position(player):
			errors.append("Forbidden foot sample did not move player: %s" % label)


func _check_forbidden_zone_coverage(level: Node, errors: Array[String]) -> void:
	var player := level.get_node_or_null("Player")
	if player == null:
		return
	var no_feet_zones := level.get_node_or_null("Navigation/NoFeetZones")
	if no_feet_zones == null:
		return

	for child in no_feet_zones.get_children():
		var forbidden_zone := child as Polygon2D
		if forbidden_zone == null or forbidden_zone.polygon.size() < 3:
			continue
		_check_forbidden_zone_samples(player, forbidden_zone, errors)


func _check_forbidden_zone_samples(player: Node2D, forbidden_zone: Polygon2D, errors: Array[String]) -> void:
	var global_polygon := _polygon_to_global(forbidden_zone)
	var bounds := _polygon_bounds(global_polygon)
	var checked_points := 0
	var failures := 0
	var y := bounds.position.y
	while y <= bounds.end.y:
		var x := bounds.position.x
		while x <= bounds.end.x:
			var sample := Vector2(x, y)
			if Geometry2D.is_point_in_polygon(sample, global_polygon):
				checked_points += 1
				player.global_position = sample
				player.call("_apply_navigation_constraints")
				if not _point_is_valid_player_foot_position(player):
					failures += 1
			x += FORBIDDEN_ZONE_SAMPLE_STEP
		y += FORBIDDEN_ZONE_SAMPLE_STEP

	if checked_points == 0:
		errors.append("No dense samples were generated for forbidden zone: %s" % forbidden_zone.name)
	elif failures > 0:
		errors.append("Forbidden zone dense coverage failed for %s: %d/%d samples remained blocked." % [forbidden_zone.name, failures, checked_points])


func _point_is_inside_any_forbidden_zone(point: Vector2, forbidden_polygons: Array[PackedVector2Array]) -> bool:
	for polygon in forbidden_polygons:
		if polygon.size() >= 3 and Geometry2D.is_point_in_polygon(point, polygon):
			return true
	return false


func _point_is_valid_player_foot_position(player: Node) -> bool:
	return Geometry2D.is_point_in_polygon(player.global_position, player.playable_polygon) and not _point_is_inside_any_forbidden_zone(player.global_position, player.forbidden_polygons)


func _polygon_to_global(source: Polygon2D) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for point in source.polygon:
		polygon.append(source.to_global(point))
	return polygon


func _polygon_bounds(polygon: PackedVector2Array) -> Rect2:
	var min_point := polygon[0]
	var max_point := polygon[0]
	for point in polygon:
		min_point.x = min(min_point.x, point.x)
		min_point.y = min(min_point.y, point.y)
		max_point.x = max(max_point.x, point.x)
		max_point.y = max(max_point.y, point.y)
	return Rect2(min_point, max_point - min_point)


func _check_level_logic(level: Node, errors: Array[String]) -> void:
	if not level.has_method("handle_interaction"):
		errors.append("Level does not expose handle_interaction.")
		return

	var game_state := root.get_node_or_null("GameState")
	var dialogue_manager := root.get_node_or_null("DialogueManager")
	if game_state == null:
		errors.append("GameState autoload is missing.")
		return
	if dialogue_manager == null:
		errors.append("DialogueManager autoload is missing.")
		return

	game_state.set_flag("screen_off", false)
	level.handle_interaction("door", null)
	if dialogue_manager.current_text != "я ещё не готов выйти":
		errors.append("Door did not show locked text before screen was off.")

	level.handle_interaction("screen", null)
	if not game_state.get_flag("screen_off", false):
		errors.append("Screen interaction did not set screen_off.")
	if dialogue_manager.current_text != "стало тихо":
		errors.append("Screen did not show silence text.")

	level.handle_interaction("screen", null)
	if dialogue_manager.current_text != "экран уже молчит":
		errors.append("Screen did not show already-off text on repeated interaction.")

	level.handle_interaction("door", null)
	if dialogue_manager.current_text != "Глава 1: Тихий сбой":
		errors.append("Door did not show transition text after screen was off.")
