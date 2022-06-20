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
func cast_wind():
	var tr = $Pages.get_global_transform()
	var origin = tr.origin
	origin.y = round(origin.y)
	var world = Helper.get_world(self)
	for x in [1, 2, 3, 4, 5]:
		for z in [-2, -1, 0, 1, 2]:
			tr.origin = origin + z * tr.basis.z + x * tr.basis.x
			var y = world.get_ground_y(tr.origin)
			if y == null:
				continue
			tr.origin.y = y + 5
			drop_hail(tr)
	yield(get_tree().create_timer(1.8), "timeout")
const Stone = preload("res://HailStone.tscn")
func drop_hail(tr):
	yield(get_tree().create_timer(randf() * 1.2), "timeout")
	Helper.add_to_world(self, Stone.instance(), tr)
