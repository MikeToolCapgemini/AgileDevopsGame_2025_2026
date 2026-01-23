extends Node

@export_category("Facilitator Objects to Show")
@export var TimerObject : Node
@export var FacilitatorCardPanel : Node
@export var FacilitatorUI : Node
@export var FacilitatorKitButton : Node

@export_category("Other Objects to Show when done")
@export var OptionsPanel : Node
@export var Top_left_buttons : Control
@export var ColorSelectPanel : Control

func _ready():
	match(PlayerSettings.role):
		"none":
			self.visible = true
		"facilitator":
			toggleFacilitatorbuttons(true)
		"player":
			toggleFacilitatorbuttons(false)
			if ColorSelectPanel:
				ColorSelectPanel.visible = true
	if OptionsPanel:
		OptionsPanel.visible = true
	if Top_left_buttons:
		Top_left_buttons.visible = true

func _on_facilitator_pressed():
	PlayerSettings.role = "facilitator"
	self.visible = false
	toggleFacilitatorbuttons(true)

func toggleFacilitatorbuttons(visible : bool):
	
	for node in get_tree().get_nodes_in_group("FacilitatorUI"):
		if node is CanvasItem:
			node.visible = visible
		elif node is VisualInstance3D:
			node.visible = visible


func _on_player_pressed():
	PlayerSettings.role = "player"
	self.visible = false
	toggleFacilitatorbuttons(false)
