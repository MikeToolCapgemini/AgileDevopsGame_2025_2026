extends MarginContainer

@export var FacilitatorPanels : Control
@export var CardPanel : Container
var panelhidden : bool

func _ready() -> void:
	panelhidden = !FacilitatorPanels.visible

func _toggle_facilitator_panels():
	if PlayerSettings.role == "facilitator":
		if panelhidden:
			CardPanel.mouse_filter = Control.MOUSE_FILTER_STOP
			FacilitatorPanels.mouse_filter = Control.MOUSE_FILTER_STOP
			FacilitatorPanels.show()
			panelhidden = false
		else:
			CardPanel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			FacilitatorPanels.mouse_filter = Control.MOUSE_FILTER_IGNORE
			FacilitatorPanels.hide()
			panelhidden = true
