extends Spatial
func cast():
	
	var tr = get_global_transform()
	var origin = tr.origin
	origin.y = round(origin.y)
	var world = Helper.get_world(self)
	for x in [1, 2, 3, 4, 5]:
		for z in [-2, -1, 0, 1, 2]:
			tr.origin = origin + z * tr.basis.z + x * tr.basis.x
			var g = world.get_ground_origin(tr.origin)
			if g == null:
				continue
			tr.origin.y = g.y
			Helper.add_to_world(self, Fog.instance(), tr)
	yield(get_tree().create_timer(1.8), "timeout")
const Fog = preload("res://ScaldFog.tscn")
