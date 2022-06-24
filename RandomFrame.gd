extends Sprite3D
func _ready():
	frame = randi()%(hframes * vframes)
