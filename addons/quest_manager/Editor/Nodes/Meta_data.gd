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
	super.setup()
	Node_Type = Type.META_DATA
	%AddButton.get_popup().index_pressed.connect(_on_option_selected)

#set is_function_param to true if you want an ordered array to be returnd
func get_data(is_function_params :bool= false):
	#Array for function parameter for callable Node
	var meta_data = {}
	var arr = [] 
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
		meta_data[meta_name] = meta_value
		#store only value in array if for a function call
		if is_function_params:
			arr.append(meta_value)
	meta_data["funcparams"] = arr
	node_data["meta_data"] = meta_data
	super.get_data()
	return node_data
	
func set_data(data):
	super.set_data(data)
	var user_data = data["meta_data"]
	for meta in user_data:
		#skip function params setting
		if meta == "funcparams":
			continue
		var meta_node
		match typeof(user_data[meta]):
			TYPE_STRING: meta_node = string_meta.duplicate()
			TYPE_INT: meta_node = integer_meta.duplicate()
			TYPE_FLOAT: meta_node = float_meta.duplicate()
			TYPE_BOOL: meta_node = bool_meta.duplicate()
			TYPE_VECTOR2: meta_node = vec2.duplicate()
			TYPE_VECTOR3: meta_node = vec3.duplicate()
		data_container.add_child(meta_node)
		meta_node.get_node("name").text = meta
		if typeof(user_data[meta]) == TYPE_STRING:
			meta_node.get_node("data").text = user_data[meta]
		elif typeof(user_data[meta]) == TYPE_VECTOR2:
			meta_node.get_node("x").value = user_data[meta].x
			meta_node.get_node("y").value = user_data[meta].y
		elif typeof(user_data[meta]) == TYPE_VECTOR3:
			meta_node.get_node("x").value = user_data[meta].x
			meta_node.get_node("y").value = user_data[meta].y
			meta_node.get_node("z").value = user_data[meta].z
		elif typeof(user_data[meta]) == TYPE_BOOL:
			meta_node.get_node("data").button_pressed = true #node_data[meta]
		else:
			#Integer/Float
			meta_node.get_node("data").value = user_data[meta]
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
	data_container.add_child(option)
	option.get_node("delete").pressed.connect(delete_meta_data.bind(option.get_path()))
