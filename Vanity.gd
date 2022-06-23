extends Spatial
signal moved()
const Mirror = preload("res://VanitySpikeAttack.tscn")
const DelayedSpike = preload("res://VanityDelayedSpikeAttack.tscn")
	
var attackInterrupted = false
var attackCharging = false
var attackPrepared = false
func get_offset(target):
	return target.get_global_transform().origin - get_global_transform().origin

enum Attacks {
	Spike, Stalagmite
}

var attackNum = 0

func start_turn():
	check_standing_areas()
func walk(dp):
	yield(Helper.tween_move(self, dp, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
	check_standing_areas()
func play_move():
	var target = null
	
	var world = Helper.get_world(self)
	for c in world.get_children():
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
				if !world.has_ground(get_global_transform().origin + dp):
					break
				yield(walk(dp), "completed")
				movePoints -= 1
				moved = true
			for i in range(min(abs(off.x), abs(movePoints))):
				if target.walking:
					$ThinkingEye/Anim.play("Look")
					while target.walking:
						yield(get_tree().create_timer(0.3), "timeout")
					break
				var dp = Vector3(sign(off.x), 0, 0)
				if !world.has_ground(get_global_transform().origin + dp):
					break
				yield(walk(dp), "completed")
				movePoints -= 1
				moved = true
		if !moved:
			$ThinkingEye/Anim.play("Look")
			yield(get_tree().create_timer(1.0), "timeout")
	while target.walking:
		yield(get_tree().create_timer(0.3), "timeout")
	var attackType = [Attacks.Spike, Attacks.Spike, Attacks.Stalagmite, Attacks.Stalagmite, Attacks.Spike]
	attackType = attackType[attackNum%len(attackType)]
	attackNum += 1
	match attackType:
		Attacks.Spike:
			var off = (target.get_global_transform().origin - get_global_transform().origin)
			var deltaAngle = atan2(-off.z, off.x) - rotation.y
			deltaAngle = atan2(sin(deltaAngle), cos(deltaAngle))
			yield(Helper.tween_rotate(self, Vector3(0, deltaAngle, 0), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
			
			yield(charge(), "completed")
			
			if randi()%3 == 0 and !attackInterrupted:
				prepared_spike_attack()
				yield(self, "attack_prepared")
			else:
				yield(spike_attack(), "completed")
			emit_signal("moved")
		Attacks.Stalagmite:
			var deltaAngle = (PI/2) * round(rotation.y / (PI / 2)) - rotation.y
			deltaAngle = atan2(sin(deltaAngle), cos(deltaAngle))
			yield(Helper.tween_rotate(self, Vector3(0, deltaAngle, 0), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
			
			yield(charge(), "completed")
			
			yield(stalagmite_attack(), "completed")
			emit_signal("moved")
func end_turn():
	check_standing_areas()
	if attackPrepared:
		yield(get_tree().create_timer(4.0), "timeout")
		emit_signal("attack_released")
		attackPrepared = false
		
func charge():
		attackInterrupted = false
		attackCharging = true
		$Anim.play("Shake")
		yield($Anim, "animation_finished")
		attackCharging = false
	
signal attack_released()
signal attack_prepared()
func prepared_spike_attack():
	var tr = get_global_transform()
	
	var forward = tr.basis.x
	var up = tr.basis.z
	var p = tr.origin + forward
	#var mirrors = []
	
	var count = 16
	if attackInterrupted:
		count = 24
		
	var placed = []
	var spikes = []
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
		
		var world = Helper.get_world(self)
		if !world.has_ground(tr.origin):
			continue
		if !world.is_open(tr.origin):
			yield(get_tree().create_timer(0.125), "timeout")
			continue
		var s = DelayedSpike.instance()
		world.add_child(s)
		s.set_global_transform(tr)
		spikes.append(s)
		yield(get_tree().create_timer(0.125), "timeout")
	yield(get_tree().create_timer(1.0), "timeout")
	
	attackPrepared = true
	emit_signal("attack_prepared")
	yield(self, "attack_released")
	attackPrepared = false
	$Anim.play("Shake")
	for s in spikes:
		if attackInterrupted:
			get_tree().create_timer(randf() * 1.0).connect("timeout", s.get_node("Anim"), "play", ["Attack"])
		else:
			s.get_node("Anim").play("Attack")
func spike_attack():
	var tr = get_global_transform()
	
	var forward = tr.basis.x
	var up = tr.basis.z
	var p = tr.origin + forward
	#var mirrors = []
	
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
		var world = Helper.get_world(self)
		if !world.has_ground(tr.origin):
			continue
		if !world.is_open(tr.origin):
			yield(get_tree().create_timer(0.125), "timeout")
			continue
		var m = Mirror.instance()
		world.add_child(m)
		m.set_global_transform(tr)
		#mirrors.append(m)
		yield(get_tree().create_timer(0.125), "timeout")
	
	yield(get_tree().create_timer(1.0), "timeout")
const Stalagmite = preload("res://VanityStalagmiteAttack.tscn") 
func stalagmite_attack():
	var placed = []
	
	var tr = get_global_transform()
	var origin = tr.origin
	
	var world = Helper.get_world(self)
	for i in range(8):
		var p = origin + int(rand_range(2, 8)) * tr.basis.x + int(rand_range(-8, 9)) * tr.basis.z
		var tries = 10
		while tries > 0:
			if placed.has(p) or !world.is_open(p):
				tries -= 1
				continue
			var ground = world.get_ground_origin(p)
			if ground == null:
				tries -= 1
				continue
			p = ground
			tries = -1
		if tries == 0:
			continue
		placed.append(p)
		
		var s = Stalagmite.instance()
		world.add_child(s)
		tr.origin = p
		s.set_global_transform(tr)
		yield(get_tree().create_timer(0.125), "timeout")
	yield(get_tree().create_timer(1.0), "timeout")

var hp_max = 300
var hp = 300
signal damaged()
func _on_area_entered(area):
	if !area.is_in_group("Damage"):
		return
	var actor = Helper.get_actor(area)
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
	
	if attackPrepared:
		emit_signal("attack_released")
		
	
	var back = actor.get_global_transform().basis.x
	
	var world = Helper.get_world(self)
	var dest = get_global_transform().origin + back
	if world.has_ground(dest) and world.is_open(dest, [$NoMove]):
		Helper.tween_move(self, back, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
	
	$Hurt.play("Hurt")
	if hp == 0:
		queue_free()
const healEffect = preload("res://HealEffect.tscn")
func check_standing_areas():
	for a in $Area.get_overlapping_areas():
		if a.is_in_group("Heal"):
			hp = min(100, hp + 10)
			emit_signal("damaged")
			var he = healEffect.instance()
			he.set_global_transform(get_global_transform())
			Helper.get_world(self).add_child(he)
		elif a.is_in_group("Burning"):
			hp = max(0, hp - 10)
			emit_signal("damaged")
			$Hurt.play("Hurt")
