extends RefCounted
class_name SupabaseAuthManager

const SUPABASE_URL := "https://toudisnarpddnrqkykmo.supabase.co/functions/v1"
const SUPABASE_ANON_KEY := "sb_publishable_uCWRYRWqziLSBA5WGjYXcA_l5K8dvb0"

var access_token : String = ""
var user_id := -1

var _http := HTTPRequest.new()
var passHasher := PassHasher.new()

func _init() -> void:
	Engine.get_main_loop().root.add_child(_http)
	_http.request_completed.connect(_on_request_completed)
	
	
	
func login(username: String, password: String):
	var body = {
		"username" : username,
		"password" : password
	}
	
	_send_request_sync("login", body)

func register(username: String, password : String) -> void:
	print("registering user")
	var salt = passHasher.GenerateSalt()
	var hashed_password = passHasher.HashPassword(password,salt)
	var body = {
		"username" : username,
		"hashed_password" : hashed_password,
		"salt" : salt
	}
	
	_send_request_async("register",body)
	
	
func is_logged_in() -> bool:
	return access_token != ""


func get_user_id() -> int:
	return user_id

func _send_request_async(endpoint: String, body: Dictionary) -> void:
	print("sending Request")
	var headers = [
		"Content-Type: application/json",
		"apikey: %s" % SUPABASE_ANON_KEY
	]

	var json_body = JSON.stringify(body)
	_http.request(
		SUPABASE_URL + "/" + endpoint,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)
	
func _send_request_sync(endpoint: String, body: Dictionary) -> Dictionary:
	var done := false
	var result_data = null

	# Create a temporary HTTPRequest node
	var http := HTTPRequest.new()
	Engine.get_main_loop().root.add_child(http)

	# Connect completion signal
	http.request_completed.connect(func(result, response_code, headers, body_bytes):
		if response_code != 200:
			result_data = null
		else:
			result_data = JSON.parse_string(body_bytes.get_string_from_utf8())
		done = true
	)

	# Send request
	var headers = [
		"Content-Type: application/json",
		"apikey: %s" % SUPABASE_ANON_KEY
	]
	http.request(
		SUPABASE_URL + "/" + endpoint,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)

	# Wait until done
	while not done:
		OS.delay_msec(10)

	return result_data

	
func _on_request_completed(result, response_code, headers, body) -> void:
	if response_code != 200:
		print("Auth failed: %s" % body.get_string_from_utf8())
		ErrorLabel.show_error("Auth failed: %s" % body.get_string_from_utf8())
		return

	var data = JSON.parse_string(body.get_string_from_utf8())
	if data == null:
		print("Invalid auth response")
		ErrorLabel.show_error("Invalid auth response")
		return
	if data.has("user_id"):
		user_id = data["user_id"]
	if data.has("access_token"):
		access_token = data["access_token"]

	

#func _save_session() -> void:
	#JavaScriptBridge.eval("""
		#localStorage.setItem("sb_access_token", "%s");
		#localStorage.setItem("sb_user_id", "%s");
	#""" % [access_token, user_id])
#
	#
#func _load_session() -> void:
	#if not OS.has_feature("web"):
		#return
#
	#var token = JavaScriptBridge.eval("localStorage.getItem('sb_access_token');")
	#var uid = JavaScriptBridge.eval("localStorage.getItem('sb_user_id');")
#
	#if token and uid:
		#access_token = token
		#user_id = uid	
