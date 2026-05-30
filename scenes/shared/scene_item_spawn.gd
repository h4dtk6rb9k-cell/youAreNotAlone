# scenes/shared/scene_item_spawn.gd
# Данные об интерактивном предмете на сцене (позиция + item_id)
class_name SceneItemSpawn
extends RefCounted

var item_id:    String   = ""
var tile_pos:   Vector2i = Vector2i.ZERO
var voice_text: String   = ""   # внутренний голос при подборе


static func make(p_item_id: String, tx: int, ty: int, p_voice: String = "") -> SceneItemSpawn:
	var s          := SceneItemSpawn.new()
	s.item_id       = p_item_id
	s.tile_pos      = Vector2i(tx, ty)
	s.voice_text    = p_voice
	return s
