extends Control


@export var UserNameField : LineEdit
@export var PasswordField : LineEdit
@export var CreateButton : Button

@export var next_scene : PackedScene

var Username : String
var Password : String

var ldm = LDM.new()
var ljm = LJM.new()
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
	var isCorrect = _check_user_information(Username,Password)
	if isCorrect:
		_go_to_next_scene()
	

func _go_to_next_scene():
	get_tree().change_scene_to_packed(next_scene)

func createUser(username,password):
	print("Creating user " + username)
	var salt = passHasher.GenerateSalt()
	var hashedPassword = passHasher.HashPassword(password,salt)
	ljm.add_user(username,hashedPassword,salt)



func _check_user_information(username,password):
	if DevMode.DevModeEnabled:
		if username == "DEVELOPER" && password == "C4PGEM1N!":
			return true
	var userData = ljm.get_user(username)
	
	if userData == null:
		ErrorLabel.show_error("Login Failed, invalid username")
		return false
	else:
		if userData["hashedPassword"] == passHasher.HashPassword(password,userData["salt"]):
			print(userData)
			return true
		else:
			ErrorLabel.show_error("Login Failed, invalid password")
			return false


func _on_create_user_pressed() -> void:
	_get_TextBox_Values()
	createUser(Username,Password)
