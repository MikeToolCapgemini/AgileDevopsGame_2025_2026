extends Node

@export_category("Facilitator Objects to Show")
@export var role = "none"
@export var TimerObject : Node
@export var FacilitatorCardPanel : Node
@export var FacilitatorUI : Node
@export var FacilitatorKitButton : Node

@export_category("Other Objects to Show when done")
@export var OptionsPanel : Node

func _ready():
	self.visible = true

func _on_facilitator_pressed():
	role = "facilitator"
	self.visible = false
	print(role)
	toggleFacilitatorbuttons(true)
	OptionsPanel.visible = true
	pass # Replace with function body.

func toggleFacilitatorbuttons(visible : bool):
	TimerObject.visible = visible
	FacilitatorCardPanel.visible = visible
	FacilitatorUI.visible = visible
	FacilitatorKitButton.visible = visible


func _on_player_pressed():
	role = "player"
	print(role)
	self.visible = false
	toggleFacilitatorbuttons(false)
	OptionsPanel.visible = true
	pass # Replace with function body.
