extends Node

var DevModeEnabled : bool = false


func _process(delta: float) -> void:
	if Input.is_action_just_released("DevMode"):
		DevModeEnabled = !DevModeEnabled
		if DevModeEnabled:
			show_enable_notif()
		else:
			show_disable_notif()


func show_enable_notif():
	ErrorLabel.show_error("Devmode Enabled")

func show_disable_notif():
	ErrorLabel.show_error("Devmode Disabled")
