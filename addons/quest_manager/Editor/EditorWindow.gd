@tool
extends Control
signal data_saved()
@onready var quest_node = preload("res://addons/quest_manager/Editor/Nodes/quest.tscn")
@onready var step = preload("res://addons/quest_manager/Editor/Nodes/Step.tscn")
@onready var inc_step = preload("res://addons/quest_manager/Editor/Nodes/IncrementalStep.tscn")
@onready var item_step = preload("res://addons/quest_manager/Editor/Nodes/items_step.tscn")
@onready var group_tag = preload("res://addons/quest_manager/Editor/Nodes/Group.tscn")
@onready var meta_data = preload("res://addons/quest_manager/Editor/Nodes/Meta_data.tscn")
@onready var end = preload("res://addons/quest_manager/Editor/Nodes/End.tscn")
var instance_position = Vector2(150,150)
var node_offset = Vector2(0,0)

@onready var new_btn = %New
@onready var save_btn = %Save
@onready var load_btn = %Load
@onready var graph : GraphEdit = %GraphEdit
@onready var context_menu = %MenuButton
@onready var test_btn = %Test
@onready var rightmousemenu = preload("res://addons/quest_manager/Editor/right_mouse_menu.tscn")

#Check to see if all quest are properly structured
#Used for sending warning after save
var quest_chains_complete = false
var quest_name_duplicate = false
var current_file_path = ""
var editor_plugin: EditorPlugin
var test_scene_path = "res://addons/quest_manager/Editor/Quest_File_Test_Scene.tscn"
var popup_options_list =[
	"Add Quest",
	"Add Step",
	"Add Incremental Step",
	"Add Item Step",
	"Add Group Tag",
	"Add Meta Data",
	"Add End Node"
]
var quest_data = {}
var graph_data = {}
func _ready():
	set_button_icons()
	%right_mouse_list.index_pressed.connect(_on_context_menu_index_pressed)
	context_menu.get_popup().clear()
	for item in popup_options_list:
		context_menu.get_popup().add_item(item)
	context_menu.get_popup().index_pressed.connect(_on_context_menu_index_pressed)
	save_btn.get_popup().index_pressed.connect(_on_save_pressed)
	
func setup_menu():
	for item in popup_options_list:
		context_menu.get_popup().add_item(item)
	context_menu.get_popup().index_pressed.connect(_on_context_menu_index_pressed)

func set_button_icons():
	new_btn.icon = get_theme_icon("New", "EditorIcons")
	save_btn.icon = get_theme_icon("Save", "EditorIcons")
	load_btn.icon = get_theme_icon("Load", "EditorIcons")
	test_btn.icon = get_theme_icon("PlayScene", "EditorIcons")
	test_btn.tooltip_text = "Test Quest File"
	context_menu.icon = get_theme_icon("RichTextEffect", "EditorIcons")
	context_menu.tooltip_text = "Add Node..."

func _on_save_pressed(index):
	match index:
		0:
			if ResourceLoader.exists(current_file_path):
				save_data(current_file_path)
			else:
				%Save_File.popup_centered_clamped(Vector2(300,300))
		1:
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
	node.set_position_offset(instance_position+graph.scroll_offset+node_offset)
	node_offset += Vector2(50,50)
	if node_offset.x > 400:
		node_offset = Vector2()
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
	quest_name_duplicate = hasDuplicateNames()
	
	for quest in quest_nodes:
		quest.update_group_data()
		quest.update_meta_data()
		var steps = []
		var current_node = quest.output_node
		var index = 0
		while current_node != null:
			quest_chains_complete = false
			
			if current_node.Node_Type == EditorNode.Type.END_NODE:
				quest_chains_complete = true
				break
			var data = current_node.get_data()
			data["index"] = index
			steps.append(data)
			index += 1
			current_node = current_node.output_node
		quest.steps = steps

#Check if quest has the same names
func hasDuplicateNames():
	var namesofar = []
	for quest in get_quest_nodes():
		var value = quest.get_data()["quest_name"];
		if value in namesofar:
			return true
		namesofar.append(value)
	return false
		
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

func _on_graph_edit_popup_request(_position):
	instance_position = _position
	%right_mouse_list.position = get_global_mouse_position() + Vector2(100,100)
	%right_mouse_list.popup()

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
	data_saved.emit(file_path)
	clear_graph()

#=============================SAVE DATA==============================
func save_data(file_path):
	updateIdSteps()

	var Save = FileAccess.open(file_path,FileAccess.WRITE)
	
	Save.store_var(get_quest_data())
	Save.store_var(get_editor_data())

	current_file_path = file_path
	if quest_chains_complete == false:
		$Quest_Warning.popup_centered()
	if quest_name_duplicate == true:
		$Quest_Name_Warning.popup_centered()
		
	data_saved.emit(file_path)
	print("File saved %s" % file_path)

func get_quest_data():
	var quest_data = {}
	for node in graph.get_children():
		if node is EditorNode:
			if node.Node_Type == EditorNode.Type.QUEST_NODE:
				quest_data[node.id] = node.get_data()
	return quest_data

func get_editor_data():
	var node_data = {}
	for node in graph.get_children():
		if node is EditorNode:
			node_data[node.id] = node.get_node_data()
			node_data[node.id]["quest_data"] = node.get_data()
			node_data["connections_list"] = graph.get_connection_list()
	return node_data

#=============================LOAD DATA================================

func load_data(file_path):
	var quest_res = ResourceLoader.load(file_path)
	current_file_path = file_path
	#clear the current nodes in the graph
	clear_graph()
	#load new node and set data from resource
	
	for i in quest_res.graph_data:
		var node
		if i == "connections_list":
			continue
		match quest_res.graph_data[i].type:
			EditorNode.Type.QUEST_NODE:
				node = quest_node.instantiate()
			EditorNode.Type.STEP_NODE:
				node = step.instantiate()
			EditorNode.Type.INCREMENTAL_NODE:
				node = inc_step.instantiate()
			EditorNode.Type.ITEM_STEP_NODE:
				node = item_step.instantiate()
			EditorNode.Type.META_DATA:
				node = meta_data.instantiate()
			EditorNode.Type.GROUP_NODE:
				node = group_tag.instantiate()
			EditorNode.Type.END_NODE:
				node = end.instantiate()
		graph.add_child(node)
		node.set_node_data(quest_res.graph_data[i])
		node.set_data(quest_res.graph_data[i]["quest_data"])
	for con in quest_res.graph_data.connections_list:
		_on_graph_edit_connection_request(con.from,con.from_port,con.to,con.to_port)

func clear_graph():
	graph.clear_connections()
	for node in graph.get_children():
		if node is GraphNode:
			node.free()
			
func get_all_nodes():
	var nodes=[]
	for node in graph.get_children():
		if node is GraphNode:
			nodes.append(node)
	return nodes

func _on_open_file_file_selected(path):
	load_data(path)

func _on_save_file_file_selected(path):
	save_data(path)

func _on_new_file_file_selected(path):
	save_new_file(path)

func _on_graph_edit_connection_from_empty(to_node, to_port, release_position):
	pass # Replace with function body.


func _on_graph_edit_connection_to_empty(from_node, from_port, release_position):
	pass


func _on_graph_edit_mouse_exited():
	for node in get_all_nodes():
		node.release_all_focus()


func _on_test_button_pressed():
	_on_save_pressed(0)
	if current_file_path == "":
		return
	ProjectSettings.set_setting("quest_file_path",current_file_path)
	ProjectSettings.save()
	editor_plugin.get_editor_interface().play_custom_scene(test_scene_path)
