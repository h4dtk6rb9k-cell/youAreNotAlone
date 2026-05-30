# scenes/profile_center/profile_center_data.gd
class_name ProfileCenterData

const SCENE_ID  := "profile_center"
# Дверь назад заперта — возврат в Двор невозможен
const PREV_SCENE := ""

const TILEMAP_WIDTH:  int = 16
const TILEMAP_HEIGHT: int = 7

const SPECIALIST_TILE: Vector2i = Vector2i(3, -1)

# После завершения диалога со specialist — EndingResolver
const FLAG_SPECIALIST_DONE := "specialist_done"


static func get_npc_spawns() -> Array[SceneNpcSpawn]:
	return [
		SceneNpcSpawn.make("specialist", 3, -1, "specialist", "sw"),
	]
