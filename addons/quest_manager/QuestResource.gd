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
	assert(!quest_data.is_empty(),"The Quest: %s was not found in loaded resource" % quest_name)
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


