@tool
extends Button

var project_path = "test"

func set_project_path(path:String):
	tooltip_text= path
	project_path = path
	var p = path.rsplit("/")
	p = p[-1].rsplit(".")
	text = p[0]
