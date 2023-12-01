@tool
extends Button
const GIT_REPO = "https://github.com/Chevifier/QuestManager/releases/latest"
const CONFIG_PATH = "res://addons/quest_manager/plugin.cfg"
const TEST_IMAGE = "https://github.com/Chevifier/QuestManager/blob/main/documentation/QuestManager.jpg?raw=true"
@onready var http_request : HTTPRequest = $HTTPRequest
@onready var cfg = ConfigFile.new()

func _ready():
	cfg.load(CONFIG_PATH)
	var error = http_request.request(GIT_REPO)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		return

func _on_http_request_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Error Checking for updates")
		return
	# Parse the version number from the remote config file
	var response = body.get_string_from_utf8()
	var regex = RegEx.create_from_string("/Chevifier/QuestManager/releases/tag/v(?<version>\\d+\\.\\d+\\.\\d+)")
	var found = regex.search(response)
	
	if not found: return
	var new_version = found.strings[found.names.get("version")]
	var current_version = cfg.get_value("plugin","version")
	if version_number(current_version) < version_number(new_version):
		text = new_version
		add_theme_color_override("font_color",Color.GREEN)
	else:
		text = current_version
		add_theme_color_override("font_color",Color.WHITE)

func version_number(version:String):
	var numsplit = version.split(".")
	return numsplit[0].to_int() * 1000 + numsplit[1].to_int() * 100 + numsplit[2].to_int()*10

func _on_pressed():
	OS.shell_open("https://github.com/Chevifier/QuestManager/releases/")
