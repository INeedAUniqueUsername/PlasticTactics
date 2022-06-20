extends Spatial
func end_turn():
	pass
const Rock = preload("res://EruptRock.tscn")
const Smoke = preload("res://EruptSmoke.tscn")
func erupt():
	var tr = get_global_transform()
	#var origin = tr.origin
	tr.origin += Vector3(0, 0.5, 0)
	Helper.add_to_world(self, Smoke.instance(), tr)
	for i in range(1):
		var r = Rock.instance()
		var angle = randf() * PI * 2
		var hspeed = rand_range(1.0, 2.0)
		r.vel = Vector3(hspeed * cos(angle), rand_range(6, 9), hspeed * sin(angle))
		Helper.add_to_world(self, r, tr)	
