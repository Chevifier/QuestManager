@tool
extends EditorNode

#All data get pull to this node on save
@onready var quest_name = $Quest_Name
@onready var quest_details = $Quest_Details

var group_node = null
var quest_rewards_node = null
var group := ""
var quest_rewards := {}
var quest_steps = {}

func setup():
	super.setup()
	Node_Type = Type.QUEST_NODE
	focus_nodes.append(quest_name)
	focus_nodes.append(quest_details)
	quest_id = id

func get_data():
	node_data["quest_id"]= id
	node_data["quest_name"]= quest_name.text
	node_data["quest_details"]= quest_details.text
	node_data["first_step"]= next_id
	node_data["quest_steps"] = quest_steps
	node_data["completed"]= false
	node_data["failed"]= false
	node_data["group"]= group
	node_data["meta_data"]= get_meta_data()
	node_data["quest_rewards"]= quest_rewards
	super.get_data()
	return node_data

func set_data(data):
	super.set_data(data)
	id = data["quest_id"]
	quest_id = id
	quest_name.text = data.quest_name
	quest_details.text = data.quest_details
	group = data["group"]


func update_group_data():
	group = ""
	if is_instance_valid(group_node):
		group = group_node.get_data()["group"]


func update_quest_rewards():
	if is_instance_valid(quest_rewards_node):
		quest_rewards = quest_rewards_node.get_data()["rewards"]
	else:
		quest_rewards = {}
		
func clear_group():
	group = ""
	group_node = null
func clear_rewards():
	quest_rewards = {}
	quest_rewards_node = null
