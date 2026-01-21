extends Button


@export var mainPanel : Control
@export var PlayerColor : String

func _on_pressed() -> void:
	PlayerSettings.color = PlayerColor
	mainPanel.hide()
