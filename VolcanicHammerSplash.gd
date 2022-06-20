extends Spatial

var damageBonus = 0
func _ready():
	var tile = $Tile
	tile.opacity = 0
	var tr = tile.get_global_transform()
	tween_tile(tile)
	yield(get_tree().create_timer(0.25), "timeout")
	for v in [Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 0, 0), Vector3(1, 0, -1), Vector3(0, 0, -1), Vector3(-1, 0, -1), Vector3(-1, 0, 0), Vector3(-1, 0, 1)]:
		var t = tile.duplicate()
		t.opacity = 0
		add_child(t)
		t.transform.origin += v
		tween_tile(t)
	
	yield(get_tree().create_timer(1.5), "timeout")
	queue_free()
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
