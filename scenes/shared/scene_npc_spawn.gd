# scenes/shared/scene_npc_spawn.gd
# Данные об NPC на сцене
class_name SceneNpcSpawn
extends RefCounted

var npc_id:       String   = ""
var tile_pos:     Vector2i = Vector2i.ZERO
var dialogue_node_id: String = ""
var facing_dir:   String   = "s"


static func make(p_npc_id: String, tx: int, ty: int,
				 p_dialogue: String, p_facing: String = "s") -> SceneNpcSpawn:
	var s              := SceneNpcSpawn.new()
	s.npc_id            = p_npc_id
	s.tile_pos          = Vector2i(tx, ty)
	s.dialogue_node_id  = p_dialogue
	s.facing_dir        = p_facing
	return s
