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
	for x in [1, 2, 3, 4, 5, 6, 7]:
		for z in [-4, -3, -2, -1, 0, 1, 2, 3, 4]:
			if randi()%8 != 0:
				continue
			tr.origin = origin + z * tr.basis.z + x * tr.basis.x
			var p = world.get_ground_origin(tr.origin)
			if p == null:
				continue
			tr.origin = p
			erupt_vent(tr)
	yield(get_tree().create_timer(1.8), "timeout")
const Vent = preload("res://EruptVent.tscn")
func erupt_vent(tr):
	yield(get_tree().create_timer(randf() * 1.2), "timeout")
	Helper.add_to_world(self, Vent.instance(), tr)
