extends Spatial
var actions = ["Cast"]
const a = preload("res://SlipstreamWind.tscn")

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
	origin.y = floor(tr.origin.y)
	var tries = 10
	var world = Helper.get_world(self)
	while !world.has_ground(origin):
		origin += Vector3(0, -1, 0)
		tries -= 1
		if tries == 0:
			return
	for x in [1, 2, 3, 4, 5]:
		for z in [-2, -1, 0, 1, 2]:
			tr.origin = origin + z * tr.basis.z + x * tr.basis.x
			Helper.add_to_world(self, Fog.instance(), tr)
	yield(get_tree().create_timer(1.8), "timeout")
const Fog = preload("res://ScaldFog.tscn")
