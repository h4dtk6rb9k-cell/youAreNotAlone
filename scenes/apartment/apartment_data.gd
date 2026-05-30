# scenes/apartment/apartment_data.gd
# Статическая спецификация Квартиры из GDD / scenario_v1.md
class_name ApartmentData

const SCENE_ID    := "apartment"
const NEXT_SCENE  := "res://scenes/courtyard/courtyard.tscn"

const TILEMAP_WIDTH:  int = 25
const TILEMAP_HEIGHT: int = 8
const TILEMAP_ORIGIN: Vector2i = Vector2i(-12, -4)

const PLAYER_START: Vector2i = Vector2i(-2, -2)

# Голос вступления (без выбора)
const INTRO_VOICE_1 := "Завтра перерегистрация. Они говорят — для безопасности. " \
	+ "Я знаю, что это значит. Новый номер. Новое имя. Старое — в архив. " \
	+ "Сначала имя, потом всё остальное."
const INTRO_VOICE_2 := "Три вещи на столе. Я помню, кто я. Пока."

# Пропсы (нет взаимодействия, только визуал / коллизия)
const PROPS: Array = [
	# [tile_x, tile_y, prop_id]
	[-8,  0, "prop_bed"],
	[-4,  1, "prop_wardrobe"],
	[ 3,  0, "prop_desk"],
	[ 6,  2, "prop_plant"],
	[10, -1, "prop_door"],   # дверь — интерактивна (переход в Courtyard)
]

const DOOR_TILE: Vector2i = Vector2i(10, -1)


static func get_item_spawns() -> Array[SceneItemSpawn]:
	return [
		SceneItemSpawn.make(
			Item.ID_PHOTO, -2, 2,
			"Я помню этот день. Они ещё не знали, что мир изменится."
		),
		SceneItemSpawn.make(
			Item.ID_BADGE, 0, 2,
			"Моя работа. Моё место в системе. Удобно, когда носишь — никто не задаёт вопросов."
		),
		SceneItemSpawn.make(
			Item.ID_BOOK_ATLAS, 2, 2,
			"Её запретили два года назад. Я сохранил. Пока они не нашли."
		),
	]


static func get_npc_spawns() -> Array[SceneNpcSpawn]:
	return [
		SceneNpcSpawn.make("neighbor", 7, -1, "neighbor", "sw"),
	]
