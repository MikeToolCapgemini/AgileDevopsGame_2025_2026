extends Button

var login : Login_Manager



func _on_pressed() -> void:
	GlobalSignals.logout.emit()
