@tool
class_name QuestResource
extends Resource
#Data for quest Management

@export var quest_data = {}
@export var steps_data = {}
@export var items_list = {}
@export var meta_data = {}
@export var groups = {}
#Data For Graph Editing
@export var graph_data = {}
@export var connections_list = []

func set_quest_data(quest_data):
	self.quest_data = quest_data
func set_steps_data(steps_data):
	self.steps_data = steps_data
func set_items_list(item_list):
	self.items_list = items_list
func set_meta_data(meta_data):
	self.meta_data = meta_data
func set_groups(groups):
	self.groups = groups
	
func set_graph_data(graph_data,connections_list):
	self.graph_data = graph_data
	self.connections_list = connections_list

func get_quest_data():
	return quest_data
	
func get_steps_data():
	return steps_data
	
func get_items_list():
	return items_list
	
func get_meta_data():
	return meta_data
	
func get_graph_data():
	return graph_data
	
func get_connections_list():
	return connections_list






