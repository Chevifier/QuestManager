@tool
extends Control

@onready var quest_node = preload("res://addons/quest_manager/Editor/Quest_Step_Nodes/quest.tscn")
@onready var step = preload("res://addons/quest_manager/Editor/Quest_Step_Nodes/Step.tscn")
@onready var inc_step = preload("res://addons/quest_manager/Editor/Quest_Step_Nodes/IncrementalStep.tscn")
@onready var item_step = preload("res://addons/quest_manager/Editor/Quest_Step_Nodes/items_step.tscn")
@onready var group_tag = preload("res://addons/quest_manager/Editor/Quest_Step_Nodes/Group.tscn")
@onready var meta_data = preload("res://addons/quest_manager/Editor/Quest_Step_Nodes/Meta_data.tscn")
@onready var end = preload("res://addons/quest_manager/Editor/Quest_Step_Nodes/End.tscn")
var instance_position = Vector2(150,150)
var node_offset = Vector2(0,0)

@onready var new_btn = %New
@onready var save_btn = %Save
@onready var load_btn = %Load
@onready var graph : GraphEdit = %GraphEdit
@onready var context_menu = %MenuButton

#Check to see if all quest are properly structured
#Used for sending warning after save
var quest_chains_complete = false

var current_file_path = ""

var popup_options_list =[
	"Add Quest",
	"Add Step",
	"Add Incremental Step",
	"Add Item Step",
	"Add Group Tag",
	"Add Meta Data",
	"And End Node"
]
@onready var right_mouse_popup : PopupMenu = %right_mouse_list
var quest_data = {}
var graph_data = {}
func _ready():
	set_button_icons()
	right_mouse_popup.clear()
	for item in popup_options_list:
		right_mouse_popup.add_item(item)
	right_mouse_popup.index_pressed.connect(_on_context_menu_index_pressed)
	context_menu.get_popup().clear()
	for item in popup_options_list:
		context_menu.get_popup().add_item(item)
	context_menu.get_popup().index_pressed.connect(_on_context_menu_index_pressed)
	OS.low_processor_usage_mode = true
	
func setup_menu():
	for item in popup_options_list:
		context_menu.get_popup().add_item(item)
	context_menu.get_popup().index_pressed.connect(_on_context_menu_index_pressed)
	context_menu.get_popup().mouse_passthrough = true

func set_button_icons():
	new_btn.icon = get_theme_icon("New", "EditorIcons")
	save_btn.icon = get_theme_icon("Save", "EditorIcons")
	load_btn.icon = get_theme_icon("Load", "EditorIcons")

#func test_save():
#	var packed_scene = PackedScene.new()
#	packed_scene.pack(graph)
#	ResourceSaver.save(packed_scene,"res://my_scene.tscn")


func _on_save_pressed():
	#TO DO check if file already exist and save if not open save dialogue
	if ResourceLoader.exists(current_file_path):
		save_data(current_file_path)
	else:
		%Save_File.popup_centered_clamped(Vector2(300,300))

func _on_load_pressed():
	%Open_File.popup_centered_clamped(Vector2(300,300))


func _on_new_pressed():
	#Create New Save File
	%New_File.popup_centered_clamped(Vector2(300,300))
	

func add_graph_node(index):
	var node
	match index:
		0:
			node = quest_node.instantiate()
		1:
			node = step.instantiate()
		2:
			node = inc_step.instantiate()
		3:
			node = item_step.instantiate()
		4:
			node = group_tag.instantiate()
		5:
			node = meta_data.instantiate()
		6:
			node = end.instantiate()
	if node == null:
		print("Node instance Error, Check Index")
		return
	
	graph.add_child(node)
	node.owner = graph
	node.set_position_offset(instance_position+node_offset)
	node_offset += Vector2(50,50)
	#remove @ signs from random Node names for save/load compatibility
	node.name = node.name.replace("@", "")


func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
	#Prevent multiple connections to same port
	for connection in graph.get_connection_list():
		if connection.to == to_node and connection.to_port == to_port:
			return
			
	var from = get_connection_node(from_node)
	var to = get_connection_node(to_node)
	match from.Node_Type:
		EditorNode.Type.GROUP_NODE:
			to.group_node = from
			from.output_node = to
		EditorNode.Type.META_DATA:
			to.meta_data_node = from
			from.output_node = to
		_:
			to.input_node = from
			from.output_node = to

	graph.connect_node(from_node,from_port,to_node,to_port)
	#graph.set_connection_activity(from_node,from_port,to_node,to_port,1.0)
	updateIdSteps()
	#Check if from node is Group or Meta Data
	updateMetaDataAndGroup(to,from)
	

