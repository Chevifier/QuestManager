@tool
class_name QuestManagerSaveFileManager
extends Node
signal data_saved
signal data_loaded
var current_file_path = ""
@onready var Editor = get_parent()

func _ready():
	pass

func save_data(file_path):
	var Save = FileAccess.open(file_path,FileAccess.WRITE)
	Save.store_var(Editor.get_quests_data())
	Save.store_var(Editor.get_editor_data())
	current_file_path = file_path

	if Editor.quest_name_duplicate == true:
		%Quest_Name_Warning.popup_centered()
		
	data_saved.emit(file_path)
	print("File saved %s" % file_path)

func load_data(file_path):
	var quest_res = ResourceLoader.load(file_path)
	current_file_path = file_path
	#clear the current nodes in the graph
	Editor.clear_graph()
	#load new node and set data from resource
	
	for i in quest_res.editor_data:
		var node
		#skip connection list until all node are loaded
		if i == "connections_list":
			continue

		match quest_res.editor_data[i].type:
			EditorNode.Type.QUEST_NODE:
				node = Editor.quest_node.instantiate()
			EditorNode.Type.STEP_NODE:
				node = Editor.step.instantiate()
			EditorNode.Type.INCREMENTAL_NODE:
				node = Editor.inc_step.instantiate()
			EditorNode.Type.ITEM_STEP_NODE:
				node = Editor.item_step.instantiate()
			EditorNode.Type.META_DATA:
				node = Editor.meta_data.instantiate()
			EditorNode.Type.GROUP_NODE:
				node = Editor.group_tag.instantiate()
			EditorNode.Type.END_NODE:
				node = Editor.end.instantiate()
			EditorNode.Type.TIMER_NODE:
				node = Editor.timer_step.instantiate()
			EditorNode.Type.REWARDS_NODE:
				node = Editor.rewards.instantiate()
			EditorNode.Type.BRANCH_NODE:
				node = Editor.branch.instantiate()
			EditorNode.Type.FUNCTION_CALL_NODE:
				node = Editor.callable_node.instantiate()
		Editor.graph.add_child(node)
		node.set_data(quest_res.editor_data[i])
		node.show_id(%show_ids.button_pressed)
	for con in quest_res.editor_data.connections_list:
		Editor._on_graph_edit_connection_request(con.from_node,con.from_port,con.to_node,con.to_port)
	data_loaded.emit(file_path)
	
func save_new_file(file_path):
	current_file_path = file_path
	var Save = FileAccess.open(file_path,FileAccess.WRITE)
	Save.store_var({})
	Save.store_var({})
	current_file_path = file_path
	data_saved.emit(file_path)
	Editor.clear_graph()
	
