extends Spatial
const Splash = preload("res://SunsetSwordSplash.tscn")
onready var sword = Helper.get_actor(self)
func make_splash():
	var world = Helper.get_world(self)
	var tr = get_global_transform()
	
	var origin = world.get_ground_origin(tr.origin)
	if origin == null:
		return
	
	tr.origin = origin
	var s = Splash.instance()
	s.damageBonus = sword.boost
	s.particleCount *= 1.5
	world.call_deferred("add_child", s)
	yield(s, "tree_entered")
	s.set_global_transform(tr)
	#s.queue_free()
