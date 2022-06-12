extends "res://Damage.gd"

const Beam = preload("res://SunsetBeam.tscn")


var actions = ["Slash", "Stab", "Smash", "Shield"]
signal attack_ended()
signal boost_started()
signal boost_ended()
var boost = 0

var current_attack = null
func do(action, boostable = false):
	$Pivot/Copper/Boost.visible = boostable
	if action in ["Shield", "Unshield"]:
		$Anim.play(action)
		yield($Anim, "animation_finished")
		return
	
	boost = 0
	current_attack = action
	$Anim.play(action)
	yield($Anim, "animation_finished")
	emit_signal("attack_ended")
func start_boost():
	emit_signal("boost_started")
func set_boost():
	boost = $Anim.current_animation_position
func end_boost():
	var dur = ($Anim.current_animation_length - $Anim.current_animation_position) / $Anim.playback_speed
	
	var baseDamage = damage
	boost = 1.0 * boost / $Anim.current_animation_position
	damage += damage * boost
	emit_signal("boost_ended")
	#yield(get_tree(), "idle_frame")
	var t = Tween.new()
	t.interpolate_property($Pivot/Copper/Boost, "opacity", boost, boost, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	
	
	Helper.get_world(self).add_child(t)
	t.start()
	yield(self, "attack_ended")
	t.stop_all()
	t.queue_free()
	
	boost = 0
	damage = baseDamage
	$Pivot/Copper/Boost.opacity = 0
	
#onready var world = Helper.get_world(self)
func fire_beam():
	var b = Beam.instance()
	var world = Helper.get_world(self)
	world.call_deferred("add_child", b)
	yield(b, "tree_entered")
	b.set_global_transform($Pivot/Copper/Tip.get_global_transform())
	#yield(Helper.tween_move(b, get_global_transform().basis.x * 30, 1, Tween.TRANS_LINEAR), "completed")
	yield(b, "tree_exited")
	b.queue_free()
const Splash = preload("res://SunsetSwordSplash.tscn")
func make_splash():
	var world = Helper.get_world(self)
	var tr = $Pivot/Copper/Tip.get_global_transform()
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
	var tr = $Pivot/Copper/Tip.get_global_transform()
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
		emit_signal("boost_ended")
		emit_signal("attack_ended")
		Helper.tween_rotate($Pivot, Vector3(0, 0, PI/4), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		yield(get_tree().create_timer(1), "timeout")
		
		var t = Tween.new()
		t.interpolate_property($Pivot, "rotation", $Pivot.rotation, Vector3(0, 0, 0), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		t.interpolate_property($Pivot, "translation", $Pivot.translation, Vector3(0, 0, 0), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		t.interpolate_property($Pivot/Copper, "rotation", $Pivot/Copper.rotation, Vector3(0, 0, 0), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		t.interpolate_property($Pivot/Copper, "translation", $Pivot/Copper.translation, Vector3(0, 0, 0), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		add_child(t)
		t.start()
		yield(t, "tween_all_completed")
		t.queue_free()
	pass
