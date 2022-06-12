extends Spatial

func _ready():
	var tile = $Tile
	tile.opacity = 0
	tween_tile(tile)
	yield(get_tree().create_timer(0.5), "timeout")
	for v in [Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 0, 0), Vector3(1, 0, -1), Vector3(0, 0, -1), Vector3(-1, 0, -1), Vector3(-1, 0, 0), Vector3(-1, 0, 1)]:
		var t = tile.duplicate()
		call_deferred("add_child", t)
		var tr = tile.get_global_transform()
		tr.origin += v
		t.set_global_transform(tr)
		tween_tile(t)
		
	yield(get_tree().create_timer(0.5), "timeout")
	var plant = $Plant
	
	for angle in [0, PI/2, PI, 3 * PI / 2]:
		for z in [-1, 0, 1]:
			var tr = get_global_transform()
			var origin = tr.basis.x * 1.5 + Vector3(0, 0.5, 0) + tr.basis.z * z
			origin = origin.rotated(tr.basis.y, angle)
			var p = plant.duplicate()
			add_child(p)
			tr.origin = origin + Vector3(0, -1, 0)
			p.set_global_transform(tr)
			p.rotation = Vector3(0, angle, 0)
			tween_plant(p)
	plant.queue_free()
func tween_tile(tile):
	var t = Tween.new()
	t.interpolate_property(tile, "opacity", 0, 0.8, 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	call_deferred("add_child", t)
	yield(t, "tree_entered")
	t.start()
	yield(t, "tween_all_completed")
	t.queue_free()
func tween_plant(tile):
	var t = Tween.new()
	var origin = tile.transform.origin
	t.interpolate_property(tile, "transform:origin", origin, origin + Vector3(0, 1, 0), 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	call_deferred("add_child", t)
	yield(t, "tree_entered")
	t.start()
	yield(t, "tween_all_completed")
	t.queue_free()
