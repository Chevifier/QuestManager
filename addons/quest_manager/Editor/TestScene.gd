extends Control


func _ready():
	var quest_path = ProjectSettings.get_setting("quest_file_path","Error")
	assert(quest_path != "Error","Path Not Set")
	if ResourceLoader.exists(quest_path):
		var quest:QuestResource = ResourceLoader.load(quest_path)
		QuestManager.load_quest_resource(quest)
		print(QuestManager.get_quest_list())
	else:
		print("Quest File Not found")
