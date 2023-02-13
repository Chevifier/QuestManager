extends Control


func _ready():
	var quest_path = ProjectSettings.get_setting("quest_file_path","Error")
	assert(quest_path != "Error","Path Not Set")
	var quest:QuestResource = ResourceLoader.load(quest_path)

	QuestManager.load_quest_resource(quest)
	print(QuestManager.get_quest_list())
