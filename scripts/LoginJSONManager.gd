extends RefCounted
class_name LJM

# File path for storing users
var users_file: String = "user://users.json"
var users_data: Array = []
var passHasher = PassHasher.new()

func _init() -> void:
	load_users()

# Load users from JSON file, or create defaults if none exists
func load_users() -> void:
	if FileAccess.file_exists(users_file):
		var file := FileAccess.open(users_file, FileAccess.READ)
		var json_result = JSON.parse_string(file.get_as_text())
		if json_result.error == OK:
			users_data = json_result.result
		file.close()
	else:
		# Default accounts for small-scale setup
		users_data = []
		save_users()

func save_users():
	var file = FileAccess.open(users_file, FileAccess.WRITE)
	var json = JSON.stringify(users_data)
	
	file.store_string(json)
	file.close()
	

# Add a new user
func add_user(name: String, hashed_password: String, salt: String, role: String = "player") -> void:
	var id = users_data[-1]["id"] + 1 if users_data.size() > 0 else 1
	users_data.append({
		"id": id,
		"name": name,
		"hashedPassword": hashed_password,
		"salt": salt,
		"role": role
	})
	save_users()

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
