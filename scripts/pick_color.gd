extends Button


@export var mainPanel : select_color_ui
@export var PlayerColor : String

func _on_pressed() -> void:
	PlayerSettings.color = PlayerColor
	PlayerSettings.rpc("set_player_color",multiplayer.get_unique_id(),PlayerColor)
	mainPanel.hide_ui()
