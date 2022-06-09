extends Spatial
const Beam = preload("res://SunsetBeam.tscn")
onready var b = Beam.instance()
func fire_beam():
	var world = Helper.get_world(self)
	world.call_deferred("add_child", b)
	yield(b, "tree_entered")
	b.set_global_transform(get_global_transform())
	yield(Helper.tween_move(b, get_global_transform().basis.x * 30, 1, Tween.TRANS_LINEAR), "completed")
	b.queue_free()
	b = Beam.instance()
	
