extends Node
func _ready():
	call_deferred("generate")
const Grass = preload("res://Grass.tscn")
func generate():
	var p = get_parent()
	for c in p.get_children():
		if !c.is_in_group("Grass"):
			continue
		c.transform.origin.y += randf() * 0.25
