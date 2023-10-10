@tool
extends EditorNode

var nodes = 0

func add_node():
	nodes += 1

func propagate_quest_id(_id):
	if quest_id == "":
		super.propagate_quest_id(_id)


func clear_quest_id():
	nodes -= 1
	if nodes == 0:
		super.clear_quest_id()

func setup():
	super.setup()
	Node_Type = Type.END_NODE

func get_data():
	node_data["step_type"] = "end"
	node_data["details"] = "Complete"
	super.get_data()
	return node_data
	
func set_data(data):
	super.set_data(data)
