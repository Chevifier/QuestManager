class_name ItemCollect2D extends Node
#add as child of items that require collection in quest

@export var quest_name:String = ""
@export var name_as_id := false
@export var item_name = ""
@export var item_quantity := 1

func _ready() -> void:
	add_to_group("qm_items")

func _on_item_collected():
	if quest_name == "":
		return
	
		
