@tool
extends EditorNode

@onready var data_container = %data
@onready var string_meta = %String
@onready var integer_meta = %Integer
@onready var float_meta = %Float
@onready var bool_meta = %Bool

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
		data[meta_name] = meta_value

	return data
	

func set_data(data):
	return
	for meta in data:
		var meta_node
		if typeof(data[meta]) == TYPE_STRING:
			meta_node = string_meta.duplicate()
			data_container.add_child(meta_node)
			meta_node.get_node("name").text = meta
			meta_node.get_node("data").value = data[meta]
		if typeof(data[meta]) == TYPE_INT:
			meta_node = integer_meta.duplicate()
			data_container.add_child(meta_node)
			meta_node.get_node("name").text = meta
			meta_node.get_node("data").value = data[meta]
		elif typeof(data[meta]) == TYPE_FLOAT:
			meta_node = float_meta.duplicate()
			data_container.add_child(meta_node)
			meta_node.get_node("name").text = meta
			meta_node.get_node("data").value = data[meta]
		elif typeof(data[meta]) == TYPE_BOOL:
			meta_node = bool_meta.duplicate()
			data_container.add_child(meta_node)
			meta_node.get_node("name").text = meta
			meta_node.get_node("data").value = data[meta]
		meta_node.get_node("delete").pressed.connect(delete_meta_data.bind(meta_node.get_path()))

func delete_meta_data(node_path):
	data_container.get_node(node_path).queue_free()
	
func _on_string_pressed():
	var s = string_meta.duplicate()
	data_container.add_child(s)
	s.get_node("delete").pressed.connect(delete_meta_data.bind(s.get_path()))

func _on_int_pressed():
	var i = integer_meta.duplicate()
	data_container.add_child(i)
	i.get_node("delete").pressed.connect(delete_meta_data.bind(i.get_path()))
	

func _on_float_pressed():
	var f = float_meta.duplicate()
	data_container.add_child(f)
	f.get_node("delete").pressed.connect(delete_meta_data.bind(f.get_path()))

func _on_bool_pressed():
	var b = bool_meta.duplicate()
	data_container.add_child(b)
	b.get_node("delete").pressed.connect(delete_meta_data.bind(b.get_path()))

