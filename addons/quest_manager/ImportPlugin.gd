@tool
extends EditorImportPlugin

func _get_importer_name():
	return "quest_importer"
	
func _get_import_options(path, preset_index):
	return [{}]
	
func _get_visible_name():
	return "Quest Importer"
	
func _get_priority():
	return 1.0
	
func _get_import_order():
	return 0
	
func _get_recognized_extensions():
	return ["qm"] #QuestManager file

func _get_save_extension():
	return "qm"
	
func _get_resource_type():
	return "Resource"
	
func _import(source_file, save_path, options, platform_variants, gen_files):
	pass


