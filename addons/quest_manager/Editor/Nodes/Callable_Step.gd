extends EditorNode

@onready var callable = %callable

func set_data(data):
	callable.text = data["callable"]
	super.set_data(data)
	
	
func get_data():
	node_data["step_type"] = "function_call_step"
	node_data["callable"] = callable.text
	node_data["params"] = get_meta_data(true)
	node_data["complete"] = false
	super.get_data()
