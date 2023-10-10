extends Node2D
@export var dialogue := ""
@export var quest_resource : QuestResource
@export_enum("Father", "Mother", "Sister") var family_member = 0
var quest_name = "Meal for the Family"
var gave_quest = false
func _ready():
	match family_member:
		0:
			$Father.show()
		1:
			$Mother.show()
		2:
			$Sister.show()
	
func get_quest():
	if gave_quest == false:
		QuestManager.add_quest(quest_name,quest_resource)
		gave_quest = true
		

func get_family_member():
	return family_member
	
func give_pie():
	dialogue = "Thank You"

func get_dialogue(num = 0):
	match family_member:
		0:
			if num == 1:
				return "This is really good son"
		1:
			if num == 1:
				return "Thank you son, Its delicious"
		2:
			if num == 1:
				return "Yum Tasty"
	return dialogue
