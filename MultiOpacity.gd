extends Spatial

export(float) var opacity = 1.0
func _physics_process(delta):
	for c in get_children():
		c.opacity = opacity
