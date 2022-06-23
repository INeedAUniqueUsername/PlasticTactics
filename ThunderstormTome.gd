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
func cast():
	var tr = $Spine.get_global_transform()
	var origin = tr.origin
	origin.y = round(origin.y)
	var world = Helper.get_world(self)
	for x in [1, 2, 3, 4, 5, 6, 7]:
		for z in [-3, -2, -1, 0, 1, 2, 3]:
			var p = world.get_ground_origin(origin + z * tr.basis.z + x * tr.basis.x)
			if p == null:
				continue
			tr.origin = p
			Helper.add_to_world(self, Cloud.instance(), tr)
	yield(get_tree().create_timer(1.8), "timeout")
const Cloud = preload("res://ThunderstormCloud.tscn")
