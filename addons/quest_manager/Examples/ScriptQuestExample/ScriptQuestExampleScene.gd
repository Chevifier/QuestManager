extends Node2D

func _ready():
	var Quest = ScriptQuest.new("Example","Disc")
	#add an action step
	Quest.add_action_step("Step1")
	#add an incremental step
	Quest.add_incremental_step("Step2", "item", 10)
	#finalize
	Quest.finalize_quest()
	#Add quest to player quests
	QuestManager.add_scripted_quest(Quest)
	#print the quest disctionary
	print(QuestManager.get_player_quest("Example"))
