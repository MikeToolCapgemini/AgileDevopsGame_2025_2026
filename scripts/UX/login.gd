extends Control
class_name  Login_Manager

@export var UserNameField : LineEdit
@export var PasswordField : LineEdit
@export var CreateButton : Button

@export var logoutButton : Button
@export var mainPanel : CanvasLayer

@export var next_scene : PackedScene
var nextActiveScene

var Username : String
var Password : String
var user_id

#var ldm = LDM.new()
#var ljm = LJM.new()
#var sam = SupabaseAuthManager.new()
var auth = VPSAuthManager.new()
var passHasher = PassHasher.new()
var tokenmanager = WebTokenManager.new()

func _ready() -> void:
	add_child(auth)
	add_child(tokenmanager)
	GlobalSignals.logout.connect(_on_logout)
	GlobalSignals.show_logout_button.connect(show_logout_button)
	GlobalSignals.show_logout_button.emit(false)
	auth.login_success.connect(on_login_success)
	if OS.has_feature("web"):
		auth.users_ready.connect(auto_login)
	if OS.has_feature("dedicated_server"):
		print("skipping login screen")
		_go_to_next_scene()

func show_logout_button(visible):
	logoutButton.visible = visible

func auto_login():
	var result = tokenmanager.try_get_valid_token()

	if result.success:
		auth._login_using_token(result.username, tokenmanager)
		Username = result.username
	else:
		print("Auto login failed: ", result.reason)

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
		auth.login_success.emit(user_id)
		return

	# Optional: catch errors returned by VPS or Supabase
	if data.has("error"):
		ErrorLabel.show_error("Login failed! Error: %s" % str(data["error"]))
		emit_signal("login_failed", str(data["error"]))
		return

	# Fallback
	ErrorLabel.show_error("Login failed! Unexpected response: %s" % str(data))
	emit_signal("login_failed", str(data))


func on_login_success(userid,auto_logged_in : bool = false):
	user_id = userid
	if !auto_logged_in:
		var token = tokenmanager.generate_token(Username)
		tokenmanager.save_token_cookie(token)
	GlobalSignals.show_logout_button.emit(true)
	_go_to_next_scene()

func _go_to_next_scene():
	hide_login_UI()
	var scene = next_scene.instantiate()
	nextActiveScene = scene
	get_tree().root.add_child(scene)

func createUser(username,password):
	
	print("Creating user " + username)
	auth.register(username,password,_on_register_response)
	#var salt = passHasher.GenerateSalt()
	#var hashedPassword = passHasher.HashPassword(password,salt)
	#ljm.add_user(username,hashedPassword,salt)


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		print("Blocked by:", self.name)
		
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

func show_login_UI():
	mainPanel.show()
	

func hide_login_UI():
	mainPanel.hide()

func _on_create_user_pressed() -> void:
	_get_TextBox_Values()
	createUser(Username,Password)


func _on_logout():
	tokenmanager.clear_token_cookie()
	print("Logging out")
	if nextActiveScene != self:  # Make sure we don't remove the login manager
		nextActiveScene.queue_free()
	show_login_UI()

func _on_logout_button_pressed() -> void:
	GlobalSignals.logout.emit()
