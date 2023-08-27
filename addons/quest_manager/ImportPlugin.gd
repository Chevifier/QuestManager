@tool
extends EditorImportPlugin

enum Presets { DEFAULT }

func _get_importer_name():
	return "quest_importer"
	
func _get_import_options(path, preset_index):
	return []
	
func _get_option_visibility(path,option, options):
	return true
	
func _get_visible_name():
	return "Quest File"
	
func _get_priority():
	return 1.0
	
func _get_import_order():
	return 0
	
func _get_recognized_extensions():
	return ["quest"] #Quest Manager file

func _get_save_extension():
	return "tres"
	
func _get_resource_type():
	return "Resource"

func _get_preset_count():
	return Presets.size()
	
func _get_preset_name(preset):
	match preset:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"


func _import(source_file, save_path, options, platform_variants, gen_files):
	var file = FileAccess.open(source_file,FileAccess.READ)
	var err = file.get_open_error()
	if err != OK:
		return err
	var quest_res = QuestResource.new()
	quest_res.quest_data = file.get_var()
	return ResourceSaver.save(quest_res, "%s.%s" % [save_path, _get_save_extension()])
	















