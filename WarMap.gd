extends Spatial

func _ready():
	$Map.connect("clicked", self, "on_map_clicked")
	$Map.connect("hovered", self, "on_map_hovered")
func on_map_clicked(pos):
	Game.region_pos = pos
	
	return
	
	if Game.get_region(pos) == null:
		return
	get_tree().change_scene("res://Battle.tscn")
func on_map_hovered(pos):
	pass
func _enter_region():
	Game.region_pos = Helper.flatten_3d($MapOrigin/Spatial.transform.origin)
	if Game.get_region(Game.region_pos) == null:
		return
	get_tree().change_scene("res://Battle.tscn")
	pass # Replace with function body.
