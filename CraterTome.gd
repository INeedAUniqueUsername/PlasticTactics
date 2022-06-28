extends Spatial
func cast():
	var tr = get_global_transform()
	tr.origin = Helper.get_actor(self).targeting.target
	Helper.add_to_world(self, Explosion.instance(), tr)
	yield(get_tree().create_timer(1.8), "timeout")
const Explosion = preload("res://DynamiteExplosion.tscn")
