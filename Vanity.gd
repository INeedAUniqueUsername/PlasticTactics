extends Spatial
signal moved()
const Mirror = preload("res://VanitySpikeAttack.tscn")
func play_move():
	var target = null
	for c in get_parent().get_children():
		if c.is_in_group("Player"):
			target = c
	if !target:
		return
		
	var off = (target.get_global_transform().origin - get_global_transform().origin)
	var angle = atan2(-off.z, off.x)
	var deltaAngle = angle - rotation.y
	deltaAngle = atan2(sin(deltaAngle), cos(deltaAngle))
	$Tween.interpolate_property(self, "rotation:y", rotation.y, rotation.y + deltaAngle, 0.5,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
		
	$Anim.play("Shake")
	yield($Anim, "animation_finished")
	var tr = get_global_transform()
	
	var forward = tr.basis.x
	tr.origin += forward
	var mirrors = []
	for i in range(8):
		tr.origin += forward
		var m = Mirror.instance()
		get_parent().call_deferred("add_child", m)
		m.set_global_transform(tr)
		mirrors.append(m)
		
		var t = Timer.new()
		t.wait_time = 0.25
		add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
	for m in mirrors:
		yield(m, "tree_exited")
	emit_signal("moved")

func get_actor(node):
	while node and !node.is_in_group("Actor"):
		node = node.get_parent()
	return node

var hp = 100
signal damaged()
func _on_area_entered(area):
	var actor = get_actor(area)
	if actor and area.is_in_group("Damage"):
		hp = max(0, hp - actor.damage)
		emit_signal("damaged")
		
		var t = $Tween
		var tr = get_global_transform()
		var origin = tr.origin
		var back = -tr.basis.x
		t.interpolate_property(self, "global_transform:origin", origin, origin + back, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		t.start()
		
		$Hurt.play("Hurt")
		if hp == 0:
			queue_free()
