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
	
	
	
signal login_success(user_id)
signal login_failed(message)

func login(username: String, password: String, callback: Callable) -> void:
	# Send raw password; hashing is done on the server
	var body = {
		"username": username,
		"password": password
	}

	_send_request_async("login", body, callback)





func register(username: String, password : String, callback: Callable) -> void:
	print("registering user")
	var salt = passHasher.GenerateSalt()
	var hashed_password = passHasher.HashPassword(password,salt)
	var body = {
		"username" : username,
		"hashed_password" : hashed_password,
		"salt" : salt
	}
	
	_send_request_async("register",body,callback)
	
	
func is_logged_in() -> bool:
	return access_token != ""


func get_user_id() -> int:
	return user_id

func _send_request_async(endpoint: String, body: Dictionary, callback: Callable) -> void:
	var http := HTTPRequest.new()
	Engine.get_main_loop().root.add_child(http)

	http.request_completed.connect(func(result, response_code, headers, body_bytes):
		var data = null
		if response_code == 200:
			data = JSON.parse_string(body_bytes.get_string_from_utf8())
		callback.call(data, response_code)
		http.queue_free()
	)
	var headers = ["Content-Type: application/json"]
	http.request(SUPABASE_URL + "/" + endpoint, headers, HTTPClient.METHOD_POST, JSON.stringify(body))


	
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
