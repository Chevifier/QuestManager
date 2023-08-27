@tool
class_name QuestManagerSaveFileManager
extends Node
signal data_saved
var current_file_path = ""
@onready var Editor = get_parent()

func _ready():
	pass

func save_data(file_path):
	Editor.updateIdSteps()
	var Save = FileAccess.open(file_path,FileAccess.WRITE)
	Save.store_var(Editor.get_quest_data())
	current_file_path = file_path
	
	if Editor.quest_chains_complete == false:
		%Quest_Warning.popup_centered()
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
	
	for i in quest_res.quest_data:
		var node
		#skip connection list until all node are loaded
		if i == "connections_list":
			continue

		match quest_res.quest_data[i].type:
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
		Editor.graph.add_child(node)
		node.set_data(quest_res.quest_data[i])
	for con in quest_res.quest_data.connections_list:
		Editor._on_graph_edit_connection_request(con.from,con.from_port,con.to,con.to_port)

func save_new_file(file_path):
	var quest_res = QuestResource.new()
	ResourceSaver.save(quest_res,file_path)
	current_file_path = file_path
	data_saved.emit(file_path)
	Editor.clear_graph()
