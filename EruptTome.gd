extends Spatial
func cast():
	var tr = get_global_transform()
	var origin = tr.origin
	origin.y = round(origin.y)
	var world = Helper.get_world(self)
	for x in [1, 2, 3, 4, 5, 6, 7]:
		for z in [-4, -3, -2, -1, 0, 1, 2, 3, 4]:
			if randi()%8 != 0:
				continue
			tr.origin = origin + z * tr.basis.z + x * tr.basis.x
			var p = world.get_ground_origin(tr.origin)
			if p == null:
				continue
			tr.origin = p
			erupt_vent(tr)
	yield(get_tree().create_timer(1.8), "timeout")
const Vent = preload("res://EruptVent.tscn")
func erupt_vent(tr):
	yield(get_tree().create_timer(randf() * 1.2), "timeout")
	Helper.add_to_world(self, Vent.instance(), tr)
