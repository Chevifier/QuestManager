@tool
extends Control
signal data_saved()
@onready var quest_node = preload("res://addons/quest_manager/Editor/Nodes/Quest.tscn")
@onready var step = preload("res://addons/quest_manager/Editor/Nodes/Step.tscn")
@onready var inc_step = preload("res://addons/quest_manager/Editor/Nodes/IncrementalStep.tscn")
@onready var item_step = preload("res://addons/quest_manager/Editor/Nodes/items_step.tscn")
@onready var group_tag = preload("res://addons/quest_manager/Editor/Nodes/Group.tscn")
@onready var meta_data = preload("res://addons/quest_manager/Editor/Nodes/Meta_data.tscn")
@onready var timer_step = preload("res://addons/quest_manager/Editor/Nodes/Timer_Step.tscn")
@onready var end = preload("res://addons/quest_manager/Editor/Nodes/End.tscn")
@onready var rewards = preload("res://addons/quest_manager/Editor/Nodes/Quest_Rewards.tscn")
@onready var branch = preload("res://addons/quest_manager/Editor/Nodes/Branch.tscn")
@onready var callable_node = preload("res://addons/quest_manager/Editor/Nodes/Callable_Step.tscn")
var node_offset = Vector2(0,0)
var selected_node = null
var new_copy = null


@onready var new_btn = %New
@onready var save_btn = %Save
@onready var load_btn = %Load
@onready var graph : GraphEdit = %GraphEdit
@onready var context_menu = %MenuButton
@onready var test_btn = %test
@onready var update_btn = %update
@onready var rightmousemenu = preload("res://addons/quest_manager/Editor/right_mouse_menu.tscn")

#Check to see if all quest are properly structured
#Used for sending warning after save
var quest_chains_complete = false
var quest_name_duplicate = false
var editor_plugin: EditorPlugin
const test_scene_path = "res://addons/quest_manager/Editor/TestScene.tscn"
var popup_options_list =[
	"Add Quest",
	"Add Step",
	"Add Incremental Step",
	"Add Item Step",
	"Add Group Tag",
	"Add Meta Data",
	"Add Timer",
	"Add End Node",
	"Add Rewards Node",
	"Add Branch Node",
	"Add Callable Node"
]
func _ready():
	set_button_icons()
	%right_mouse_list.clear()
	%right_mouse_list.index_pressed.connect(_on_context_menu_index_pressed)
	context_menu.get_popup().clear()
	for item in popup_options_list:
		%right_mouse_list.add_item(item)
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
	update_btn.icon = get_theme_icon("Reload", "EditorIcons")
	context_menu.icon = get_theme_icon("RichTextEffect", "EditorIcons")
	context_menu.tooltip_text = "Add Node..."

func _on_save_pressed(index):
	match index:
		0:
			if ResourceLoader.exists(%QuestManagerSaveSystem.current_file_path):
				%QuestManagerSaveSystem.save_data(%QuestManagerSaveSystem.current_file_path)
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
			node = timer_step.instantiate()
		7:
			node = end.instantiate()
		8: 
			node = rewards.instantiate()
		9:
			node = branch.instantiate()
		10:
			node = callable_node.instantiate()
	if node == null:
		print("Node instance Error, Check Index")
		return
	
	graph.add_child(node)
	node.owner = graph
	node.show_id(%show_ids.button_pressed)
	node.set_position_offset(graph.scroll_offset+node_offset)
	node_offset += Vector2(50,50)
	if node_offset.x > 400:
		node_offset = Vector2()


func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
	var from = get_connection_node(from_node)
	var to = get_connection_node(to_node)
	#Prevent multiple connections to same port
	for connection in graph.get_connection_list():
		if to.Node_Type == EditorNode.Type.END_NODE:
			#prevent multiple Quest from connecting to same end node
			if to.quest_id != "" and from.quest_id  != to.quest_id:
				return
			#Allow multiple connections to end node
			to.add_node()
			break
		if connection.to_node == to_node and connection.to_port == to_port:
			return
		if connection.from_node == from_node and connection.from_port == from_port:
			return
	match from.Node_Type:
		EditorNode.Type.GROUP_NODE:
			to.group_node = from
			from.output_node = to
		EditorNode.Type.META_DATA:
			to.meta_data_node = from
			from.output_node = to
		EditorNode.Type.REWARDS_NODE:
			to.quest_rewards_node = from
			from.output_node = to
		EditorNode.Type.BRANCH_NODE:
			if from_port == 1: # second output
				from.alt_output_node = to
				from.branch_step_id = to.id
			elif from_port == 0: #otherwise connect
				from.output_node = to
				to.input_node = from
				from.next_id = to.name
			from.propagate_quest_id(from.quest_id);
		_:
			to.input_node = from
			from.output_node = to
			from.next_id = to.name
			from.propagate_quest_id(from.quest_id);

	graph.connect_node(from_node,from_port,to_node,to_port)
	#propagates quest id to output node if any
	#Check if from node is Group or Meta Data
	updateMetaDataAndGroup(to,from)
	

