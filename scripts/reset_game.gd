extends Button


@export var pawnmanager : PawnManager
@export var cardmanager : CardManager
@export var hourglass : Hourglass

func _on_reset_pressed() -> void:
	pawnmanager._on_reset_pawn_position_button_pressed()
	cardmanager.close_answer()
	GlobalSettings.clear_settings.rpc()
	hourglass._on_reset_button_pressed()
	
