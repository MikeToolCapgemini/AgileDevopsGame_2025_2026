class_name save_overwrite_UI
extends Control

@export var titleTextField : RichTextLabel
var saveName : String
var saveData
var saveSystem : SaveSystem

func _show_overwrite_UI(system,savename,savedata):
	_set_overwrite_variables(system,savename,savedata)
	show()

func _set_overwrite_variables(system,savename,savedata):
	saveSystem = system
	saveName = savename
	saveData = savedata
	_set_overwrite_title(saveName)


func _set_overwrite_title(saveName : String):
	titleTextField.text = "A Save with the name '%s' already exists
	Do you want to replace it?" % saveName


func _on_yes_pressed() -> void:
	saveSystem.save_game_file(saveName,saveData,false)
	hide()


func _on_no_pressed() -> void:
	hide()
