extends Spatial
func cast():
	var tr = get_global_transform()
	var origin = tr.origin
	origin.y = round(origin.y)
	var world = Helper.get_world(self)
	for x in [1, 2, 3, 4, 5, 6, 7]:
		for z in [-3, -2, -1, 0, 1, 2, 3]:
			var p = world.get_ground_origin(origin + z * tr.basis.z + x * tr.basis.x)
			if p == null:
				continue
			tr.origin = p
			Helper.add_to_world(self, Cloud.instance(), tr)
	yield(get_tree().create_timer(1.8), "timeout")
const Cloud = preload("res://ThunderstormCloud.tscn")
