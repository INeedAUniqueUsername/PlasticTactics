extends Node

signal attack_stopped()
signal wind_blocked()
func _on_area_entered(area):
	if area.is_in_group("StopAttack"):
		emit_signal("attack_stopped")
	if area.is_in_group("BlockWind"):
		emit_signal("wind_blocked")
