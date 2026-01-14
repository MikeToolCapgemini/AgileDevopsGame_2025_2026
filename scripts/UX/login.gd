extends Control


@export var UserNameField : LineEdit
@export var PasswordField : LineEdit

var Username : String
var Password : String

var ldm = LDM.new()
var passHasher = PassHasher.new()


func _get_TextBox_Values():
	Username = UserNameField.text
	Password = PasswordField.text
	Username = Username.strip_edges(true,true)
	Password = Password.strip_edges(true,true)


func _on_Login_pressed() -> void:
	_get_TextBox_Values()
	_check_user_information(Username,Password)
	

func createUser(username,password):
	var salt = passHasher.GenerateSalt()
	var hashedPassword = passHasher.HashPassword(password,salt)
	ldm.InsertUserData(username,hashedPassword,salt)



func _check_user_information(username,password):
	var userData = ldm.GetUserFromDB(username)
	
	if userData == null:
		ErrorLabel.show_error("Login Failed, invalid username")
	else:
		if userData["hashedPassword"] == passHasher.HashPassword(password,userData["salt"]):
			print(userData)
		else:
			ErrorLabel.show_error("Login Failed, invalid password")


func _on_create_user_pressed() -> void:
	_get_TextBox_Values()
	createUser(Username,Password)
