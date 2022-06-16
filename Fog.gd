extends "res://Damage.gd"

var turnsLeft = 6
func end_turn():
	turnsLeft -= 1
	if turnsLeft == 0:
		$Anim.play("Fade")

var moving = false
func _on_area_entered(area):
	if area.is_in_group("Wind"):
		if moving:
			return
		var inc = area.get_global_transform().basis.x
		#moving = true
		yield(Helper.tween_move(self, inc, 0.75, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
		moving = false
		
