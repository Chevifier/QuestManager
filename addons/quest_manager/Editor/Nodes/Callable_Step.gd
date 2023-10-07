@tool
extends EditorNode

@onready var callable = %callable


func setup():
	Node_Type = Type.FUNCTION_CALL_NODE
	focus_nodes.append(callable)
	super.setup()

func set_data(data):
	callable.text = data["callable"]
	super.set_data(data)
	
func get_data():
	node_data["step_type"] = "callable_step"
	node_data["details"] = callable.text
	node_data["callable"] = callable.text
	node_data["params"] = get_meta_data(true)
	node_data["complete"] = false
	super.get_data()
	return node_data
