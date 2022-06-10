extends "res://Damage.gd"

const Beam = preload("res://SunsetBeam.tscn")

#onready var world = Helper.get_world(self)
func fire_beam():
	var b = Beam.instance()
	var world = Helper.get_world(self)
	world.call_deferred("add_child", b)
	yield(b, "tree_entered")
	b.set_global_transform($Pivot/Sprite/Tip.get_global_transform())
	#yield(Helper.tween_move(b, get_global_transform().basis.x * 30, 1, Tween.TRANS_LINEAR), "completed")
	yield(b, "tree_exited")
	b.queue_free()
const Splash = preload("res://SunsetSwordSplash.tscn")
func make_splash():
	var world = Helper.get_world(self)
	var tr = $Pivot/Sprite/Tip.get_global_transform()
	if !world.has_ground(tr.origin):
		return
	var s = Splash.instance()
	world.call_deferred("add_child", s)
	yield(s, "tree_entered")
	s.set_global_transform(tr)
	#s.queue_free()
const Spark = preload("res://SunsetSwordSpark.tscn")
func make_wave():
	var dur = 0.3
	
	for i in range(16):
		yield(get_tree().create_timer(pow(0.3 * i / 200.0, 2)), "timeout")
		create_spark()
func create_spark():
	var s = Spark.instance()
	var world = Helper.get_world(self)
	world.call_deferred("add_child", s)
	yield(s, "tree_entered")
	var tr = $Pivot/Sprite/Tip.get_global_transform()
	s.set_global_transform(tr)
	yield(Helper.tween_move(s, tr.basis.x * 6, 1.5, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
	yield(Helper.tween_property(s, "opacity", 1, 0, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN), "completed")
	s.queue_free()
