extends Node2D

#This is for function call step
func _ready():
	var regex = RegEx.new()
	var st :String = "TestAutoLoad.print_text()"
	#split function from autoload script name
	var autofuncsplit = st.split(".")
	var singleton_name = autofuncsplit[0]
	var function :String= autofuncsplit[1]
	#get only function name without ()
	var callable = function.split("(")[0]
	#TestAutoLoad.call(callable)
	var auto_load = get_tree().root.get_node(singleton_name)
	auto_load.call(callable)


func function():
	print("Hello World")
	RenderingServer
