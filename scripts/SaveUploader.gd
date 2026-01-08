extends Node

@export var upload_url := "https://miketool.eu/devopsbookmark/upload.php"
@export var view_url := "https://miketool.eu/devopsbookmark"
@export var saveManager : SaveSystem 

@export var Upload_notification : Control

var pending_url := ""

var http: HTTPRequest

func _ready():
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)


func upload_save():
	var json_text = saveManager.get_save_json()
	
	var headers = [
		"Content-Type: application/json"
	]
	
	http.accept_gzip = false
	print("Uploading save")
	http.request(
		upload_url,
		headers,
		HTTPClient.METHOD_POST,
		json_text
	)

func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("HTTPRequest failed: %s" % result)
		return

	if response_code != 200:
		push_error("Upload failed with code: %s" % response_code)
		return

	var response_text = body.get_string_from_utf8().strip_edges()

	if response_text.is_empty():
		push_error("Empty server response")
		return

	var json := JSON.new()
	var err := json.parse(response_text)

	if err != OK:
		push_error("JSON parse error. Raw response:\n" + response_text)
		return

	var parsed = json.data

	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("token"):
		push_error("Invalid server response format")
		return

	var token = parsed["token"]
	print("Upload successful, token:", token)
	
	pending_url = "%s?token=%s" % [view_url, token]
	print("Upload successful, waiting for user action")
	Upload_notification.edit_text("Upload successful, token: " + token)
	Upload_notification.show()

func _on_open_page_button_pressed():
	if pending_url != "":
		OS.shell_open(pending_url)

	
func _on_upload_button_pressed():
	upload_save()
	
func _on_copy_link_button_pressed():
	if pending_url == "":
		return

	DisplayServer.clipboard_set(pending_url)
	saveManager.saveNotifText.text = "Save link copied to clipboard"
	saveManager.saveNotificationUI.show()
	print("Save link copied to clipboard")
