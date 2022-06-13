extends Node

signal stopped()
func _on_area_entered(area):
	if area.is_in_group("StopAttack"):
		emit_signal("stopped")
