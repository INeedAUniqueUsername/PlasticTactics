extends Spatial
signal moved()
const Mirror = preload("res://VanitySpikeAttack.tscn")
func start_turn():
	pass
func end_turn():
	pass
	
var attackInterrupted = false
var attackCharging = false
var attackPrepared = false
func get_offset(target):
	return target.get_global_transform().origin - get_global_transform().origin


func play_move():
	var target = null
	for c in get_parent().get_children():
		if c.is_in_group("Player"):
			target = c
	if !target:
		return
			
	var movePoints = 8
			
	var moved = false
	for ii in range(3):
		if movePoints == 0 or moved:
			break
		for n in range(10):
			if movePoints == 0:
				break
			
			var off = get_offset(target) + Vector3(8, 0, 0)
			for i in range(min(abs(off.z), abs(movePoints))):
				if target.walking:
					$ThinkingEye/Anim.play("Look")
					while target.walking:
						yield(get_tree().create_timer(0.3), "timeout")
					off = get_offset(target) + Vector3(8, 0, 0)
					break
				
				var dp = Vector3(0, 0, sign(off.z))
				if !get_parent().has_ground(get_global_transform().origin + dp):
					break
				yield(Helper.tween_move(self, dp, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")	
				movePoints -= 1
				moved = true
			for i in range(min(abs(off.x), abs(movePoints))):
				if target.walking:
					$ThinkingEye/Anim.play("Look")
					while target.walking:
						yield(get_tree().create_timer(0.3), "timeout")
					break
				var dp = Vector3(sign(off.x), 0, 0)
				if !get_parent().has_ground(get_global_transform().origin + dp):
					break
				yield(Helper.tween_move(self, dp, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")	
				movePoints -= 1
				moved = true
		if !moved:
			$ThinkingEye/Anim.play("Look")
			yield(get_tree().create_timer(1.0), "timeout")
		
	while target.walking:
		yield(get_tree().create_timer(0.3), "timeout")
	var off = (target.get_global_transform().origin - get_global_transform().origin)
	var deltaAngle = atan2(-off.z, off.x) - rotation.y
	deltaAngle = atan2(sin(deltaAngle), cos(deltaAngle))
	yield(Helper.tween_rotate(self, Vector3(0, deltaAngle, 0), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
	
	attackInterrupted = false
	attackCharging = true
	$Anim.play("Shake")
	yield($Anim, "animation_finished")
	attackCharging = false
	if randi()%4 == 0 and !attackInterrupted:
		attackPrepared = true
	else:
		yield(spike_attack(), "completed")
	emit_signal("moved")
	
	if attackPrepared:
		yield(get_tree().create_timer(4.0), "timeout")
		prepared_spike_attack()

func spike_attack():
	var tr = get_global_transform()
	
	var forward = tr.basis.x
	var up = tr.basis.z
	var p = tr.origin + forward
	var mirrors = []
	
	var count = 16
	if attackInterrupted:
		count = 24
		
	var placed = []
	for i in range(count):
		
		if !attackInterrupted or randi()%2 == 0:
			p += forward
		tr.origin = p
		if attackInterrupted:
			tr.origin += (randi()%5 - 2) * up
			tr.origin += (randi()%5 - 2) * forward
		
		if placed.has(tr.origin):
			continue
		placed.append(tr.origin)
		
		if !get_parent().has_ground(tr.origin):
			continue
		
		var m = Mirror.instance()
		get_parent().add_child(m)
		
		m.set_global_transform(tr)
		mirrors.append(m)
		
		yield(get_tree().create_timer(0.125), "timeout")
	
	yield(get_tree().create_timer(1.0), "timeout")

func prepared_spike_attack():
	if attackPrepared:
		$Anim.play("Shake")
		spike_attack()
		attackPrepared = false
func get_actor(node):
	while node and !node.is_in_group("Actor"):
		node = node.get_parent()
	return node

var hp_max = 300
var hp = 300
signal damaged()
func _on_area_entered(area):
	if !area.is_in_group("Damage"):
		return
	var actor = get_actor(area)
	if !actor:
		return
	if 'active' in actor and !actor.active:
		return
	attackInterrupted = attackCharging or attackPrepared
	var dmg = actor.damage
	if attackInterrupted:
		dmg *= 2.0
	hp = max(0, hp - dmg)
	emit_signal("damaged")
	
	prepared_spike_attack()
	
	var back = actor.get_global_transform().basis.x
	if get_parent().has_ground(get_global_transform().origin + back):
		Helper.tween_move(self, back, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
	
	$Hurt.play("Hurt")
	if hp == 0:
		queue_free()
