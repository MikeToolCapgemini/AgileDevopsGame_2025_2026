extends Control

@export var cardManagerObject : Node
@export var textObject :RichTextLabel

func _on_pressed():
	cardManagerObject.card_bookmark()
	cardManagerObject.close_answer()
	textObject.update_text()
	
