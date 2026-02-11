class_name save_overwrite_UI
extends Control

@export var titleTextField : RichTextLabel
var saveName : String
var saveData
var saveSystem : SaveSystem

@rpc("any_peer")
func _show_overwrite_UI(savename, savedata):
	_set_overwrite_variables(savename, savedata)
	show()

func _set_overwrite_variables(savename, savedata):
	saveName = savename
	saveData = savedata

	_set_overwrite_title(saveName)


func _set_overwrite_title(saveName : String):
	titleTextField.text = "A Save with the name '%s' already exists
	Do you want to replace it?" % saveName


func _on_yes_pressed() -> void:
	if multiplayer.is_server():
		saveSystem.save_game_file(saveName,saveData,1)
	else:
		saveSystem.rpc_id(1,"request_saving_game",saveName,saveData,multiplayer.get_unique_id(),false)
	hide()


func _on_no_pressed() -> void:
	hide()
