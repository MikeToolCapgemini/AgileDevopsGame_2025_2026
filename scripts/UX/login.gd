extends Control


@export var UserNameField : LineEdit
@export var PasswordField : LineEdit

var Username : String
var Password : String

var ldm = LDM.new()


func _get_TextBox_Values():
	Username = UserNameField.text
	Password = PasswordField.text


func _on_Login_pressed() -> void:
	_get_TextBox_Values()
	_check_user_information(Username,Password)
	

func createUser(username,password):
	ldm.InsertUserData(username,password,131231)



func _check_user_information(username,password):
	var userData = ldm.GetUserFromDB(username)
	
	if userData == null:
		ErrorLabel.show_error("Login Failed, invalid username")
	else:
		if userData["hashedPassword"] == password:
			print(userData)
		else:
			ErrorLabel.show_error("Login Failed, invalid password")


func _on_create_user_pressed() -> void:
	_get_TextBox_Values()
	createUser(Username,Password)
