extends Spatial

var damage = 20

var turnsLeft = 2
func start_turn():
	if turnsLeft > 0:
		turnsLeft -= 1
	else:
		destroy()
func end_turn():
	pass
var destroyed = false
func destroy():
	if destroyed:
		return
	destroyed = true
	$Anim.play("Fall")
