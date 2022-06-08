extends "res://Clickable.gd"
var walking = false
var movePoints = 5
func refresh_move():
	movePoints = 5
func jump():
	$Anim.play("Jump")

func get_actor(node):
	while node and !node.is_in_group("Actor"):
		node = node.get_parent()
	return node


func _on_area_entered(area):
	if !area.is_in_group("Damage"):
		return
	$Hurt.play("Hurt")
