# ui/character_creation.gd
# Сцена: scenes/character_creation.tscn
#
# Ожидаемые ноды (уникальные имена через %):
#   %FirstNameEdit      — LineEdit
#   %LastNameEdit       — LineEdit
#   %PatronymicEdit     — LineEdit
#   %GenderButton       — CheckButton   (off=М, on=Ж)
#   %AgeSpinBox         — SpinBox
#   %EducationSelect    — OptionButton
#   %MaritalSelect      — OptionButton
#   %HasChildrenButton  — CheckButton
#   %FavoriteBookEdit   — LineEdit
#   %FavoriteBookRow    — Control        (скрывается при has_children=true)
#   %ProfessionSelect   — OptionButton
#   %WorkplaceSelect    — OptionButton
#   %SignButton         — Button
#   %PencilPlayer       — AudioStreamPlayer
#   %DebounceTimer      — Timer          (wait_time=0.05, one_shot=true)
extends Control

const DEBOUNCE_SEC    := 0.05
const APARTMENT_SCENE := "res://scenes/apartment.tscn"

@onready var _first_name_edit:   LineEdit         = %FirstNameEdit
@onready var _last_name_edit:    LineEdit         = %LastNameEdit
@onready var _patronymic_edit:   LineEdit         = %PatronymicEdit
@onready var _gender_button:     CheckButton      = %GenderButton
@onready var _age_spinbox:       SpinBox          = %AgeSpinBox
@onready var _education_select:  OptionButton     = %EducationSelect
@onready var _marital_select:    OptionButton     = %MaritalSelect
@onready var _has_children_btn:  CheckButton      = %HasChildrenButton
@onready var _fav_book_edit:     LineEdit         = %FavoriteBookEdit
@onready var _fav_book_row:      Control          = %FavoriteBookRow
@onready var _profession_select: OptionButton     = %ProfessionSelect
@onready var _workplace_select:  OptionButton     = %WorkplaceSelect
@onready var _sign_button:       Button           = %SignButton
@onready var _pencil_player:     AudioStreamPlayer = %PencilPlayer
@onready var _debounce_timer:    Timer            = %DebounceTimer


func _ready() -> void:
	_debounce_timer.wait_time = DEBOUNCE_SEC
	_debounce_timer.one_shot  = true
	_debounce_timer.timeout.connect(_on_debounce_timeout)

	_populate_profession_select()
	_populate_workplace_select(_profession_select.get_selected_id())

	_first_name_edit.text_changed.connect(_on_text_changed)
	_last_name_edit.text_changed.connect(_on_text_changed)
	_patronymic_edit.text_changed.connect(_on_text_changed)
	_fav_book_edit.text_changed.connect(_on_text_changed)

	_has_children_btn.toggled.connect(_on_has_children_toggled)
	_profession_select.item_selected.connect(_on_profession_selected)
	_sign_button.pressed.connect(_on_sign_pressed)

	_update_sign_button()


# ── Звук карандаша ──────────────────────────────────────────────────────────

func _on_text_changed(_new_text: String) -> void:
	_debounce_timer.start()


func _on_debounce_timeout() -> void:
	_pencil_player.play()
	_update_sign_button()


# ── Профессия → фильтрация рабочих мест ────────────────────────────────────

func _populate_profession_select() -> void:
	_profession_select.clear()
	for i in PlayerProfile.PROFESSION_NAMES.size():
		_profession_select.add_item(PlayerProfile.PROFESSION_NAMES[i], i)


func _on_profession_selected(index: int) -> void:
	var profession_id: int = _profession_select.get_item_id(index)
	_populate_workplace_select(profession_id)
	_update_sign_button()


func _populate_workplace_select(profession_id: int) -> void:
	_workplace_select.clear()
	var allowed: Array = PlayerProfile.PROFESSION_WORKPLACES.get(
		profession_id, [PlayerProfile.WORKPLACE_NONE]
	)
	for workplace_id in allowed:
		_workplace_select.add_item(PlayerProfile.WORKPLACE_NAMES[workplace_id], workplace_id)


# ── Книга видна только без детей ───────────────────────────────────────────

func _on_has_children_toggled(pressed: bool) -> void:
	_fav_book_row.visible = not pressed
	_update_sign_button()


# ── Валидация кнопки «Подписать» ───────────────────────────────────────────

func _update_sign_button() -> void:
	_sign_button.disabled = not _is_form_valid()


func _is_form_valid() -> bool:
	return (
		_first_name_edit.text.strip_edges() != "" and
		_last_name_edit.text.strip_edges() != ""
	)


# ── Подписать ──────────────────────────────────────────────────────────────

func _on_sign_pressed() -> void:
	var profile := _build_profile()
	SaveManager.save_profile(profile)
	GameState.profile = profile
	get_tree().change_scene_to_file(APARTMENT_SCENE)


func _build_profile() -> PlayerProfile:
	var p := PlayerProfile.new()
	p.first_name     = _first_name_edit.text.strip_edges()
	p.last_name      = _last_name_edit.text.strip_edges()
	p.patronymic     = _patronymic_edit.text.strip_edges()
	p.gender         = 1 if _gender_button.button_pressed else 0
	p.age            = int(_age_spinbox.value)
	p.education      = _education_select.get_selected_id()
	p.marital_status = _marital_select.get_selected_id()
	p.has_children   = _has_children_btn.button_pressed
	p.profession     = _profession_select.get_selected_id()
	p.workplace      = _workplace_select.get_selected_id()
	p.favorite_book  = _fav_book_edit.text.strip_edges()
	return p
