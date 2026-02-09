extends Node
class_name LJM

# File path for storing users
var users_file: String = "user://users.json"
var PATH_JSON_DATA = "res://Data/users.json"
var WEB_PATH = "Data/users.json"

var users_data: Array = []

var passHasher = PassHasher.new()
var jsonLoader = json_loader.new()

signal users_ready
signal  user_created(success)

var upload_endpoint := "save_user.php"



func _ready() -> void:
	add_child(jsonLoader)
	jsonLoader.data_ready.connect()

func _on_users_loaded(data: Array):
	if data.size() > 0:
		# Web or res:// data becomes master
		users_data = data
	else:
		# If both web AND res failed → try user:// backup
		load_local_backup()

	emit_signal("users_ready")


func load_local_backup() -> void:
	if FileAccess.file_exists(users_file):
		var file := FileAccess.open(users_file, FileAccess.READ)
		var json_result = JSON.parse_string(file.get_as_text())

		if json_result != null:
			users_data = json_result
		else:
			users_data = []

		file.close()
	else:
		users_data = []

func _login_json(username: String, password: String, callback: Callable) -> void:

	# Wait until JSON data is ready
	await users_ready

	var user = get_user(username)

	if user.is_empty():
		callback.call({"error": "User not found"}, 401)
		return

	var salt = user["salt"]
	var hashed = passHasher.HashPassword(password, salt)

	if hashed == user["hashedPassword"]:
		callback.call({
			"user_id": user["id"],
			"role": user["role"]
		}, 200)
	else:
		callback.call({"error": "Invalid password"}, 401)


# Load users from JSON file, or create defaults if none exists
func load_users() -> void:
	jsonLoader.load_json(PATH_JSON_DATA,WEB_PATH)
	if FileAccess.file_exists(users_file):
		var file := FileAccess.open(users_file, FileAccess.READ)
		var json_result = JSON.parse_string(file.get_as_text())
		users_data = json_result
		file.close()
	else:
		users_data = []

func save_users_local():
	var file = FileAccess.open(users_file, FileAccess.WRITE)
	var json = JSON.stringify(users_data)
	
	file.store_string(json)
	file.close()
	

func _register_json(username: String, hashed: String, salt: String, callback: Callable) -> void:

	await users_ready

	if not get_user(username).is_empty():
		callback.call({"error": "User already exists"}, 400)
		return

	add_user(username, hashed, salt, "player")

	callback.call({
		"user_id": get_user(username)["id"]
	}, 200)


# Add a new user
func add_user(name: String, hashed_password: String, salt: String, role: String = "player") -> void:
	var id = users_data[-1]["id"] + 1 if users_data.size() > 0 else 1
	var new_user = {
		"id": id,
		"name": name,
		"hashedPassword": hashed_password,
		"salt": salt,
		"role": role
	}
	users_data.append(new_user)
	
	if OS.has_feature("web"):
		upload_user_to_web(new_user)
	else:
		save_users_local()
		emit_signal("user_created", true)

func upload_user_to_web(user:Dictionary) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	
	http.request_completed.connect(_on_user_uploaded)
	
	var body = JSON.stringify(user)
	var headers = ["Content-Type: application/json"]
	
	var url = jsonLoader.get_web_base() + upload_endpoint
	http.request(url,headers,HTTPClient.METHOD_POST,body)

func _on_user_uploaded(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		emit_signal("user_created", true)
	else:
		# Fallback → save locally if web failed
		save_users_local()
		emit_signal("user_created", false)



# Get a user by username
func get_user(username: String) -> Dictionary:
	for u in users_data:
		if u["name"] == username:
			return u
	return {}

# Verify login credentials
func verify_login(username: String, password_hash: String) -> bool:
	var u = get_user(username)
	if u.empty():
		return false
	return u["hashedPassword"] == password_hash

# Optional: Get role of user
func get_role(username: String) -> String:
	var u = get_user(username)
	if u.empty():
		return ""
	return u["role"]
