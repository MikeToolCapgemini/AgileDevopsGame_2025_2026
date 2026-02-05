extends Control


@export var UserNameField : LineEdit
@export var PasswordField : LineEdit
@export var CreateButton : Button

@export var next_scene : PackedScene

var Username : String
var Password : String
var user_id

#var ldm = LDM.new()
#var ljm = LJM.new()
var sam = SupabaseAuthManager.new()
var auth = VPSAuthManager.new()
var passHasher = PassHasher.new()

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		print("skipping login screen")
		_go_to_next_scene()


func _process(delta: float) -> void:
	if DevMode.DevModeEnabled:
		if Input.is_action_just_pressed("DevmodeC"):
			toggle_create_button()
	else:
		hide_create_button()
	

func hide_create_button():
	createVisible = false
	CreateButton.visible = false

var createVisible : bool = false
func toggle_create_button():
	createVisible = !createVisible
	CreateButton.visible = createVisible
	

func _get_TextBox_Values():
	Username = UserNameField.text
	Password = PasswordField.text
	Username = Username.strip_edges(true,true)
	Password = Password.strip_edges(true,true)


func _on_Login_pressed() -> void:
	_get_TextBox_Values()

	# Dev backdoor
	if DevMode.DevModeEnabled:
		if Username == "DEVELOPER" and Password == "C4PGEM1N!":
			_go_to_next_scene()
			return

	# Async login
	auth.login(Username, Password, _on_login_response)

func _on_login_response(data, response_code):
	print("=== LOGIN RESPONSE ===")
	print("HTTP response code:", response_code)
	print("Raw response data:", str(data))

	if response_code != 200:
		ErrorLabel.show_error("Login failed!\nCode: %d\nData: %s" % [response_code, str(data)])
		emit_signal("login_failed", str(data))
		return

	if data == null:
		ErrorLabel.show_error("Login failed! Response is null")
		emit_signal("login_failed", "Response is null")
		return

	# Check for ID in response (works for Supabase 'id' or VPS)
	if data.has("id"):
		user_id = data["id"]
		print("Login successful! User ID:", user_id)
		emit_signal("login_success", user_id)
		_go_to_next_scene()
		return

	# Optional: catch errors returned by VPS or Supabase
	if data.has("error"):
		ErrorLabel.show_error("Login failed! Error: %s" % str(data["error"]))
		emit_signal("login_failed", str(data["error"]))
		return

	# Fallback
	ErrorLabel.show_error("Login failed! Unexpected response: %s" % str(data))
	emit_signal("login_failed", str(data))





	

func _go_to_next_scene():
	get_tree().change_scene_to_packed(next_scene)

func createUser(username,password):
	
	print("Creating user " + username)
	auth.register(username,password,_on_register_response)
	#var salt = passHasher.GenerateSalt()
	#var hashedPassword = passHasher.HashPassword(password,salt)
	#ljm.add_user(username,hashedPassword,salt)

func _on_register_response(data, response_code):
	print("=== REGISTER RESPONSE ===")
	print("HTTP response code:", response_code)
	print("Raw response data:", str(data))

	if response_code != 200:
		ErrorLabel.show_error("Registration failed!\nCode: %d\nData: %s" % [response_code, str(data)])
		emit_signal("register_failed", str(data))
		return

	if data == null:
		ErrorLabel.show_error("Registration failed! Response is null")
		emit_signal("register_failed", "Response is null")
		return

	if data.has("user_id"):
		print("User registered! User ID:", data["user_id"])
		emit_signal("register_success", data["user_id"])
		return

	if data.has("id"):  # For VPS backend
		print("User registered! User ID:", data["id"])
		emit_signal("register_success", data["id"])
		return

	if data.has("error"):
		ErrorLabel.show_error("Registration failed! Error: %s" % str(data["error"]))
		emit_signal("register_failed", str(data["error"]))
		return

	# Fallback
	ErrorLabel.show_error("Registration failed! Unexpected response: %s" % str(data))
	emit_signal("register_failed", str(data))



func _on_create_user_pressed() -> void:
	_get_TextBox_Values()
	createUser(Username,Password)
