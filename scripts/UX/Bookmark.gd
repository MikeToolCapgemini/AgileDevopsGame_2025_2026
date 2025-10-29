extends Control

@export var cardManagerObject : Node
@export var bookmarkIcon : TextureRect


func _on_pressed():
	cardManagerObject.card_bookmark()
	hide()
	$"../CancelSave".show()
	bookmarkIcon.visible = true
	

func on_Cancel():
	show()
	$"../CancelSave".hide()
	bookmarkIcon.visible = false
	cardManagerObject.card_cancel_bookmark()
