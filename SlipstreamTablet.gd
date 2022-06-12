extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
const a = preload("res://SunsetSwordSpark.tscn")
func cast_wind():
	
	var wind = a.instance()
	var world = Helper.get_world(self)
	world.add_child(wind)
	var t = Tween.new()
	
	var tr = $Pages.get_global_transform()
	wind.set_global_transform(tr)
	var origin = tr.origin
	var offset = tr.basis.x.rotated(tr.basis.y, rand_range(-PI/3, PI/3)) * 8
	t.interpolate_property(wind, "global_transform:origin", origin, origin + offset, 1.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	world.add_child(t)
	t.start()
	yield(t, "tween_all_completed")
	t.queue_free()
	
