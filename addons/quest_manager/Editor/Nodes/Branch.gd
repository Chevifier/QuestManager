@tool
class_name Branch
extends EditorNode

@onready var details = %details

var branch_step_id = ""
var alt_output_node = null
enum Condition {
	GREATER_THAN,
	LESS_THAN,
	EQUAL_TO,
	NOT_EQUAL_TO
}

func setup():
	super.setup()
	Node_Type = Type.BRANCH_NODE
	focus_nodes.append(details)
	
func get_data():
	node_data["step_type"]= "branch_step"
	node_data["details"]= details.text
	node_data["branch"]= false
	node_data["complete"]= false
	node_data["branch_step_id"]=branch_step_id # the step to jump if branching
	node_data["meta_data"] = get_meta_data()
	super.get_data()
	return node_data


func propagate_quest_id(id):
	super.propagate_quest_id(id)
	if alt_output_node != null:
		alt_output_node.propagate_quest_id(id)
		
func clear_quest_id():
	super.clear_quest_id()
	alt_output_node.clear_quest_id()

func set_data(data):
	super.set_data(data)
	details.text = data["details"]

func _on_details_gui_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ENTER:
			details.release_focus()