func updateMetaDataAndGroup(to,from):
	if Engine.is_editor_hint():
		return
	var quest_nodes = get_quest_nodes()
	if  from.Node_Type == EditorNode.Type.GROUP_NODE:
		to.group_node = from
	if from.Node_Type == EditorNode.Type.META_DATA:
		to.meta_data_node = from
	for quest in quest_nodes:
		quest.update_meta_data()
		quest.update_group_data()

#Pulls all data into Quest Nodes and return it for saving
func get_quests_data():
	var quest_data = {}
	var quest_nodes = get_quest_nodes()
	for quest in quest_nodes:
		quest.update_group_data()
		quest.update_meta_data()
		quest.update_quest_rewards()
		var steps = {}
		for node in graph.get_children():
			if node is EditorNode:
				if node.Node_Type != EditorNode.Type.QUEST_NODE:
					if node.quest_id == quest.id:
						steps[node.id] = node.get_data()
		quest.quest_steps = steps
		quest_data[quest.id] = quest.get_data()
	return quest_data
	
#Gets all Nodes that are Quests
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
	match from.Node_Type:
		EditorNode.Type.META_DATA:
			to.clear_meta_data()
		EditorNode.Type.GROUP_NODE:
			to.clear_group()
		EditorNode.Type.REWARDS_NODE:
			to.clear_rewards()
			#Only call clear id on None quest nodes
			if to.Node_Type != EditorNode.Type.QUEST_NODE:
				to.clear_quest_id()
	#special check on branch node
	if from.Node_Type == EditorNode.Type.BRANCH_NODE:
		if from_port == 1: # second output
			from.branch_step_id = ""
			from.alt_output_node = null
		elif from_port == 0:
			from.next_id = ""
			from.output_node = null
			to.input_node = null
	else:
		from.next_id = ""
		from.output_node = null
		to.input_node = null
	#Disconnect lines
	graph.disconnect_node(from_node,from_port,to_node,to_port)

func _on_graph_edit_popup_request(_position):
	%right_mouse_list.position = get_global_mouse_position() + Vector2(100,0)
	%right_mouse_list.popup()

#On Node option selected from context menu
func _on_context_menu_index_pressed(index):
	add_graph_node(index)

func _on_graph_edit_node_selected(node):
	selected_node = node

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
		if connection.to_node == node.name or connection.from_node == node.name:
			graph.disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)

#retreive editor data for saving
func get_editor_data():
	var editor_data = {}
	for node in graph.get_children():
		if node is EditorNode:
			editor_data[node.name] = node.get_data()
	editor_data["connections_list"] = graph.get_connection_list()
	return editor_data

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
	%QuestManagerSaveSystem.load_data(path)

func _on_save_file_file_selected(path):
	%QuestManagerSaveSystem.save_data(path)

func _on_new_file_file_selected(path):
	%QuestManagerSaveSystem.save_new_file(path)
	

func _on_graph_edit_connection_from_empty(to_node, to_port, release_position):
	#TO-DO context sensitive node menu
	pass

func _on_graph_edit_connection_to_empty(from_node, from_port, release_position):
	#TO-DO context sensitive node menu
	pass

func reimport_saved_file(save_file):
	EditorInterface.get_resource_filesystem().scan_sources()

func _on_graph_edit_mouse_exited():
	for node in get_all_nodes():
		node.release_all_focus()

func _on_test_button_pressed():
	_on_save_pressed(0)
	if %QuestManagerSaveSystem.current_file_path == "":
		return
	ProjectSettings.set_setting("quest_file_path",%QuestManagerSaveSystem.current_file_path)
	ProjectSettings.save()
	EditorInterface.play_custom_scene(test_scene_path)

#copy selected node data
func _on_graph_edit_copy_nodes_request():
	if selected_node != null:
		var tip = selected_node.get_child(selected_node.get_child_count()-1)
		if tip is PopupPanel:
			tip.free()
		new_copy = selected_node.duplicate()

#Paste duplicate node
func _on_graph_edit_paste_nodes_request():
	if new_copy != null:
		graph.add_child(new_copy)
		new_copy.position_offset += Vector2(10,10)
		graph.set_selected(new_copy)
		
func _on_graph_edit_duplicate_nodes_request():
	_on_graph_edit_copy_nodes_request()
	_on_graph_edit_paste_nodes_request()

func _on_graph_edit_gui_input(event):
	if event is InputEventMouseButton:
		node_offset = graph.get_local_mouse_position()

func _on_show_ids_toggled(button_pressed):
	for node in graph.get_children():
		if node is EditorNode:
			node.show_id(button_pressed)
	#workaround to redraw connections
	graph.scroll_offset.x += 0.01
