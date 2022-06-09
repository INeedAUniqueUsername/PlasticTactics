extends Spatial
signal moved()
const Mirror = preload("res://VanitySpikeAttack.tscn")
func start_turn():
	pass
func end_turn():
	pass
func play_move():
	var target = null
	for c in get_parent().get_children():
		if c.is_in_group("Player"):
			target = c
	if !target:
		return
			
	var movePoints = 8
			
	var off = (target.get_global_transform().origin - get_global_transform().origin)
	for i in range(min(abs(off.z), abs(movePoints))):
		var dp = Vector3(0, 0, sign(off.z))
		if !get_parent().has_ground(get_global_transform().origin + dp):
			continue
		yield(Helper.tween_move(self, dp, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")	
		movePoints -= 1
	for i in range(min(abs(off.x), abs(movePoints))):
		var dp = Vector3(-sign(off.x), 0, 0)
		if !get_parent().has_ground(get_global_transform().origin + dp):
			continue
		yield(Helper.tween_move(self, dp, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")	
		movePoints -= 1
	off = (target.get_global_transform().origin - get_global_transform().origin)
	var deltaAngle = atan2(-off.z, off.x) - rotation.y
	deltaAngle = atan2(sin(deltaAngle), cos(deltaAngle))
	yield(Helper.tween_rotate(self, Vector3(0, deltaAngle, 0), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
	
	$Anim.play("Shake")
	yield($Anim, "animation_finished")
	
	var tr = get_global_transform()
	
	var forward = tr.basis.x
	tr.origin += forward
	var mirrors = []
	for i in range(8):
		tr.origin += forward
		var m = Mirror.instance()
		get_parent().add_child(m)
		m.set_global_transform(tr)
		mirrors.append(m)
		
		yield(get_tree().create_timer(0.25), "timeout")
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
		
		var back = actor.get_global_transform().basis.x
		if get_parent().has_ground(get_global_transform().origin + back):
			Helper.tween_move(self, back, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
		
		$Hurt.play("Hurt")
		if hp == 0:
			queue_free()
