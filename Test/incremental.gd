extends Control
signal item_collected(n)
@export var item_name = "Apple"
func _ready() -> void:
	#connect signal to quest manager item
	item_collected.connect(QuestManager.set_item_collected)
func _on_add_item_pressed() -> void:
	item_collected.emit(item_name)
