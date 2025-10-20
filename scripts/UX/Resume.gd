extends Node

@export var hideObject : Control

func _on_pressed():
	if hideObject.visible:
		hideObject.visible = false
		hideObject.mouse_filter = Control.MOUSE_FILTER_PASS
	else:
		hideObject.visible = true
