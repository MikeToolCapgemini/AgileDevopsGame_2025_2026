extends Node

@export var upload_url := "https://miketool.eu/devopsbookmark/upload.php"
@export var view_url := "https://miketool.eu/devopsbookmark"
@export var saveManager : SaveSystem 

var http: HTTPRequest

func _ready():
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)


func upload_save_and_open_page():
	saveManager.save_game()
	
	var save_path = saveManager.SavePath + saveManager.get_save_name() + ".json"
	
	if not FileAccess.open(save_path, FileAccess.READ):
		push_error("Save file not found: " + save_path)
	
	var file = FileAccess.open(save_path,FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	var headers = [
		"Content-Type: application/json"
	]
	
	print("Uploading save")
	http.request(
		upload_url,
		headers,
		HTTPClient.METHOD_POST,
		json_text
	)

func _on_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		push_error("Upload failed with code: %s" % response_code)
		return
	
	var response_text = body.get_string_from_utf8()
	var parsed = JSON.parse_string(response_text)
	
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("token"):
		push_error("Invalid server response")
		return
	
	var token = parsed["token"]
	print("Upload succesful, token:", token)
	
	var full_url = "%s?token=%s" % [view_url,token]
	OS.shell_open(full_url)
	
func _on_upload_button_pressed():
	upload_save_and_open_page()
