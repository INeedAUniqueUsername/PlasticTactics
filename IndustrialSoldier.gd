extends Spatial
signal moved()
var attackInterrupted = false
var attackCharging = false
var attackPrepared = false
func get_offset(target):
	return target.get_global_transform().origin - get_global_transform().origin

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
			
			var off = get_offset(target) + Vector3(2, 0, 0)
			for i in range(min(abs(off.z), abs(movePoints))):
				if target.walking:
					#$ThinkingEye/Anim.play("Look")
					while target.walking:
						yield(get_tree().create_timer(0.3), "timeout")
					off = get_offset(target) + Vector3(8, 0, 0)
					break
				
				var dp = Vector3(0, 0, sign(off.z))
				if !world.get_ground(get_global_transform().origin + dp):
					break
				yield(walk(dp), "completed")
				movePoints -= 1
				moved = true
			for i in range(min(abs(off.x), abs(movePoints))):
				if target.walking:
					#$ThinkingEye/Anim.play("Look")
					while target.walking:
						yield(get_tree().create_timer(0.3), "timeout")
					break
				var dp = Vector3(sign(off.x), 0, 0)
				if !world.get_ground(get_global_transform().origin + dp):
					break
				yield(walk(dp), "completed")
				movePoints -= 1
				moved = true
		if !moved:
			#$ThinkingEye/Anim.play("Look")
			yield(get_tree().create_timer(1.0), "timeout")
	while target.walking:
		yield(get_tree().create_timer(0.3), "timeout")
	attackNum += 1
	
	$Sprite/WeaponEquip.get_child(0).do("Slash", self)
	
	emit_signal("moved")
func end_turn():
	check_standing_areas()
	if attackPrepared:
		yield(get_tree().create_timer(4.0), "timeout")
		emit_signal("attack_released")
		attackPrepared = false
		
var hp_max = 300
var hp = hp_max
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
	if world.get_ground(dest) and world.is_open(dest, [$NoMove]):
		Helper.tween_move(self, back, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
	
	$Hurt.play("Hurt")
	if hp == 0:
		queue_free()
const healEffect = preload("res://HealEffect.tscn")
func check_standing_areas():
	for a in $Sprite/Area.get_overlapping_areas():
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
