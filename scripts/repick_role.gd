extends Button

@export var hideObject : Control
func on_repick():
	if hideObject.visible:
		hideObject.visible = false
		hideObject.mouse_filter = Control.MOUSE_FILTER_PASS
	else:
		hideObject.visible = true
	%Setup.visible = true
