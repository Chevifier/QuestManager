extends Area2D
#Helper Class for positional Actions
#i.e Go to location (WIP)
#Requires a Collision shape to be added

@export var quest_name = ""
@export var target:Node2D
@export var step_id = ""
#Not implemented
@export var use_meta_data := false
@export var meta_data_entry = ""

func set_quest_name(quest:String) -> void:
	quest_name = quest

func set_target(target):
	self.target = target

func _on_body_entered(body):
	if QuestManager.active_quest == "":
		return
	#TO-DO check all quest that relates to this Area and update them
	if target == null:
		return
	if body == target:
		print(QuestManager.active_quest)
		QuestManager.progress_quest(QuestManager.active_quest)
		queue_free()
