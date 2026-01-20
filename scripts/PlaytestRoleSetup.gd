extends Node

@export_category("Facilitator Objects to Show")
@export var TimerObject : Node
@export var FacilitatorCardPanel : Node
@export var FacilitatorUI : Node
@export var FacilitatorKitButton : Node

@export_category("Other Objects to Show when done")
@export var OptionsPanel : Node

func _ready():
	self.visible = true
	toggleFacilitatorbuttons(false)

func _on_facilitator_pressed():
	PlayerSettings.role = "facilitator"
	self.visible = false
	toggleFacilitatorbuttons(true)
	OptionsPanel.visible = true
	pass # Replace with function body.

func toggleFacilitatorbuttons(visible : bool):
	
	for node in get_tree().get_nodes_in_group("FacilitatorUI"):
		if node is CanvasItem:
			node.visible = visible
		elif node is VisualInstance3D:
			node.visible = visible
	#TimerObject.visible = visible
	#FacilitatorCardPanel.visible = visible
	#FacilitatorUI.visible = visible
	#FacilitatorKitButton.visible = visible


func _on_player_pressed():
	PlayerSettings.role = "player"
	self.visible = false
	toggleFacilitatorbuttons(false)
	OptionsPanel.visible = true
	pass # Replace with function body.
