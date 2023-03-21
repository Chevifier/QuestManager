@tool
extends Panel


signal failed()
signal updated(updated_to_version: String)

const CONFIG_PATH = "res://addons/quest_manager/plugin.cfg"
const TEMP_FILE_NAME = "user://temp.zip"

@onready var cfg = ConfigFile.new()

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var download_button: Button = %DownloadButton
var next_version:String


func _ready() -> void:
	update_ui()
	
func update_ui():
	cfg.load(CONFIG_PATH)
	next_version = cfg.get_value("plugin","new_version")
	var update_available = cfg.get_value("plugin","update_available","false")
	%label.text = "CURRENT VERSION: %s" % cfg.get_value("plugin","version")
	if update_available:
		%DownloadButton.text = " Download Update v%s" % cfg.get_value("plugin","new_version")
		%DownloadButton.disabled = false
		%PatchNotes.text = "v%s Patch Notes" % cfg.get_value("plugin","new_version")
	else:
		%DownloadButton.text = "Up To Date"
		%DownloadButton.disabled = true
		%PatchNotes.text = "v%s Patch Notes" % cfg.get_value("plugin","version")
	
	
	

func save_zip(bytes: PackedByteArray) -> void:
	var file: FileAccess = FileAccess.open(TEMP_FILE_NAME, FileAccess.WRITE)
	file.store_buffer(bytes)
	file.flush()

func _on_download_button_pressed() -> void:
	# Safeguard the actual dialogue manager repo from accidentally updating itself
	if FileAccess.file_exists("res://addons/quest_manager/extras/test.gd"): 
		prints("You can't update the dialogue manager from within itself.")
		return
	if cfg.get_value("plugin","update_available") == "true":
		
		%DownloadButton.disabled = true
		%DownloadButton.text = "Updating..."
		http_request.request("https://github.com/Chevifier/QuestManager/archive/refs/tags/v%s.zip" % next_version)
	else:
		%DownloadButton.disabled = true
		%DownloadButton.text = "Up To Date"


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS: 
		emit_signal("failed")
		print("update failed")
		return
	
	# Save the downloaded zip
	save_zip(body)
	
	if DirAccess.dir_exists_absolute("res://addons/quest_manager"):
		DirAccess.remove_absolute("res://addons/quest_manager")
	
	var zip_reader: ZIPReader = ZIPReader.new()
	zip_reader.open(TEMP_FILE_NAME)
	var files: PackedStringArray = zip_reader.get_files()
	
	var base_path = files[1]
	
	for path in files:
		print(path)

	for path in files:
		var new_file_path: String = path.replace(base_path, "")
		if path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute("res://addons/%s" % new_file_path)
		else:
			var file: FileAccess = FileAccess.open("res://addons/%s" % new_file_path, FileAccess.WRITE)
			file.store_buffer(zip_reader.read_file(path))

	zip_reader.close()
	
	#DirAccess.remove_absolute(TEMP_FILE_NAME)

	#restart
	get_parent().editor_plugin.get_editor_interface().restart_editor(true)


func _on_patch_notes_pressed():
	OS.shell_open("https://github.com/Chevifier/QuestManager/releases/tag/v%s" % next_version)
	

func _on_cancel_pressed():
	hide()

func _on_update_update_available():
	update_ui()
