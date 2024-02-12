extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rotation_rad
# Called when the node enters the scene tree for the first time.
func _ready():
	rotation_rad = 0
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation_rad = rotation
