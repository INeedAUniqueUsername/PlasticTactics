extends Spatial
var actions = ["Cast"]

signal attack_started()
signal attack_ended()
var current_attack = null

func _ready():
	connect("attack_ended", self, "set", ["current_attack", null])
func do(a, b):
	a = "Cast"
	current_attack = a
	emit_signal("attack_started")
	$Anim.play(a)
	yield($Anim, "animation_finished")
	emit_signal("attack_ended")
