extends Node

@export var windSway = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if windSway:
		if self.rotation.z <= 20 && self.rotation.z >= -10:
			self.rotation.z += randf_range(-0.5, 0.5)*delta
