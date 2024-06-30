extends Node
#Adds each quest as children to be updated
#Each Quest adds its current step add its child

func _ready() -> void:
	QuestManager.get_player_quest()
