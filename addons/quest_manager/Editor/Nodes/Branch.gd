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
	node_data["step_type"]= "branch"
	node_data["details"]= details.text
	node_data["branch"]= false
	node_data["complete"]= false
	node_data["branch_step_id"]=branch_step_id # the step to jump if branching
	super.get_data()
	return node_data

func set_data(data):
	super.set_data(data)
	details.text = data["details"]

func _on_details_gui_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ENTER:
			details.release_focus()
