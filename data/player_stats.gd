# data/player_stats.gd
class_name PlayerStats
extends Resource

const IDENTITY_START   := 50
const COMPLIANCE_START := 30
const SUSPICION_START  := 0

const SELFHOOD_IDENTITY_THRESHOLD   := 70
const SELFHOOD_COMPLIANCE_THRESHOLD := 30
const CONFORMIST_THRESHOLD          := 70
const REBEL_THRESHOLD               := 60

signal stats_changed(identity: int, compliance: int, suspicion: int, selfhood_unlocked: bool)
signal selfhood_just_unlocked

@export var identity:   int = IDENTITY_START
@export var compliance: int = COMPLIANCE_START
@export var suspicion:  int = SUSPICION_START

var _selfhood_permanently_unlocked: bool = false


func apply_delta(identity_d: int, compliance_d: int, suspicion_d: int) -> void:
	identity   = clampi(identity   + identity_d,   0, 100)
	compliance = clampi(compliance + compliance_d,  0, 100)
	suspicion  = clampi(suspicion  + suspicion_d,   0, 100)
	_check_selfhood()
	stats_changed.emit(identity, compliance, suspicion, _selfhood_permanently_unlocked)


func selfhood_unlocked() -> bool:
	return _selfhood_permanently_unlocked


func _check_selfhood() -> void:
	if _selfhood_permanently_unlocked:
		return
	if identity > SELFHOOD_IDENTITY_THRESHOLD and compliance < SELFHOOD_COMPLIANCE_THRESHOLD:
		_selfhood_permanently_unlocked = true
		selfhood_just_unlocked.emit()


func reset() -> void:
	identity                       = IDENTITY_START
	compliance                     = COMPLIANCE_START
	suspicion                      = SUSPICION_START
	_selfhood_permanently_unlocked = false
	stats_changed.emit(identity, compliance, suspicion, false)
