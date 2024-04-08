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

func sort_linked_list(steps):
	var start_id = null
	var next_ids = []
	for step in steps:
		if step.has("next_id"):
			next_ids.append(step["next_id"])

	# Find the start_id
	for step in steps:
		if not next_ids.has(step["id"]):
			start_id = step["id"]
			break

	# Construct the sorted list
	var sorted_steps = []
	var current_id = start_id
	while current_id != null:
		var current_step = null
		for step in steps:
			if step["id"] == current_id:
				current_step = step
				break
		current_id = null
		if current_step:
			sorted_steps.append(current_step)
			# Update current_id to the next in the list, if it exists
			if current_step.has("next_id"):
				current_id = current_step.get("next_id")
	return sorted_steps

func get_quest_steps_sorted(quest_name:String) -> Array:
	var steps = []
	var quest = get_quest_by_name(quest_name)

	var steps_dic = quest.quest_steps
	for step in steps_dic:
		steps.append(steps_dic[step])
	steps = sort_linked_list(steps)
	return steps
