extends Area2D
#Helper Class for positional Actions
#i.e Go to location (WIP)
@export var quest_name = ""
@export var target:Node2D
@export var step_index = -1

func set_quest_name(quest:String) -> void:
	quest_name = quest

func set_target(target):
	self.target = target

func _on_body_entered(body):
	if QuestManager.has_quest(quest_name) == false:
		return
	if target == null:
		return
	if body == target:
		QuestManager.progress_quest(quest_name)
		queue_free()
