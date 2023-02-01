extends CanvasLayer
@export var Quest: Resource

@onready var quest_name_list = %QuestList

func _ready():
	print(QuestManager.get_quest("It Begins"))
	#var action = %Action_Step.duplicate()
	#var inc = %Inc_Step.duplicate()
	#var items_step = %Items_Step.duplicate()
	pass
