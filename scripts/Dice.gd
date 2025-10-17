extends Node3D
@export var LabelObject : Label

var hover = false
var rng = RandomNumberGenerator.new()
var rollcount = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		if hover:
			set_label_text(str(_roll_dice()))
	

func set_label_text(t):
	var textadd = ""
	for i in range(0, rollcount):
		textadd += "#"
	if rollcount >= 3:
		rollcount = 0
	LabelObject.text = "[" + t + "]" + textadd
	rollcount += 1
	syncDiceCount.rpc(LabelObject.text, rollcount)


func _on_static_body_3d_mouse_entered():
	hover = true
	pass # Replace with function body.


func _on_static_body_3d_mouse_exited():
	hover = false
	pass # Replace with function body.

func _roll_dice():
	var roll = rng.randf_range(1, 7)
	return int(roll)
	
@rpc("any_peer")
func syncDiceCount(t, rc):
	LabelObject.text = t
	rollcount = rc