func updateMetaDataAndGroup(to,from):
	var quest_nodes = get_quest_nodes()
	if  from.Node_Type == EditorNode.Type.GROUP_NODE:
		to.group_node = from
	if from.Node_Type == EditorNode.Type.META_DATA:
		to.meta_data_node = from

	for quest in quest_nodes:
		quest.update_meta_data()
		quest.update_group_data()

func updateIdSteps():
	var quest_nodes = get_quest_nodes()
	quest_chains_complete = false
	for quest in quest_nodes:
		var steps = []
		var current_node = quest.output_node
		while current_node != null:
			quest_chains_complete = false
			if current_node.Node_Type == EditorNode.Type.END_NODE:
				if steps.size() > 0:
					print("Quest: " + quest.id + " steps complete. Steps: " + str(steps))
					quest_chains_complete = true
				break
			steps.append(current_node.id)
			current_node = current_node.output_node
		quest.steps = steps

		
func get_quest_nodes():
	var quest_nodes = []
	for child in graph.get_children():
		if child is EditorNode:
			if child.Node_Type == EditorNode.Type.QUEST_NODE:
				quest_nodes.append(child)
	return quest_nodes

func get_connection_node(node_name):
	for node in graph.get_children():
		if node is EditorNode:
			if node.name == node_name:
				return node

func _on_graph_edit_disconnection_request(from_node, from_port, to_node, to_port):
	var from = get_connection_node(from_node)
	var to = get_connection_node(to_node)
	
	if from.Node_Type == EditorNode.Type.META_DATA:
		to.clear_meta_data()
	if from.Node_Type == EditorNode.Type.GROUP_NODE:
		to.clear_group()
	from.output_node = null
	to.input_node = null
	
	graph.disconnect_node(from_node,from_port,to_node,to_port)
	updateIdSteps()
	
func _on_graph_edit_popup_request(position):
	right_mouse_popup.position = graph.position + position + graph.scroll_offset
	right_mouse_popup.popup()
	#context_menu.get_popup().position = position
	#context_menu.get_popup().popup()

#On Node option selected from context menu
func _on_context_menu_index_pressed(index):
	add_graph_node(index)

func _on_graph_edit_node_selected(node):
#	instance_position = get_global_mouse_position()
	pass


func _on_graph_edit_delete_nodes_request(nodes):
	var to_delete = []
	for node in graph.get_children():
		if node is GraphNode:
			if node.is_selected():
				remove_connections_to_node(node)
				to_delete.append(node)
				
	for node in to_delete:
		node.free()

#remove connection to a node before deleting it
func remove_connections_to_node(node):
	for connection in graph.get_connection_list():
		if connection.to == node.name or connection.from == node.name:
			graph.disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)


func save_new_file(file_path):
	var quest_res = QuestResource.new()
	ResourceSaver.save(quest_res,file_path)
	current_file_path = file_path
	clear_graph()

#=============================SAVE DATA==============================
func save_data(file_path):
	for quest in get_quest_nodes():
		quest.update_group_data()
		quest.update_meta_data()
	
	var Save = FileAccess.open(file_path,FileAccess.WRITE)
	
	Save.store_var(get_quest_data())
	Save.store_var(get_steps_data())
	Save.store_var(get_items_data())
	Save.store_var(get_meta_data())
	Save.store_var(get_editor_data())
	Save.store_var(graph.get_connection_list())
	Save.store_var(get_group_data())

	
#	Save.store_line(JSON.stringify(get_quest_data()))
#	Save.store_line(JSON.stringify(get_steps_data()))
#	Save.store_line(JSON.stringify(get_items_data()))
#	Save.store_line(JSON.stringify(get_meta_data()))
#	Save.store_line(JSON.stringify(get_editor_data()))
#	Save.store_var(graph.get_connection_list())
#	Save.store_var(get_group_data())

	current_file_path = file_path
	if quest_chains_complete == false:
		$Quest_Warning.popup_centered()

func get_quest_data():
	var quest_data = {}
	for node in graph.get_children():
		if node is EditorNode:
			if node.Node_Type == EditorNode.Type.QUEST_NODE:
				quest_data[node.id] = node.get_data()
	return quest_data
	
