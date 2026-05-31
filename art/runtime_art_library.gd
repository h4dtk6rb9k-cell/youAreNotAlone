# art/runtime_art_library.gd — ADR-003
class_name RuntimeArtLibrary

const ART_BASE_PATH := "res://assets/art/generated/"

# Доступные направления по персонажу (NW/W/SW — зеркало через flip_h)
const CHAR_DIRS := ["e", "n", "s", "ne", "se"]

# Доступные персонажи
const CHAR_AVAILABLE := {
	"player":     ["e", "n", "s"],
	"neighbor":   ["s"],
	"specialist": ["s"],
}

# Доступные пропсы
const PROPS_AVAILABLE := [
	"bed", "desk", "door", "plant", "wardrobe", "terminal"
]

# Доступные тайлы
const TILES_AVAILABLE := ["floor_a", "floor_b", "courtyard"]

# Доступные предметы
const ITEMS_AVAILABLE := ["photo", "book", "badge"]


static func get_character_sprite(char_name: String, dir: String) -> Texture2D:
	var path := "%scharacter_%s_%s.png" % [ART_BASE_PATH, char_name, dir]
	if ResourceLoader.exists(path):
		return load(path)
	# Fallback: пробуем направление "s" как дефолт
	var fallback := "%scharacter_%s_s.png" % [ART_BASE_PATH, char_name]
	if ResourceLoader.exists(fallback):
		return load(fallback)
	return null


static func get_prop_sprite(prop_name: String) -> Texture2D:
	var path := "%sprop_%s.png" % [ART_BASE_PATH, prop_name]
	if ResourceLoader.exists(path):
		return load(path)
	return null


static func get_tile_sprite(tile_name: String) -> Texture2D:
	var path := "%stile_%s.png" % [ART_BASE_PATH, tile_name]
	if ResourceLoader.exists(path):
		return load(path)
	return null


static func get_item_sprite(item_id: String) -> Texture2D:
	# item_id из Item.ID_* → strip "item_" prefix
	var name := item_id.trim_prefix("item_")
	# Алиасы
	match name:
		"book_atlas", "book_unnamed": name = "book"
		"badge_mvd":                  name = "badge"
	var path := "%sitem_%s.png" % [ART_BASE_PATH, name]
	if ResourceLoader.exists(path):
		return load(path)
	return null
