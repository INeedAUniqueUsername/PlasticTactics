extends Spatial
func start_turn():
	detonate()
const Explosion = preload("res://DynamiteExplosion.tscn")
func detonate():
	var e = Explosion.instance()
	Helper.add_to_world(self, e, $ExplosionOrigin.get_global_transform())
	queue_free()
