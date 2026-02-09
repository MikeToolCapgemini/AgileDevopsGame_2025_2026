extends RefCounted
class_name VPSAuthManager

# ---------------------------
# Backend config
# ---------------------------

enum Backend {
	SUPABASE,
	MYSQL,
	Json
}

@export var backend: Backend = Backend.SUPABASE

# Supabase
const SUPABASE_URL := "https://toudisnarpddnrqkykmo.supabase.co/functions/v1"
const SUPABASE_ANON_KEY := "sb_publishable_uCWRYRWqziLSBA5WGjYXcA_l5K8dvb0"

var jsonManager := LJM.new()

# VPS
const VPS_URL := "https://yourdomain.com"

# ---------------------------
# Runtime state
# ---------------------------

var access_token : String = ""
var user_id := -1
var _http := HTTPRequest.new()
var passHasher := PassHasher.new()

signal login_success(user_id)
signal login_failed(message)
signal register_success(user_id)
signal register_failed(message)

func _init() -> void:
	Engine.get_main_loop().root.add_child(_http)

# ---------------------------
# LOGIN
# ---------------------------

func login(username: String, password: String, callback: Callable) -> void:
	var body := {}
	var endpoint := ""

	match backend:
		Backend.Json:
			jsonManager._login_json(username,password,callback)
		
		Backend.SUPABASE:
			endpoint = "login"
			body = {
				"username": username,
				"password": password  # hashing is done server-side
			}
		Backend.MYSQL:
			endpoint = "login"
			body = {
				"username": username,
				"password": password
			}

	_send_request_async(endpoint, body, callback)



# ---------------------------
# REGISTER
# ---------------------------

func register(username: String, password: String, callback: Callable) -> void:
	var body := {}
	var endpoint := ""

	var salt = passHasher.GenerateSalt()
	var hashed_password = passHasher.HashPassword(password, salt)

	match backend:
		Backend.Json:
			jsonManager._register_json(username,hashed_password,salt,callback)
		
		Backend.SUPABASE:
			endpoint = "register"
			body = {
				"username": username,
				"hashed_password": hashed_password,
				"salt": salt
			}
		Backend.MYSQL:
			endpoint = "register"
			body = {
				"username": username,
				"hashed_password": hashed_password,
				"salt": salt
			}

	_send_request_async(endpoint, body, callback)

# ---------------------------
# HTTP REQUEST
# ---------------------------

func _send_request_async(endpoint: String, body: Dictionary, callback: Callable) -> void:
	var http := HTTPRequest.new()
	Engine.get_main_loop().root.add_child(http)

	http.request_completed.connect(func(result, response_code, headers, body_bytes):
		var data = null
		if body_bytes and body_bytes.size() > 0:
			data = JSON.parse_string(body_bytes.get_string_from_utf8())
		callback.call(data, response_code)
		http.queue_free()
	)

	var url := ""
	var headers := ["Content-Type: application/json"]

	match backend:
		Backend.SUPABASE:
			url = "%s/%s" % [SUPABASE_URL, endpoint]
			# anon key required for supabase
			headers.append("apikey: %s" % SUPABASE_ANON_KEY)
		Backend.MYSQL:
			url = "%s/%s" % [VPS_URL, endpoint]

	http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))

# ----------
