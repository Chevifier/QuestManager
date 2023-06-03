extends Node2D

func _ready():
	#create a new quest giving it a name
	var quest := ScriptQuest.new("Reach the Hills")
	#set the quest details
	quest.set_quest_details("Race your rival to the top of the hill.")
	#create an action step 
	var action_step = ScriptQuest.QuestStep.new(ScriptQuest.ACTION_STEP)
	#set step instruction
	action_step.set_step_details("Reach hill")
	#create a timer step
	var timer_step = ScriptQuest.QuestStep.new(ScriptQuest.TIMER_STEP)
	#set timer step instruction
	timer_step.set_step_details("Run back down hill in time")
	#set timer step data; time, is_count_down = true,fail_on_timeout = true
	timer_step.set_timer_data(60,true,true)
	#add step in the order of completion to the quest
	quest.add_step(action_step)
	quest.add_step(timer_step)
	#finish creating quest
	quest.finalize_quest()
	#add quest to player quests
	QuestManager.add_scripted_quest(quest)
	#print player quest
	print(QuestManager.get_all_player_quests())
