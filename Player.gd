extends "res://Clickable.gd"
var walking = false
var movePoints = 5
var attackPoints = 1

var actButtons = {
	"Cast": null,
	"Slash": null,
	"Stab": null,
	"Smash": null,
	"Shield": null
}
var boostButtons = {}
var sword
func _ready():
	sword = $Sprite/WeaponEquip.get_child(0)
	sword.connect("boost_started", self, "set_boost_button")
	for act in actButtons.keys():
		var button = $AttackButtons.get_node(act)
		button.connect("clicked", self, "attack", [act])
		actButtons[act] = button
	for act in actButtons.keys():
		var button = actButtons[act].get_node("Boost")
		button.set_appearance(false, false)
		button.connect("clicked", button, "set_appearance", [false, false])
		button.connect("clicked", sword, "set_boost")
		
		sword.connect("boost_ended", button, "set_appearance", [false, false])
		boostButtons[act] = button
	$Jump.connect("clicked", self, "jump")
	updateButtons()
var selected = false
func selected():
	selected = true
	updateButtons()
func deselected():
	selected = false
	updateButtons()
func updateButtons():
	var y = 0
	for action in actButtons.keys():
		var vis = selected and action in sword.actions
		var enabled = attackPoints > 0
		var b = actButtons[action]
		b.set_appearance(vis, enabled)
		if vis:
			b.transform.origin = Vector3(0, y, 0)
			y += 0.5
	actButtons["Shield"].set_appearance(selected and "Shield" in sword.actions, attackPoints > 0 and !shielding)
	$Jump.set_appearance(true, true)
func set_boost_button():
	boostButtons[sword.current_attack].set_appearance(true)
var inTurn = false
func start_turn():
	refresh_move()
	inTurn = true
func end_turn():
	inTurn = false
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
		var heal = Helper.get_world(self).get_heal(get_global_transform().origin)
		if !heal.empty():
			hp = min(100, hp + 10)
			emit_signal("damaged")
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
		attackPoints -= 1
		sword.do(move, inTurn)
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
