extends Spatial
var actions = ["Cast"]

signal attack_started()
signal attack_ended()
var current_attack = null

enum TargetType {
	NONE, LOCATION, CHAR
}
export(TargetType) var targeting = TargetType.NONE
func _ready():
	if targeting != TargetType.NONE:
		targeting = Targeting.new(self, targeting)
	connect("attack_ended", self, "set", ["current_attack", null])

const AP = preload("res://AttackPanel.tscn")
func do(a, attacker):
	cast()

func cast():
	current_attack = "Cast"
	emit_signal("attack_started")
	$Anim.play(current_attack)
	yield($Anim, "animation_finished")
	emit_signal("attack_ended")

class Targeting:
	signal targeting_activated()
	signal target_selected()
	var weapon
	var targetType = TargetType.LOCATION
	var target
	var panels = []
	func _init(weapon, targetType):
		self.weapon = weapon
		self.targetType = targetType
		weapon.connect("attack_ended", self, "set", ["target", null])
	func clear_panels():
		for p in panels:
			p.dismiss()
		panels.clear()
	func selected_char(target):
		clear_panels()
		self.target = target
		emit_signal("target_selected")
	func deselected():
		clear_panels()
	func activate(attacker : Spatial, attackPos = null):
		emit_signal("targeting_activated")
		attacker.connect("deselected", self, "deselected")
		clear_panels()
		
		if !attackPos:
			attackPos = attacker.get_global_transform().origin
		var world = Helper.get_world(weapon)
		for c in world.get_children():
			if !c.is_in_group("Char"):
				continue
			var ap = AP.instance()
			world.add_child(ap)
			ap.transform.origin = c.get_global_transform().origin
			ap.connect("clicked", self, "selected_char", [c])
			#ap.connect("clicked", self, "set", ["target", ap.transform.origin])
			#ap.connect("clicked", self, "clear_panels", [panels])
			#ap.connect("clicked", self, "emit_signal", ["target_selected"])
			panels.append(ap)
