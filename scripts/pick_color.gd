extends Button


@export var mainPanel : Control
@export var PlayerColor : String

func _on_pressed() -> void:
	PlayerSettings.color = PlayerColor
	PlayerSettings.rpc("notify_players_updated")
	mainPanel.hide()
