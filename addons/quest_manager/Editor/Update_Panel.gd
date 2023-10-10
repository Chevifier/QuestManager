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

func save_zip(bytes: PackedByteArray) -> void:
	var file: FileAccess = FileAccess.open(TEMP_FILE_NAME, FileAccess.WRITE)
	file.store_buffer(bytes)
	file.flush()

func _on_download_button_pressed() -> void:
	if not Engine.is_editor_hint():
		print("Updating from running the editor window can cause \
		data loss. Cancelling...")
		return
	%DownloadButton.disabled = true
	%DownloadButton.text = "Updating..."
	http_request.request("https://github.com/Chevifier/QuestManager/archive/refs/tags/v%s.zip" % next_version)
	


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS: 
		emit_signal("failed")
		print("update failed")
		%DownloadButton.disabled = false
		%DownloadButton.text = "Retry Update"
		return
	
	# Save the downloaded zip
	save_zip(body)
	
	if DirAccess.dir_exists_absolute("res://addons/quest_manager"):
		DirAccess.remove_absolute("res://addons/quest_manager")
	
	var zip_reader: ZIPReader = ZIPReader.new()
	zip_reader.open(TEMP_FILE_NAME)
	var files: PackedStringArray = zip_reader.get_files()
	
	var base_path = files[3]
	for path in files:
		if include_file(path):
			#print(path)
			var new_file_path: String = path.replace(base_path, "")
			if path.ends_with("/"): # create path
				DirAccess.make_dir_recursive_absolute("res://addons/%s" % new_file_path)
			else:
				# add file to path
				var file: FileAccess = FileAccess.open("res://addons/%s" % new_file_path, FileAccess.WRITE)
				file.store_buffer(zip_reader.read_file(path))
				
	
	zip_reader.close()
	%DownloadButton.text = "Restarting..."
	DirAccess.remove_absolute(TEMP_FILE_NAME)

	#restart
	get_parent().editor_plugin.get_editor_interface().restart_editor(true)

func _on_patch_notes_pressed():
	OS.shell_open("https://github.com/Chevifier/QuestManager/releases/tag/v%s" % next_version)

func _on_cancel_pressed():
	hide()

func include_file(path:String):
	return path.begins_with("QuestManager-%s/addons/" % next_version)
