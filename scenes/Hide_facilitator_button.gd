extends MarginContainer

@export var FacilitatorPanels : Control
var panelhidden : bool

func _ready() -> void:
	panelhidden = !FacilitatorPanels.visible

func _toggle_facilitator_panels():
	if panelhidden:
		FacilitatorPanels.show()
		panelhidden = false
	else:
		FacilitatorPanels.hide()
		panelhidden = true
