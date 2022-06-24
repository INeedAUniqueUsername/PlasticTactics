extends Node
func _ready():
	call_deferred("generate")
const Grass = preload("res://Grass.tscn")
func generate():
	var p = get_parent()
	var w = Helper.get_world(self)
	for c in p.get_children():
		if !c.is_in_group("Grass"):
			continue
		if randi()%100 > 25:
			continue
		var g = Grass.instance()
		w.add_child(g)
		g.set_global_transform(c.get_global_transform())
