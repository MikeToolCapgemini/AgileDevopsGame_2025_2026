extends Node

@export var upload_url := "https://miketool.eu/devopsbookmark/upload.php"
@export var view_url := "https://miketool.eu/devopsbookmark"
@export var saveManager : SaveSystem 
@export var MailInputField : LineEdit

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
		ErrorLabel.show_error("HTTPRequest failed: %s" % result)
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
	

func _on_send_mail_pressed():
	var mailadress := MailInputField.text
	send_email_via_client(mailadress)
	

# This function is called when the user presses the button
func send_email_via_client(user_email: String):
	# Basic validation
	if not user_email.contains("@") or not user_email.contains("."):
		push_error("Invalid email address")
		ErrorLabel.show_error("Invalid email address")
		return

	# Subject and body (with line breaks)
	var subject = "Your Devops Bookmark access link"
	var body = "Hello! %0D%0A%0D%0A
	Here is your access link to view your cards:" + pending_url + "%0D%0A%0D%0AThank you!"

	# Build the mailto: URL
	var mailto_url = "mailto:%s?subject=%s&body=%s" % [user_email, subject, body]

	# Open default email client
	OS.shell_open(mailto_url)
	
	
	


func send_email_request_trough_web(mailto):
	if not mailto.contains("@") or not mailto.contains("."):
		push_error("Invalid email address")
		ErrorLabel.show_error("Invalid email address")
		return
	
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_email_request_completed)

	var url = "https://miketool.eu/devopsbookmark/send_email.php"
	var headers = ["Content-Type: application/json"]

	var data = {
		"to": mailto,
		"subject": "Devops Website token adress",
		"message": pending_url
	}

	var err = http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(data)
	)
	
	if err != OK:
		push_error("HTTPRequest failed to start")
		ErrorLabel.show_error("HTTPRequest failed to start")
		
	
func _on_email_request_completed(result, response_code, headers, body):
	if response_code == 200:
		print("Email sent successfully")
	else:
		var failmsg = "Email failed:" + str(response_code) + body.get_string_from_utf8()
		print(failmsg)
		ErrorLabel.show_error(failmsg)
