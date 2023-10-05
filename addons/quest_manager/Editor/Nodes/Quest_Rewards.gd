@tool
extends EditorNode

@onready var data_container = %data
@onready var string_meta = %String
@onready var integer_meta = %Integer
@onready var float_meta = %Float
@onready var bool_meta = %Bool
@onready var vec2 = %Vector2
@onready var vec3 = %Vector3


func setup():
	Node_Type = Type.REWARDS_NODE
	super.setup()
	%AddButton.get_popup().index_pressed.connect(_on_option_selected)

func get_data():
	var data = {}
	for node in data_container.get_children():
		var meta_name = node.get_node("name").text
		var meta_value
		if node.is_in_group("numerical"):
			meta_value = node.get_node("data").value
		if node.is_in_group("string"):
			meta_value = node.get_node("data").text
		if node.is_in_group("boolean"):
			meta_value = node.get_node("data").button_pressed
		if node.is_in_group("vector2"):
			var x = node.get_node("x").value
			var y = node.get_node("y").value
			meta_value = Vector2(x,y)
		if node.is_in_group("vector3"):
			var x = node.get_node("x").value
			var y = node.get_node("y").value
			var z = node.get_node("z").value
			meta_value = Vector3(x,y,z)
		data[meta_name] = meta_value
	node_data["rewards"] = data
	super.get_data()
	return node_data
	
func set_data(data):
	super.set_data(data)
	var rewards = data["rewards"]
	for meta in rewards:
		var meta_node
		match typeof(rewards[meta]):
			TYPE_STRING: meta_node = string_meta.duplicate()
			TYPE_INT: meta_node = integer_meta.duplicate()
			TYPE_FLOAT: meta_node = float_meta.duplicate()
			TYPE_BOOL: meta_node = bool_meta.duplicate()
			TYPE_VECTOR2: meta_node = vec2.duplicate()
			TYPE_VECTOR3: meta_node = vec3.duplicate()
		data_container.add_child(meta_node)
		meta_node.get_node("name").text = meta
		if typeof(rewards[meta]) == TYPE_STRING:
			meta_node.get_node("data").text = rewards[meta]
		elif typeof(rewards[meta]) == TYPE_VECTOR2:
			meta_node.get_node("x").value = data[meta].x
			meta_node.get_node("y").value = data[meta].y
		elif typeof(rewards[meta]) == TYPE_VECTOR3:
			meta_node.get_node("x").value = data[meta].x
			meta_node.get_node("y").value = data[meta].y
			meta_node.get_node("z").value = data[meta].z
		else:
			#int/float
			meta_node.get_node("data").value = rewards[meta]
		meta_node.get_node("delete").pressed.connect(delete_meta_data.bind(meta_node.get_path()))

func delete_meta_data(node_path):
	data_container.get_node(node_path).queue_free()
	

func _on_option_selected(index):
	var option
	match index:
		0: option = string_meta.duplicate()
		1: option = integer_meta.duplicate()
		2: option = float_meta.duplicate()
		3: option = bool_meta.duplicate()
		4: option = vec2.duplicate()
		5: option = vec3.duplicate()
	focus_nodes.append(option.get_node("name"))
	focus_nodes.append(option.get_node("data"))
	data_container.add_child(option)
	option.get_node("delete").pressed.connect(delete_meta_data.bind(option.get_path()))
