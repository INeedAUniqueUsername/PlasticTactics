extends Spatial
var turnsLeft = 4
func start_turn():
	if turnsLeft > 0:
		turnsLeft -= 1
	else:
		destroy()
var destroyed = false
func destroy():
	if destroyed:
		return
	destroyed = true
	$Anim.play("Fade")
