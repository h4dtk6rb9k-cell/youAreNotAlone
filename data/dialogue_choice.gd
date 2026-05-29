# data/dialogue_choice.gd
class_name DialogueChoice
extends Resource

@export var id:                  String = ""
@export var text:                String = ""
@export var identity_delta:      int    = 0
@export var compliance_delta:    int    = 0
@export var suspicion_delta:     int    = 0
# ID следующего узла ("" = конец ветки, возврат к caller)
@export var next_node_id:        String = ""


static func make(
	p_id: String,
	p_text: String,
	p_identity: int  = 0,
	p_compliance: int = 0,
	p_suspicion: int  = 0,
	p_next: String    = ""
) -> DialogueChoice:
	var c := DialogueChoice.new()
	c.id               = p_id
	c.text             = p_text
	c.identity_delta   = p_identity
	c.compliance_delta = p_compliance
	c.suspicion_delta  = p_suspicion
	c.next_node_id     = p_next
	return c
