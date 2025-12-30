extends Control

@export var cardManagerObject : Node
@export var bookmarkIcon : TextureRect

func _ready() -> void:
	bookmarkIcon.visible = false

@rpc("any_peer")
func toggle_bookmark_visuals(toggle):
	bookmarkIcon.visible = toggle
	self.visible = !toggle
	$"../CancelSave".visible = toggle
	

func _on_pressed():
	cardManagerObject.card_bookmark()
	cardManagerObject.card_bookmark.rpc()
	toggle_bookmark_visuals(true)
	toggle_bookmark_visuals.rpc(true)
	

func on_Cancel():
	show()
	$"../CancelSave".hide()
	cardManagerObject.card_cancel_bookmark()
	cardManagerObject.card_cancel_bookmark.rpc()
	toggle_bookmark_visuals(false)
	toggle_bookmark_visuals.rpc(false)
