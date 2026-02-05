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
	sam.login(Username, Password, _on_login_response)

# Handle login response
func _on_login_response(data, response_code):
	print("Login response code:", response_code)
	print("Raw response data:", data)

	if response_code != 200 or data == null:
		var msg = data != null and str(data.get("error","Unknown error")) or "No response"
		ErrorLabel.show_error("Login failed: %s" % msg)
		return

	user_id = data["id"]
	#emit_signal("login_success", user_id)
	_go_to_next_scene()




	

func _go_to_next_scene():
	get_tree().change_scene_to_packed(next_scene)

func createUser(username,password):
	
	print("Creating user " + username)
	sam.register(username,password,_on_register_response)
	#var salt = passHasher.GenerateSalt()
	#var hashedPassword = passHasher.HashPassword(password,salt)
	#ljm.add_user(username,hashedPassword,salt)

func _on_register_response(data, response_code):
	if response_code != 200 or data == null or not data.has("id"):
		ErrorLabel.show_error("Registration failed")
		return
	print("User registered with ID:", data["id"])





#func _check_user_information(username, password):
	## Dev backdoor
	#if DevMode.DevModeEnabled:
		#if username == "DEVELOPER" and password == "C4PGEM1N!":
			#return true
#
	#var login_response = sam.login(username, password)
#
	#if login_response != null and login_response.has("user_id"):
		#print("Login successful for user:", username)
		#return true
	#else:
		#ErrorLabel.show_error("Login Failed, invalid username or password")
		#return false



func _on_create_user_pressed() -> void:
	_get_TextBox_Values()
	createUser(Username,Password)
