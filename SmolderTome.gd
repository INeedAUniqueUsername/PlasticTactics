extends Spatial
func cast():
	var tr = get_global_transform()
	var forward = tr.basis.x
	var world = Helper.get_world(self)
	var origin = world.get_ground_origin(tr.origin)
	if origin == null:
		return
	tr.origin = origin
	for i in range(10):
		tr.origin += forward
		var gr = world.get_ground(tr.origin)
		if !gr or gr.is_in_group("Water"):
			return
		place_fire_tile(gr.get_global_transform())
		yield(get_tree().create_timer(0.25), "timeout")
		
const Tile = preload("res://SmolderTile.tscn")
func place_fire_tile(tr):
	var tile = Tile.instance()
	tile.set_global_transform(tr)
	
	var world = Helper.get_world(self)
	world.add_child(tile)
	
	#var t = Tween.new()
	#t.interpolate_property(tile, "scale", Vector3(0, 0, 0), Vector3(1, 1, 1), 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	#world.add_child(t)
	#t.start()
	#yield(t, "tween_all_completed")
	#t.queue_free()
