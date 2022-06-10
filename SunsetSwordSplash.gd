extends Spatial

const Drop = preload("res://SunsetSwordSplashDrop.tscn")
func _ready():
	for i in range(16):
		var d = Drop.instance()
		get_parent().call_deferred("add_child", d)
		d.set_global_transform(get_global_transform())
	var tile = $Tile
	
	var tr = tile.get_global_transform()
	remove_child(tile)
	get_parent().add_child(tile)
	tile.set_global_transform(tr)
	tween_tile(tile)
	
	
	yield(get_tree().create_timer(0.25), "timeout")
	for v in [Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 0, 0), Vector3(1, 0, -1), Vector3(0, 0, -1), Vector3(-1, 0, -1), Vector3(-1, 0, 0), Vector3(-1, 0, 1)]:
		var t = tile.duplicate()
		
		get_parent().call_deferred("add_child", t)
		tr = tile.get_global_transform()
		tr.origin += v
		t.set_global_transform(tr)
		tween_tile(t)
func tween_tile(tile):
	var t = Tween.new()
	t.interpolate_property(tile, "opacity", 0, 0.9, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
	t.interpolate_property(tile, "opacity", 0.9, 0, 1.2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 0.5)
	get_parent().add_child(t)
	t.start()
	yield(t, "tween_all_completed")
	
	yield(get_tree().create_timer(0.5), "timeout")
	t.queue_free()
	tile.queue_free()
