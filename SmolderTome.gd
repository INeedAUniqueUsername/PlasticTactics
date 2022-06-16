extends Spatial
var actions = ["Cast"]

signal attack_ended()
var current_attack = null

func _ready():
	connect("attack_ended", self, "set", ["current_attack", null])
func do(a, b):
	a = "Cast"
	current_attack = a
	$Anim.play(a)
	yield($Anim, "animation_finished")
	emit_signal("attack_ended")
func cast_fire():
	var tr = $Pages.get_global_transform()
	var forward = tr.basis.x
	
	tr.origin.y = floor(tr.origin.y)
	var world = Helper.get_world(self)
	
	var tries = 10
	while !world.has_ground(tr.origin):
		tr.origin += Vector3(0, -1, 0)
		tries -= 1
		if tries == 0:
			return
	for i in range(10):
		tr.origin += forward
		var gr = world.get_ground(tr.origin)
		if !gr or gr.is_in_group("Water"):
			return
		place_fire_tile(tr)
		yield(get_tree().create_timer(0.25), "timeout")
		
const Tile = preload("res://FireTile.tscn")
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
