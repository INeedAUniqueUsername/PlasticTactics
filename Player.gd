extends "res://Clickable.gd"
var walking = false
var movePoints = 5
var attackPoints = 1
onready var swordButtons = [$Slash, $Stab, $Smash]
func _ready():
	$Slash.connect("clicked", self, "attack", ["Slash"])
	$Stab.connect("clicked", self, "attack", ["Stab"])
	$Shield.connect("clicked", self, "attack", ["Shield"])
	$Smash.connect("clicked", self, "attack", ["Smash"])
	$Jump.connect("clicked", self, "jump")
	updateButtons()
	
	for b in [$Stab/Boost, $Slash/Boost, $Smash/Boost]:
		b.set_appearance(false, false)
var selected = false
func selected():
	selected = true
	updateButtons()
func deselected():
	selected = false
	updateButtons()
func setButton(b, enabled):
	b.set_appearance(selected, enabled)
func updateButtons():
		
	for b in swordButtons:
		setButton(b, attackPoints > 0)
	setButton($Shield, attackPoints > 0 and !shielding)
	setButton($Jump, true)
onready var sword = $Sprite/WeaponEquip.get_child(0)
func start_turn():
	refresh_move()
	sword.damage *= 1.5
func end_turn():
	sword.damage /= 1.5
func refresh_move():
	movePoints = 5
	attackPoints = 1
	
	updateButtons()
	
func walk(steps):
	if len(steps) == 0:
		return
	walking = true
	for s in steps:
		yield(Helper.tween_move(self, Helper.directions[s], 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
	walking = false
	
var shielding = false
func attack(move):
	if attackPoints > 0:
		if move == "Shield":
			if shielding:
				return
			shielding = true
		else:
			if shielding:
				shielding = false
				yield(sword.do("Unshield"), "completed")
				
			var boostButtons = {
				"Slash": $Slash/Boost,
				"Stab": $Stab/Boost,
				"Smash": $Smash/Boost
			}
			var b = boostButtons[move]
			b.set_appearance(true, true)
			b.connect("clicked", sword, "set_boost")
			sword.connect("boost_ended", b, "set_appearance", [false, false], CONNECT_ONESHOT)
			
		attackPoints -= 1
		sword.do(move)
	updateButtons()
func jump():
	$Anim.play("Jump")

func get_actor(node):
	while node and !node.is_in_group("Actor"):
		node = node.get_parent()
	return node

var hp = 100
signal damaged()
func _on_area_entered(area):
	if !area.is_in_group("Damage"):
		return
	var actor = get_actor(area)
	
	if actor == sword:
		return
	hp = max(0, hp - actor.damage)
	emit_signal("damaged")
	$Hurt.play("Hurt")
	if hp == 0:
		pass
		#queue_free()
