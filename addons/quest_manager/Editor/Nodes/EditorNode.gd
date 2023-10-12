@tool
class_name EditorNode
extends GraphNode
enum SLOTTYPE {
	STEP = 0,
	GROUP = 1,
	META_DATA = 2,
	REWARDS = 3
}

enum Type {
	QUEST_NODE,
	STEP_NODE,
	INCREMENTAL_NODE,
	ITEM_STEP_NODE,
	GROUP_NODE,
	META_DATA,
	END_NODE,
	TIMER_NODE,
	REWARDS_NODE,
	BRANCH_NODE,
	FUNCTION_CALL_NODE
}

var Node_Type : Type

var node_data :Dictionary= {}
var input_node :Node= null
var output_node :Node= null
var meta_data_node :Node= null
var id :String= ""
var next_id :String= ""
var quest_id :String= ""
var focus_nodes :Array[Node]= []
@onready var id_lbl = $id_lbl
func _ready():
	setup()
func show_id(vis:bool):
	id_lbl.visible = vis
	
func setup():
	delete_request.connect(_on_close_request)
	resize_request.connect(_on_resize_request)
	slot_updated.connect(_on_slot_updated)
	node_selected.connect(_on_node_selected)
	node_deselected.connect(_on_node_deselected)
	dragged.connect(_on_node_dragged)
	position_offset_changed.connect(_on_position_offset_changed)
	raise_request.connect(_on_raise_request)
	id = get_random_id()
	name = id
	id_lbl.text = id
	
func get_meta_data(func_params:bool = false):
	var data = {}
	if is_instance_valid(meta_data_node):
		data = meta_data_node.get_data(func_params)
		return data["meta_data"]
	else:
		data = {"funcparams":[]}
		return data
	
func get_data():
	node_data["id"] = id
	node_data["type"] = Node_Type
	node_data["position"] = position_offset
	node_data["size"] = size
	node_data["next_id"] = next_id
	return node_data
	
func set_data(data):
	id = data["id"]
	name = id
	Node_Type = data["type"]
	position_offset = data["position"]
	size = data["size"]
	id_lbl.text = id


#passes quest id to output node when a connection accures
func propagate_quest_id(_id):
	quest_id = _id
	if output_node != null:
		#failsafe avoid wiping quest Id from quest node
		if output_node.Node_Type != Type.QUEST_NODE:
			node_data["quest_id"]= quest_id
			output_node.propagate_quest_id(_id)

func clear_quest_id():
	quest_id = ""
	node_data["quest_id"]= quest_id
	if output_node != null:
		output_node.clear_quest_id()

func _on_node_selected():
	pass

func _on_node_deselected():
	pass

func _on_node_dragged(to,from):
	pass
	
func _on_position_offset_changed():
	pass

func _on_close_request():
	queue_free()

func _on_resize_request(new_minsize):
	set_size(new_minsize)

func _on_slot_updated(slot):
	pass
	
func _on_raise_request():
	pass

func release_all_focus():
	for node in focus_nodes:
		if node != null:
			node.release_focus()

func get_random_id() -> String:
	randomize()
	return str(randi() % 1000000).sha1_text().substr(0, 10)
	
func update_meta_data():
	if is_instance_valid(meta_data_node):
		node_data["meta_data"] = meta_data_node.get_data()
		

func clear_meta_data():
	node_data["meta_data"] = {}
	meta_data_node = null