func get_items_data():
	var items_data = {}
	for node in graph.get_children():
		if node is EditorNode:
			if node.Node_Type == EditorNode.Type.ITEM_STEP_NODE:
				items_data.merge(node.get_items())
	return items_data

func get_steps_data():
	var steps_data = {}
	for node in graph.get_children():
		if node is EditorNode:
			if node.Node_Type == EditorNode.Type.STEP_NODE \
				or node.Node_Type == EditorNode.Type.INCREMENTAL_NODE \
				or node.Node_Type == EditorNode.Type.ITEM_STEP_NODE:
					steps_data[node.id] = node.get_data()
	return steps_data
	
func get_meta_data():
	var meta_data = {}
	for node in graph.get_children():
		if node is EditorNode:
			if node.Node_Type == EditorNode.Type.META_DATA:
				meta_data[node.id] = node.get_data()
	return meta_data

func get_group_data():
	var group_data = {}
	for node in graph.get_children():
		if node is EditorNode:
			if node.Node_Type == EditorNode.Type.GROUP_NODE:
				group_data[node.id] = node.get_data()
	return group_data
	

func get_editor_data():
	var node_data = {}
	for node in graph.get_children():
		if node is EditorNode:
			node_data[node.id] = node.get_node_data()
	return node_data

#=============================LOAD DATA================================

func load_data(file_path):
	var file = FileAccess.open(file_path,FileAccess.READ)
	var err = file.get_open_error()
	if err != OK:
		return err
	var quest_res = QuestResource.new()
	quest_res.quest_data = file.get_var()
	quest_res.steps_data = file.get_var()
	quest_res.items_list = file.get_var()
	quest_res.meta_data = file.get_var()
	quest_res.graph_data = file.get_var()
	quest_res.connections_list = file.get_var()
	quest_res.groups = file.get_var()
	
	current_file_path = file_path
	#clear the current nodes in the graph
	clear_graph()
	#load new node and set data from resource
	
	for i in quest_res.graph_data:
		var node
		match quest_res.graph_data[i].type:
			EditorNode.Type.QUEST_NODE:
				node = quest_node.instantiate()
				graph.add_child(node)
				node.set_node_data(quest_res.graph_data[i])
				node.set_data(quest_res.quest_data[node.id])
			EditorNode.Type.STEP_NODE:
				node = step.instantiate()
				graph.add_child(node)
				node.set_node_data(quest_res.graph_data[i])
				node.set_data(quest_res.steps_data[node.id])
			EditorNode.Type.INCREMENTAL_NODE:
				node = inc_step.instantiate()
				graph.add_child(node)
				node.set_node_data(quest_res.graph_data[i])
				node.set_data(quest_res.steps_data[node.id])
			EditorNode.Type.ITEM_STEP_NODE:
				node = item_step.instantiate()
				graph.add_child(node)
				node.set_node_data(quest_res.graph_data[i])
				var data = quest_res.steps_data[node.id]
				var list = {}
				for item_id in data.item_list:
					list[item_id] = quest_res.items_list[item_id]
				data["items"] = list
				node.set_data(data)
			EditorNode.Type.META_DATA:
				node = meta_data.instantiate()
				graph.add_child(node)
				node.set_node_data(quest_res.graph_data[i])
				node.set_data(quest_res.meta_data[i])
			EditorNode.Type.GROUP_NODE:
				node = group_tag.instantiate()
				graph.add_child(node)
				node.set_node_data(quest_res.graph_data[i])
				node.set_data(quest_res.groups[i])
			EditorNode.Type.END_NODE:
				node = end.instantiate()
				graph.add_child(node)
				node.set_node_data(quest_res.graph_data[i])
	
	
	for con in quest_res.connections_list:
		_on_graph_edit_connection_request(con.from,con.from_port,con.to,con.to_port)

func clear_graph():
	graph.clear_connections()
	for node in graph.get_children():
		if node is GraphNode:
			node.free()

func _on_open_file_file_selected(path):
	load_data(path)

func _on_save_file_file_selected(path):
	save_data(path)

func _on_right_mouse_list_focus_exited():
	right_mouse_popup.hide()

func _on_new_file_file_selected(path):
	save_new_file(path)

func _on_graph_edit_connection_from_empty(to_node, to_port, release_position):
	pass # Replace with function body.


func _on_graph_edit_connection_to_empty(from_node, from_port, release_position):
	pass
