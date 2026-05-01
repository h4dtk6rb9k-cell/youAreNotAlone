extends SceneTree

const LEVEL_PATH := "res://levels/level_01_apartment/Level01Apartment.tscn"


func _initialize() -> void:
	call_deferred("_run_checks")


func _run_checks() -> void:
	var errors: Array[String] = []
	var scene := load(LEVEL_PATH)

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
		_check_node(level, "Room/Props/Screen/FeedLines", errors)
		_check_node(level, "Room/Props/Door/DoorLight", errors)
		_check_node(level, "BackgroundArt", errors)
		_check_node(level, "SolidProps/BedBlocker", errors)
		_check_node(level, "SolidProps/SofaBlocker", errors)
		_check_node(level, "SolidProps/TVConsoleBlocker", errors)
		_check_node(level, "SolidProps/DiningTableBlocker", errors)
		_check_node(level, "Player/Visual", errors)
		_check_node(level, "Player/Visual/FeetAnchor", errors)
		_check_node(level, "Player/Visual/CharacterSprite", errors)
		_check_node(level, "SilenceOverlay", errors)
		_check_debug_disabled(level, errors)
		_check_player_scale_metadata(level, errors)
		_check_player_foot_anchor(level, errors)
		_check_player_bounds(level, errors)
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


func _check_debug_disabled(level: Node, errors: Array[String]) -> void:
	var debug_overlay := level.get_node_or_null("DebugOverlay")
	if debug_overlay == null:
		errors.append("Missing node: DebugOverlay")
		return
	if debug_overlay.get("enabled") != false:
		errors.append("Debug overlay is not disabled for playable level.")


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

	var outside_point := Vector2(660, 1160)
	player.global_position = outside_point
	player.call("_keep_inside_playable_polygon")
	if player.global_position == outside_point:
		errors.append("Player was not clamped back into playable room bounds.")

	var tv_point := Vector2(468, 508)
	player.global_position = tv_point
	player.call("_keep_out_of_forbidden_polygons")
	if player.global_position.distance_to(tv_point) < 1.0:
		errors.append("Player foot anchor was not pushed out of TV console forbidden zone.")


func _check_player_scale_metadata(level: Node, errors: Array[String]) -> void:
	var player := level.get_node_or_null("Player")
	if player == null:
		return
	var visual_height: Variant = player.get_meta("visual_height_px", 0)
	if int(visual_height) < 170 or int(visual_height) > 195:
		errors.append("Player visual height metadata is outside believable range for current room.")


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
		"start": Vector2(338, 640),
		"screen_route": Vector2(436, 548),
		"door_route": Vector2(620, 508),
		"window_light_floor": Vector2(330, 548)
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
		"bed": Vector2(228, 692),
		"sofa": Vector2(467, 710),
		"coffee_table": Vector2(522, 650),
		"tv_console": Vector2(514, 466),
		"tv_console_front": Vector2(468, 508),
		"dining_table": Vector2(603, 924)
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

	level.handle_interaction("door", null)
	if dialogue_manager.current_text != "Глава 1: Тихий сбой":
		errors.append("Door did not show transition text after screen was off.")
