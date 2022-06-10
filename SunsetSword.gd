extends "res://Damage.gd"

const Beam = preload("res://SunsetBeam.tscn")
const Splash = preload("res://SunsetSwordSplash.tscn")
func fire_beam():
	var b = Beam.instance()
	var world = Helper.get_world(self)
	world.call_deferred("add_child", b)
	yield(b, "tree_entered")
	b.set_global_transform($Pivot/Sprite/Beam.get_global_transform())
	yield(Helper.tween_move(b, get_global_transform().basis.x * 30, 1, Tween.TRANS_LINEAR), "completed")
	b.queue_free()
func make_splash():
	var s = Splash.instance()
	var world = Helper.get_world(self)
	world.call_deferred("add_child", s)
	yield(s, "tree_entered")
	s.set_global_transform($Pivot/Sprite/Splash.get_global_transform())
	#s.queue_free()
