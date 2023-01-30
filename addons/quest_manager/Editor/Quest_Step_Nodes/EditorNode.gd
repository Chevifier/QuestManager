@tool
class_name EditorNode
extends GraphNode
enum Type {
	QUEST_NODE,
	STEP_NODE,
	INCREMENTAL_NODE,
	ITEM_STEP_NODE,
	GROUP_NODE,
	META_DATA,
	END_NODE 
}

@export var Node_Type :Type = Type.QUEST_NODE
var node_data = {}
var input_node = null
var output_node = null
var id = ""
var data = {}
func _ready():
	close_request.connect(_on_close_request)
	resize_request.connect(_on_resize_request)
	slot_updated.connect(_on_slot_updated)
	node_selected.connect(_on_node_selected)
	node_deselected.connect(_on_node_deselected)
	dragged.connect(_on_node_dragged)
	position_offset_changed.connect(_on_position_offset_changed)
	raise_request.connect(_on_raise_request)
	id = get_random_id()
	print("ID: ",id)
	
func get_data():
	pass

func get_node_data():
	node_data["id"] = id
	node_data["name"] = name
	node_data["type"] = Node_Type
	node_data["position"] = position_offset
	return node_data
	
func set_node_data(data):
	id = data["id"]
	name = data["name"]
	Node_Type = data["type"]
	position_offset = data["position"]
	
func set_data(data):
	pass

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

func get_random_id() -> String:
	randomize()
	#seed(Time.get_unix_time_from_system())
	return str(randi() % 1000000).sha1_text().substr(0, 10)

