# data/dialogue_node_data.gd
class_name DialogueNodeData
extends Resource

@export var node_id:         String                  = ""
@export var opening_text:    String                  = ""
# Основные варианты
@export var choices:         Array[DialogueChoice]   = []
# Ветка при наличии предмета в руке (item_id → замещающий текст + дельты без выбора)
@export var item_branch_id:  String                  = ""   # item.id триггера
@export var item_branch_text:String                  = ""
@export var item_branch_identity_delta: int          = 0
@export var item_branch_suspicion_delta: int         = 0
# Ветка при надетом значке (заменяет часть choices или добавляет текст)
@export var badge_branch_text:  String               = ""
@export var badge_blocks_choice_ids: Array[String]   = []
# Если true — ветка значка полностью замещает диалог (активист)
@export var badge_silences_npc: bool                 = false
@export var badge_silence_suspicion_delta: int       = 0
