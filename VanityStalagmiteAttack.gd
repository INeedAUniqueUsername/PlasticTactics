extends Spatial

var damage = 20

var turnsLeft = 2
func start_turn():
	if turnsLeft:
		turnsLeft -= 1
	else:
		$Anim.play("Fall")
func end_turn():
	pass
