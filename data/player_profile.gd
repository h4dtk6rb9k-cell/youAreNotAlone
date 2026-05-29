# data/player_profile.gd
class_name PlayerProfile
extends Resource

const PROFESSION_ENGINEER     := 0
const PROFESSION_MEDICAL      := 1
const PROFESSION_TEACHER      := 2
const PROFESSION_LAW          := 3
const PROFESSION_TRANSPORT    := 4
const PROFESSION_GOVERNMENT   := 5
const PROFESSION_RETAIL       := 6
const PROFESSION_UNEMPLOYED   := 7

const PROFESSION_NAMES := [
	"Инженер", "Медик", "Педагог", "МВД",
	"Транспорт", "Госслужба", "Торговля", "Безработный"
]

const WORKPLACE_RZD         := 0
const WORKPLACE_ROSATOM     := 1
const WORKPLACE_ROSCOSMOS   := 2
const WORKPLACE_POST        := 3
const WORKPLACE_MVD         := 4
const WORKPLACE_ARMY        := 5
const WORKPLACE_FSB         := 6
const WORKPLACE_METRO       := 7
const WORKPLACE_CITYTRANS   := 8
const WORKPLACE_UNITY       := 9
const WORKPLACE_VECTOR      := 10
const WORKPLACE_NONE          := 11
const WORKPLACE_CITY_HOSPITAL := 12
const WORKPLACE_SCHOOL        := 13

const WORKPLACE_NAMES := [
	"РЖД", "Росатом", "Роскосмос", "Почта России",
	"МВД", "Армия", "ФСБ",
	"Метро", "ГорТранспорт",
	"Единство", "Вектор",
	"Не трудоустроен",
	"Городская поликлиника",
	"Учебное заведение",
]

const PROFESSION_WORKPLACES := {
	PROFESSION_ENGINEER:    [WORKPLACE_RZD, WORKPLACE_ROSATOM, WORKPLACE_ROSCOSMOS, WORKPLACE_METRO],
	PROFESSION_MEDICAL:     [WORKPLACE_ARMY, WORKPLACE_CITY_HOSPITAL, WORKPLACE_NONE],
	PROFESSION_TEACHER:     [WORKPLACE_FSB, WORKPLACE_SCHOOL, WORKPLACE_NONE],
	PROFESSION_LAW:         [WORKPLACE_MVD, WORKPLACE_ARMY, WORKPLACE_FSB],
	PROFESSION_TRANSPORT:   [WORKPLACE_RZD, WORKPLACE_METRO, WORKPLACE_CITYTRANS],
	PROFESSION_GOVERNMENT:  [WORKPLACE_ROSATOM, WORKPLACE_ROSCOSMOS, WORKPLACE_POST,
	                         WORKPLACE_MVD, WORKPLACE_ARMY, WORKPLACE_FSB],
	PROFESSION_RETAIL:      [WORKPLACE_UNITY, WORKPLACE_VECTOR],
	PROFESSION_UNEMPLOYED:  [WORKPLACE_NONE],
}

@export var first_name: String = ""
@export var last_name: String = ""
@export var patronymic: String = ""
@export var gender: int = 0
@export var age: int = 30
@export var education: int = 0
@export var marital_status: int = 0
@export var has_children: bool = false
@export var profession: int = PROFESSION_ENGINEER
@export var workplace: int = WORKPLACE_RZD
@export var favorite_book: String = ""


func is_valid() -> bool:
	return first_name.strip_edges() != "" and last_name.strip_edges() != ""


func get_allowed_workplaces() -> Array:
	return PROFESSION_WORKPLACES.get(profession, [WORKPLACE_NONE])
