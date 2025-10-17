extends Node

@export var showObject : Control

func _on_pressed():
	if showObject.visible:
		showObject.visible = false
	else:
		showObject.visible = true
