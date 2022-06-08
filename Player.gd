extends "res://Clickable.gd"
var walking = false
var movePoints = 5
var attackPoints = 1
func refresh_move():
	movePoints = 5
	attackPoints = 1
func attack():
	$Sprite/VaguelyLegendarySword/Anim.play("Slash")
func jump():
	$Anim.play("Jump")

func get_actor(node):
	while node and !node.is_in_group("Actor"):
		node = node.get_parent()
	return node

var hp = 100
signal damaged()
func _on_area_entered(area):
	if !area.is_in_group("Damage"):
		return
	var actor = get_actor(area)
	if actor.get_parent() == $Sprite:
		return
	hp = max(0, hp - actor.damage)
	emit_signal("damaged")
	$Hurt.play("Hurt")
	if hp == 0:
		pass
		#queue_free()
