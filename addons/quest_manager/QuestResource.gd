@tool
class_name QuestResource
extends Resource
#Data for quest Management
@export var quest_data = {} #all data related to the quests
@export var editor_data = {} #all data related to nodes

func get_quest_by_name(quest_name:String) -> Dictionary:
	var return_quest = {}
	for quest in quest_data:
		if quest_data[quest]["quest_name"] == quest_name:
			return_quest = quest_data[quest].duplicate()
			break
	assert(!return_quest.is_empty(),"The Quest: %s was not found in loaded resource" % quest_name)
	return return_quest


func get_quests(group:String="") -> Dictionary:
	var quests = {}
	if group == "":
		quests = quest_data.duplicate()
	else:
		for quest in quest_data:
			if quest.group == group:
				quests[quest.id] = quest.duplicate()
	return quests

func get_quest_list() -> Dictionary:
	return {}

func get_editor_data() -> Dictionary:
	return editor_data

func get_quest_steps_sorted(quest_name:String) -> Array:
	var steps = []
	var quest = get_quest_by_name(quest_name)
	
	var steps_dic = quest.quest_steps
	for step in steps_dic:
		steps.append(steps_dic[step])
	steps.sort_custom(sort_by_next_id)
	return steps

func sort_by_next_id(a,b):
	if a.id == b.next_id:
		return true
	else:
		return false
