extends Spatial

func _ready():
	$Map.connect("clicked", self, "on_map_clicked")
	$Map.connect("hovered", self, "on_map_hovered")
func on_map_clicked(pos):
	Game.region_pos = pos
	Game.region_code = Helper.pos_to_region_code(pos)
	if load("res://Region%s.tscn" % Game.region_code) == null:
		return
	get_tree().change_scene("res://Battle.tscn")
	
	if true:
		return
	var stage = load("res://Region%s.tscn" % Helper.pos_to_region_code(pos))
	if !stage:
		stage = load("res://MarshLevel.tscn")
	get_tree().change_scene_to(stage)
	pass
func on_map_hovered(pos):
	pass
