extends Control

@onready var Quest_list = %Quest_List

@onready var quest_name_lbl = %Quest_Name 

@onready var quest_description = %Quest_Description
@onready var quest_step_details = %QuestSteps
@onready var quest_rewards_details = %Rewards


var selected_quest :=""
func _ready():
	set_defaults()
	var quest_path = ProjectSettings.get_setting("quest_file_path","Error")
	assert(quest_path != "Error","Path Not Set")
	if ResourceLoader.exists(quest_path):
		var quest:QuestResource = ResourceLoader.load(quest_path)
		QuestManager.load_quest_resource(quest)
		setup_available_quests(QuestManager.get_quest_list())
	else:
		print("Quest File Not found")


func setup_available_quests(quests):
	Quest_list.clear()
	for quest in quests:
		Quest_list.add_item(quests[quest].quest_name)

func _on_quest_list_item_selected(index):
	selected_quest = Quest_list.get_item_text(index)
	var quest = QuestManager.get_quest_from_resource(selected_quest)
	quest_name_lbl.text = quest.quest_name
	quest_description.text = quest.quest_details
	var steps = quest.quest_steps
	var steps_string :String= ""
	var current = 1
	for step in steps:
		if steps[step].step_type == "end" or steps[step].step_type == "function_call_step":
			continue
		steps_string += str(current) + ". %s \n" % steps[step].details
		current += 1 
	quest_step_details.text = steps_string
	
	var quest_rewards = QuestManager.get_quest_from_resource(selected_quest).quest_rewards
	var rewards_string: String = ""
	var reward_no = 1
	for reward in quest_rewards:
		rewards_string += str(reward_no) +". %s : %s" % [reward,quest_rewards[reward]] 
		reward_no += 1
	if quest_rewards.is_empty():
		rewards_string = "None"
	quest_rewards_details.text = rewards_string
	if QuestManager.has_quest(selected_quest):
		%accept_quest.disabled = true
	else:
		%accept_quest.disabled = false

func _on_accept_quest_pressed():
	if selected_quest == "":
		return
	QuestManager.add_quest(selected_quest)
	%accept_quest.disabled = true


func set_defaults():
	quest_name_lbl.text = "No Quest Select"
	quest_description.text = "No Quest selected"
	quest_step_details.text = "No Quest selected"
