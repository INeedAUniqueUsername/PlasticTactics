extends Spatial

var tiles = []
var plants = []
func _ready():
	var tile = $Tile
	tile.opacity = 0
	#tile.transform.origin = Vector3(0, 0, 0)
	show_tile(tile)
	tiles.append(tile)
	yield(get_tree().create_timer(0.5), "timeout")
	for v in [Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 0, 0), Vector3(1, 0, -1), Vector3(0, 0, -1), Vector3(-1, 0, -1), Vector3(-1, 0, 0), Vector3(-1, 0, 1)]:
		var t = tile.duplicate()
		call_deferred("add_child", t)
		t.transform.origin += v
		show_tile(t)
		tiles.append(t)
	#tile.queue_free()
	yield(get_tree().create_timer(0.5), "timeout")
	var plant = $Plant
	for angle in [0, PI/2, PI, 3 * PI / 2]:
		for z in [-1, 0, 1]:
			var p = plant.duplicate()
			p.transform.origin = Vector3(1.5, 0.5 - 1, z).rotated(Vector3(0, 1, 0), angle)
			add_child(p)
			p.rotation = Vector3(0, angle, 0)
			show_plant(p)
			plants.append(p)
	plant.queue_free()
func show_tile(tile):
	var t = Tween.new()
	t.interpolate_property(tile, "opacity", 0, 0.8, 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	yield(add_tween(t), "completed")
func hide_tile(tile):
	var t = Tween.new()
	t.interpolate_property(tile, "opacity", 0.8, 0, 1, Tween.TRANS_QUAD, Tween.EASE_IN)
	yield(add_tween(t), "completed")
func show_plant(tile):
	var t = Tween.new()
	var origin = tile.transform.origin
	t.interpolate_property(tile, "transform:origin", origin, origin + Vector3(0, 1, 0), 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	yield(add_tween(t), "completed")
func hide_plant(tile):
	var t = Tween.new()
	var origin = tile.transform.origin
	t.interpolate_property(tile, "transform:origin", origin, origin - Vector3(0, 1, 0), 1, Tween.TRANS_QUAD, Tween.EASE_IN)
	yield(add_tween(t), "completed")
func add_tween(t):
	call_deferred("add_child", t)
	yield(t, "tree_entered")
	t.start()
	yield(t, "tween_all_completed")
	t.queue_free()
var turnsLeft = 6
func start_turn():
	turnsLeft -= 1
	if turnsLeft == 0:
		for t in tiles:
			hide_tile(t)
		yield(get_tree().create_timer(1), "timeout")
		for p in plants:
			hide_plant(p)
		yield(get_tree().create_timer(1), "timeout")
		queue_free()
