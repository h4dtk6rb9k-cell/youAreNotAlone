# ui/stats_hud.gd
# Ожидаемые ноды:
#   %IdentityBar    — ProgressBar  (max=100)
#   %ComplianceBar  — ProgressBar
#   %SuspicionBar   — ProgressBar
#   %SelfhoodBar    — ProgressBar  (visible=false изначально)
#   %SelfhoodRow    — Control      (контейнер полоски Selfhood, visible=false)
extends Control

const TWEEN_DURATION := 0.35

@onready var _identity_bar:   ProgressBar = %IdentityBar
@onready var _compliance_bar: ProgressBar = %ComplianceBar
@onready var _suspicion_bar:  ProgressBar = %SuspicionBar
@onready var _selfhood_bar:   ProgressBar = %SelfhoodBar
@onready var _selfhood_row:   Control     = %SelfhoodRow

var _stats: PlayerStats = null


func bind(stats: PlayerStats) -> void:
	if _stats != null:
		_stats.changed.disconnect(_on_stats_changed)
		_stats.selfhood_just_unlocked.disconnect(_on_selfhood_unlocked)
	_stats = stats
	_stats.changed.connect(_on_stats_changed)
	_stats.selfhood_just_unlocked.connect(_on_selfhood_unlocked)
	_selfhood_row.visible = _stats.selfhood_unlocked()
	_refresh_immediate()


func _refresh_immediate() -> void:
	_identity_bar.value   = _stats.identity
	_compliance_bar.value = _stats.compliance
	_suspicion_bar.value  = _stats.suspicion
	_selfhood_bar.value   = _stats.identity if _stats.selfhood_unlocked() else 0


func _on_stats_changed(identity: int, compliance: int, suspicion: int, _su: bool) -> void:
	_animate_bar(_identity_bar,   identity)
	_animate_bar(_compliance_bar, compliance)
	_animate_bar(_suspicion_bar,  suspicion)
	if _stats.selfhood_unlocked():
		_animate_bar(_selfhood_bar, identity)


func _on_selfhood_unlocked() -> void:
	_selfhood_row.visible  = false
	_selfhood_row.modulate = Color(1, 1, 1, 0)
	_selfhood_row.visible  = true
	var tw := create_tween()
	tw.tween_property(_selfhood_row, "modulate", Color.WHITE, TWEEN_DURATION)
	_selfhood_bar.value = _stats.identity


func _animate_bar(bar: ProgressBar, target: float) -> void:
	var tw := create_tween()
	tw.tween_property(bar, "value", target, TWEEN_DURATION).set_ease(Tween.EASE_OUT)
