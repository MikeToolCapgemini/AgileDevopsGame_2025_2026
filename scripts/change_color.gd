extends Button



@export var color_ui : select_color_ui

func _on_pressed() -> void:
	color_ui.show_ui()
