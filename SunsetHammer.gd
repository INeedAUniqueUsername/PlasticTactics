extends "res://Damage.gd"

const Beam = preload("res://SunsetBeam.tscn")


var actions = ["Smash"]
signal attack_ended()
signal boost_started()
signal boost_ended()
var boost = 0
onready var boostGlow = $Pivot/Copper/Glow
var current_attack = null
func _ready():
	connect("attack_ended", self, "set", ["current_attack", null])
func do(action, boostable = false):
	boostGlow.visible = boostable
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
	t.interpolate_property(boostGlow, "opacity", boost, boost, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	Helper.get_world(self).add_child(t)
	t.start()
	yield(self, "attack_ended")
	t.stop_all()
	t.queue_free()
	boost = 0
	damage = baseDamage
	boostGlow.opacity = 0
#onready var world = Helper.get_world(self)
func fire_beam():
	pass
const Splash = preload("res://SunsetSwordSplash.tscn")
func make_splash():
	var world = Helper.get_world(self)
	var tr = $Pivot/Copper/Tip.get_global_transform()
	tr.origin.y = round(tr.origin.y)
	if !world.has_ground(tr.origin):
		return
	var s = Splash.instance()
	s.damageBonus = boost
	s.particleCount *= 1.5
	world.call_deferred("add_child", s)
	yield(s, "tree_entered")
	s.set_global_transform(tr)
	#s.queue_free()
func make_wave():
	pass
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
