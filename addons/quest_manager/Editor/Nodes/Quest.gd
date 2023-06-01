@tool
extends EditorNode

#All data get pull to this node on save
@onready var quest_name = $Quest_Name
@onready var quest_details = $Quest_Details

var group_node = null
var quest_rewards_node = null
var group := ""
var steps := []
var quest_rewards := {}

func setup():
	super.setup()
	Node_Type = Type.QUEST_NODE
	focus_nodes.append(quest_name)
	focus_nodes.append(quest_details)

#returns an array with both the stored data and node position and name data
func get_data():
	var data = {
		"quest_id" : id,
		"quest_name" : quest_name.text,
		"quest_details" : quest_details.text,
		"completed" : false,
		"failed" : false,
		"step_index" : 0,
		"steps" : steps,
		"group" : group,
		"meta_data" : get_meta_data(),
		"quest_rewards" : quest_rewards
	}
	return data

func set_data(data):
	id = data["quest_id"]
	quest_name.text = data.quest_name
	quest_details.text = data.quest_details
	steps = data["steps"]
	group = data["group"]
	
func update_group_data():
	group = ""
	if is_instance_valid(group_node):
		group = group_node.get_data()


func update_quest_rewards():
	if is_instance_valid(quest_rewards_node):
		quest_rewards = quest_rewards_node.get_data()
		
func clear_group():
	group = ""
	group_node = null
func clear_rewards():
	quest_rewards = {}
	quest_rewards_node = null

