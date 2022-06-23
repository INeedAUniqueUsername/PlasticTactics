extends Spatial
const Beam = preload("res://SunsetBeam.tscn")
onready var sword = Helper.get_actor(self)
func stab():
	var b = Beam.instance()
	var world = Helper.get_world(self)
	world.call_deferred("add_child", b)
	yield(b, "tree_entered")
	b.set_global_transform(get_global_transform())
	#yield(Helper.tween_move(b, get_global_transform().basis.x * 30, 1, Tween.TRANS_LINEAR), "completed")
	yield(b, "tree_exited")
	b.queue_free()
const Splash = preload("res://SunsetSwordSplash.tscn")
func smash():
	var world = Helper.get_world(self)
	var tr = get_global_transform()
	var origin = world.get_ground_origin(tr.origin)
	if origin == null:
		return
	tr.origin = origin
	var s = Splash.instance()
	s.damageBonus = sword.boost
	world.call_deferred("add_child", s)
	yield(s, "tree_entered")
	s.set_global_transform(tr)
	#s.queue_free()
const Spark = preload("res://SunsetSwordSpark.tscn")
func slash():
	var dur = 0.3
	
	for i in range(16):
		yield(get_tree().create_timer(pow(0.3 * i / 200.0, 2)), "timeout")
		create_spark()
func create_spark():
	var s = Spark.instance()
	var tr = get_global_transform()
	Helper.get_world(self).call_deferred("add_child", s)
	s.set_global_transform(tr)
	yield(s, "tree_entered")
	yield(Helper.tween_move(s, tr.basis.x * 6, 1.5, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
	yield(Helper.tween_property(s, "opacity", 1, 0, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN), "completed")
	s.queue_free()
