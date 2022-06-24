extends Sprite3D

func _ready():
	call_deferred("check_sides")
func check_sides():
	var world = Helper.get_world(self)
	
	var directions = {
		'E': Vector3(1, 0, 0),
		'N': Vector3(0, 0, -1),
		'S': Vector3(0, 0, 1),
		'W': Vector3(-1, 0, 0)
	}
	var pos = get_global_transform().origin
	for dir in directions.keys():
		var g = world.get_ground_origin(pos + directions[dir])
		if g == null or g.y < pos.y:
			continue
		get_node(dir).queue_free()
