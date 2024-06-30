extends Node

var quest = {}
func _init(_quest_name) -> void:
	quest = QuestManager.get_player_quest(_quest_name)
	set_current_step()

func set_current_step():
	var next_id = quest.next_id
	var step = QuestManager.get_current_step(quest_id)
