extends "res://Clickable.gd"


func set_appearance(vis, enabled = true):
	if !vis:
		self.opacity = 0
		$Area.input_ray_pickable = false
	elif enabled:
		self.opacity = 1.0
		$Area.input_ray_pickable = true
	else:
		self.opacity = 0.5
		$Area.input_ray_pickable = false
