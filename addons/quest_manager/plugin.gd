@tool
extends EditorPlugin


var editor_window_scene = preload("res://addons/quest_manager/Editor/EditorWindow.tscn")
var quest_manager

var quest_importer

var EditorWindow

func _enter_tree():
	add_autoload_singleton("QuestManager", "res://addons/quest_manager/QuestManager.gd")
	EditorWindow = editor_window_scene.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(EditorWindow)
	quest_importer = preload("res://addons/quest_manager/ImportPlugin.gd").new()
	add_import_plugin(quest_importer)
	_make_visible(false)
	EditorWindow.editor_plugin = self
	
func _edit(object):
	if is_instance_valid(EditorWindow) and is_instance_valid(object):
		EditorWindow.get_node("QuestManagerSaveSystem").load_data(object.resource_path)
		
func _handles(object):
	return object is QuestResource
	
func _has_main_screen():
	return true

func _input(event: InputEvent) -> void:
	if not EditorWindow.visible:
		return
	if event is InputEventKey and event.is_pressed():
		match event.as_text():
			"Ctrl+S":
				EditorWindow._on_save_pressed(0)

func _get_plugin_name():
	return "Quest Manager"

func _make_visible(visible):
	if EditorWindow:
		EditorWindow.visible = visible
	
func _get_plugin_icon():
	return get_icon()

func get_icon(scale: float = 1.0) -> Texture2D:
	var size: Vector2 = Vector2(16, 16) * get_editor_interface().get_editor_scale() * scale
	#var base_color: Color = get_editor_interface().get_editor_main_screen().get_theme_color("base_color", "Editor")
	#var light_theme = true if base_color.v > 0.5 else false
	var base_icon: Texture2D = load("res://addons/quest_manager/assets/icons/icon.png")
	var image: Image = base_icon.get_image()
	
	image.resize(size.x, size.y, Image.INTERPOLATE_TRILINEAR)
	return ImageTexture.create_from_image(image)

func _exit_tree():
	if EditorWindow:
		EditorWindow.queue_free()
	remove_autoload_singleton("QuestManager")
	remove_import_plugin(quest_importer)
	quest_importer = null
