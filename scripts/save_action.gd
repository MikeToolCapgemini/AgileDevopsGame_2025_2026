extends Button

@export var collapeToggler : CollapseButton
@export var TeamColor : String
@export var cardManager : CardManager


func SaveAction(color):
	PlayerSettings.add_action_card.rpc(color,cardManager.curKey)
	return

func _on_pressed() -> void:
	SaveAction(TeamColor)
	collapeToggler._on_collapse_close()
