extends "res://Damage.gd"
var actions = ["Slash", "Stab", "Smash", "Shield"]
signal attack_ended()
signal boost_started()
signal boost_ended()
var boost = 0

export(NodePath) var boostGlow = "Pivot/Sprite/Glow"
var current_attack = null
func _ready():
	boostGlow = get_node(boostGlow)
	connect("attack_ended", self, "set", ["current_attack", null])
var shielding = false
func do(action, attacker):
	var boostable = attacker.inTurn
	boostGlow.visible = boostable
	
	if action in ["Shield", "Unshield"]:
		shielding = action == "Shield"
		
		var other = { false: "Shield", true: "Unshield" }[shielding]
		var index = actions.find(action)
		actions.remove(index)
		actions.insert(index, other)
		
		$Anim.play(action)
		yield($Anim, "animation_finished")
		return
	
	boost = 0
	current_attack = action
	$Anim.play(action)
	yield($Anim, "animation_finished")
	emit_signal("attack_ended")
var boost_interval_start
func start_boost():
	boost_interval_start = $Anim.current_animation_position
	emit_signal("boost_started")
func set_boost():
	boost = $Anim.current_animation_position
func end_boost():
	var boost_interval_end = $Anim.current_animation_position
	var interval = boost_interval_end - boost_interval_start
	
	var dur = ($Anim.current_animation_length - $Anim.current_animation_position) / $Anim.playback_speed
	var baseDamage = damage
	boost = 1.0 * (boost - boost_interval_start) / boost_interval_end
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


func _on_area_entered(area):
	if !active:
		return
	if area.is_in_group("StopAttack"):
		var actor = Helper.get_actor(area)
		if actor and 'destroyed' in actor and actor.destroyed:
			return
		active = false
		$Anim.stop()
		emit_signal("boost_ended")
		emit_signal("attack_ended")
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
