# iso/iso_character.gd — ADR-003
class_name IsoCharacter
extends CharacterBody2D

const MOVE_SPEED: float = 3.5 * IsoGrid.TILE_WIDTH   # MoveSpeed из GDD × TILE_WIDTH = 224 px/s
const STOP_THRESHOLD: float = 2.0

# 8 направлений в порядке угла от Vector2.angle() при шаге PI/4
const DIRECTIONS: PackedStringArray = ["e", "se", "s", "sw", "w", "nw", "n", "ne"]

# Зеркальные направления (NW/W/SW → NE/E/SE с flip_h)
const MIRROR_MAP: Dictionary = {"nw": "ne", "w": "e", "sw": "se"}

@onready var sprite: Sprite2D = $Sprite2D

var _target_world: Vector2 = Vector2.ZERO
var _facing: String        = "s"
var _moving: bool          = false


func move_to(world_pos: Vector2) -> void:
	_target_world = world_pos
	_moving       = true


func set_facing(dir: String) -> void:
	_facing = dir
	_update_sprite()


func get_facing() -> String:
	return _facing


func is_moving() -> bool:
	return _moving


func _physics_process(delta: float) -> void:
	if not _moving:
		return
	var diff := _target_world - global_position
	if diff.length() < STOP_THRESHOLD:
		global_position = _target_world
		velocity        = Vector2.ZERO
		_moving         = false
		z_index         = IsoGrid.sort_order_from_world(global_position)
		return

	velocity = diff.normalized() * MOVE_SPEED
	move_and_slide()
	global_position = global_position.round()          # pixel-snap
	z_index         = IsoGrid.sort_order_from_world(global_position)
	_facing         = _vector_to_dir(velocity)
	_update_sprite()


func _update_sprite() -> void:
	var dir  := _facing
	var flip := false
	if dir in MIRROR_MAP:
		dir  = MIRROR_MAP[dir]
		flip = true
	if sprite != null:
		sprite.texture = RuntimeArtLibrary.get_character_sprite(name, dir)
		sprite.flip_h  = flip


static func _vector_to_dir(v: Vector2) -> String:
	# Godot Vector2.angle(): 0 = East, CW positive
	var angle := v.angle()                                    # −π … +π
	var idx   := int(round(angle / (PI / 4.0)))
	return DIRECTIONS[((idx % 8) + 8) % 8]
