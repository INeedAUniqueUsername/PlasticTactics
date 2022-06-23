extends Spatial
const Splash = preload("res://VolcanicHammerSplash.tscn")
onready var sword = Helper.get_actor(self)
func smash():
	var world = Helper.get_world(self)
	var tr = get_global_transform()
	
	var origin = world.get_ground_origin(tr.origin)
	if origin == null:
		return
	
	tr.origin = origin
	var s = Splash.instance()
	world.call_deferred("add_child", s)
	yield(s, "tree_entered")
	s.set_global_transform(tr)


	for c in Helper.get_world(self).get_misc_actors():
		if !c.is_in_group("Vent"):
			continue
		c.erupt()
