# art/runtime_art_library.gd — ADR-003
class_name RuntimeArtLibrary

const ART_BASE_PATH := "res://assets/art/generated/"


static func get_character_sprite(char_name: String, dir: String) -> Texture2D:
	var path := "%scharacter_%s_%s.png" % [ART_BASE_PATH, char_name, dir]
	if ResourceLoader.exists(path):
		return load(path)
	# Fallback: возвращаем null без краша — IsoCharacter проверяет texture != null
	return null


static func get_prop_sprite(prop_name: String) -> Texture2D:
	var path := "%sprop_%s.png" % [ART_BASE_PATH, prop_name]
	if ResourceLoader.exists(path):
		return load(path)
	return null
