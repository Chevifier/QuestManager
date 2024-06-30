extends QMQuestStep

var collected = 0
var required = 999
var item_name = ""
func _ready() -> void:
	var step = QuestManager.get_current_step(quest_id,true)
	item_name = step.item_name
	required = step.required
	collected = step.collected

func item_collected(amount:=1):
	collected += amount
