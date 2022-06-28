extends Spatial
var actions = ["Cast"]

signal attack_started()
signal attack_ended()
var current_attack = null

const TargetType = preload("res://Targeting.gd").TargetType
export(TargetType) var targeting = TargetType.NONE
func _ready():
	if targeting != TargetType.NONE:
		targeting = Targeting.new(self, targeting)
	connect("attack_ended", self, "set", ["current_attack", null])
func do(a, attacker):
	cast()
func cast():
	current_attack = "Cast"
	emit_signal("attack_started")
	$Anim.play(current_attack)
	yield($Anim, "animation_finished")
	emit_signal("attack_ended")
class Targeting:
	var targetType = TargetType.LOCATION
	var target
	func _init(weapon, targetType):
		weapon.connect("attack_ended", self, "set", ["target", null])
		self.targetType = targetType
