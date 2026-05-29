# core/read_cooldown.gd — ADR-002
class_name ReadCooldown

const COOLDOWN_SECONDS:        float = 30.0 * 60.0
const IDENTITY_DELTA_REQUIRED: int   = 15

var _last_read_time:       float = -COOLDOWN_SECONDS   # сразу доступно при старте
var _identity_at_last_read: int  = 0
var _quest_completed:      bool  = false
var _combat_occurred:      bool  = false


func can_read() -> bool:
	if _quest_completed:
		return true
	if _combat_occurred:
		return true
	if Time.get_unix_time_from_system() - _last_read_time >= COOLDOWN_SECONDS:
		return true
	if GameState.stats.identity - _identity_at_last_read >= IDENTITY_DELTA_REQUIRED:
		return true
	return false


func on_read(current_identity: int) -> void:
	_last_read_time        = Time.get_unix_time_from_system()
	_identity_at_last_read = current_identity
	_quest_completed       = false
	_combat_occurred       = false


func on_quest_completed() -> void:
	_quest_completed = true


func on_combat_occurred() -> void:
	_combat_occurred = true


func save(config: ConfigFile) -> void:
	config.set_value("cooldown", "last_read_time",    _last_read_time)
	config.set_value("cooldown", "identity_at_read",  _identity_at_last_read)


func load_from(config: ConfigFile) -> void:
	_last_read_time        = config.get_value("cooldown", "last_read_time",
	                          Time.get_unix_time_from_system() - COOLDOWN_SECONDS)
	_identity_at_last_read = config.get_value("cooldown", "identity_at_read", 0)
