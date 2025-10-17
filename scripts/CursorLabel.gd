extends Sprite3D

@export var CameraObject : Camera3D

func _ready():
	var playerID = int( str(get_parent().name) )
	$"SubViewport/Label".text = str(playerID)
	self.rotation = CameraObject.rotation
