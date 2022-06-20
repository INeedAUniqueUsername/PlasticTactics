extends Node
func _on_area_entered(area):
	var actor = Helper.get_actor(area)
	if actor and actor.is_in_group("Hammer") and actor.active and actor.current_attack != null:
		get_parent().destroy()
