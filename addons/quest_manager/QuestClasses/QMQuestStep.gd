class_name QMQuestStep extends Node
var quest_name = ""
var description = ""
var quest_id := ""
var step_complete:=false
var step_id := ""
var step = {}
func _init(_quest_name) -> void:
	quest_name = quest_name
	quest_id = QuestManager.get_quest_id(_quest_name)
	var step = QuestManager.get_current_step(quest_id,true)
	description = step.description
	step_id = step.id

func _ready() -> void:
	step = QuestManager.get_current_step(quest_id,true)
func get_next_step():
	QuestManager.next(quest_id)
