extends Node3D
@export var LabelObject : Label
@export var CardManager : Node
@export var cardType : String

var hover = false
var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	LabelObject.text = ""


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		if hover && !CardManager.active:
			CardManager.draw(cardType)


func _on_static_body_3d_mouse_entered():
	hover = true


func _on_static_body_3d_mouse_exited():
	hover = false
