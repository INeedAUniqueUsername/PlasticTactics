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
	var tr = $Pivot/Sprite/Tip.get_global_transform()
	Helper.get_world(self).call_deferred("add_child", s)
	s.set_global_transform(tr)
	yield(s, "tree_entered")
	yield(Helper.tween_move(s, tr.basis.x * 6, 1.5, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
	yield(Helper.tween_property(s, "opacity", 1, 0, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN), "completed")
	s.queue_free()


func _on_area_entered(area):
	if !active:
		return
	if area.is_in_group("StopAttack"):
		active = false
		$Anim.stop()
		
		Helper.tween_rotate($Pivot, Vector3(0, 0, PI/4), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		yield(get_tree().create_timer(1), "timeout")
		
		var t = Tween.new()
		t.interpolate_property($Pivot, "rotation", $Pivot.rotation, Vector3(0, 0, 0), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		t.interpolate_property($Pivot, "translation", $Pivot.translation, Vector3(0, 0, 0), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		t.interpolate_property($Pivot/Sprite, "rotation", $Pivot/Sprite.rotation, Vector3(0, 0, 0), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		t.interpolate_property($Pivot/Sprite, "translation", $Pivot/Sprite.translation, Vector3(0, 0, 0), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		add_child(t)
		t.start()
		yield(t, "tween_all_completed")
		t.queue_free()
	pass
