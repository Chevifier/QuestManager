@tool
extends Node

@onready var recents_btn = %recent_btn_template
@onready var recents_box = %recents_box
@onready var save_system = %QuestManagerSaveSystem
var recents = []

func _ready():
	reload_recents()
	
func reload_recents():
	for i in recents_box.get_children():
		i.queue_free()
	recents = ProjectSettings.get_setting("recent_projects",[])
	for path in recents:
		var btn = recents_btn.duplicate()
		recents_box.add_child(btn)
		btn.set_project_path(path)
		btn.show()
		btn.pressed.connect(project_selected.bind(btn.project_path))
		
func project_selected(path):
	save_system.load_data(path)

func add_recent(path):
	if recents.has(path) == false:
		#if path doesnt exist add it to front(most recent)
		recents.push_front(path)
	else:
		#if path exist move it to front(most recent)
		recents.erase(path)
		recents.push_front(path)
	ProjectSettings.set_setting("recent_projects",recents)
	ProjectSettings.save()
	reload_recents()

func _on_clear_recents_pressed():
	#clear config as well
	for i in recents_box.get_children():
		i.queue_free()
	recents = []
	ProjectSettings.set_setting("recent_projects",recents)
	ProjectSettings.save()

func _on_quest_manager_save_system_data_saved(path):
	add_recent(path)

func _on_quest_manager_save_system_data_loaded(path):
	add_recent(path)
