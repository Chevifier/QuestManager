@tool
class_name Branch
extends EditorNode

@onready var details = %details
@onready var branch_condition = %branch_condition
@onready var item_name = %item_name
@onready var condition_value = %condition_value

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
	node_data["condition"]=branch_condition.selected
	node_data["item_name"]= item_name.text
	node_data["current_value"]= 0
	node_data["condition_value"]= condition_value.value
	node_data["branching"]= false
	node_data["complete"]= false
	node_data["branch_step_id"]=branch_step_id # the step to jump if branching
	super.get_data()
	return node_data

func set_data(data):
	super.set_data(data)
	details.text = data["details"]
	branch_condition.selected = data["condition"]
	item_name.text = data["item_name"]
	condition_value.value = data["condition_value"]

func _on_details_gui_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ENTER:
			details.release_focus()
