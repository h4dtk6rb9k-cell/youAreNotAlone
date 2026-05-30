# scenes/courtyard/courtyard_data.gd
# Статическая спецификация Двора из GDD / scenario_v1.md
class_name CourtyardData

const SCENE_ID         := "courtyard"
const NEXT_SCENE       := "res://scenes/profile_center/profile_center.tscn"
const PREV_SCENE       := "res://scenes/apartment/apartment.tscn"

const TILEMAP_WIDTH:  int = 20
const TILEMAP_HEIGHT: int = 8

# Тайлы интерактивных объектов
const TERMINAL_TILE:     Vector2i = Vector2i(8, 2)   # терминал у фонтана
const EXIT_TO_CENTER_TILE: Vector2i = Vector2i(18, 0)  # выход в Центр профилирования
const EXIT_TO_APART_TILE:  Vector2i = Vector2i(0, 0)   # возврат в Квартиру

# Флаги GameState
const FLAG_TERMINAL_USED         := "terminal_used"
const FLAG_ACTIVIST_GAVE_HINT    := "activist_gave_hint"   # ветка C1 активиста
const FLAG_CENTER_UNLOCKED       := "center_unlocked"      # после любого тапа терминала


static func get_npc_spawns() -> Array[SceneNpcSpawn]:
	return [
		SceneNpcSpawn.make("janitor",  3,  1, "janitor",  "e"),
		SceneNpcSpawn.make("activist", 10, 0, "activist", "sw"),
		SceneNpcSpawn.make("girl",     6,  3, "girl",     "s"),
	]
