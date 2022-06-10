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
var selected = false
func selected():
	selected = true
	updateButtons()
func deselected():
	selected = false
	updateButtons()
func setButton(b, enabled):
	if !selected:
		b.modulate.a = 0
		b.get_node("Area").input_ray_pickable = false
	if enabled:
		b.modulate.a = 1.0
		b.get_node("Area").input_ray_pickable = true
	else:
		b.modulate.a = 0.5
		b.get_node("Area").input_ray_pickable = false
func updateButtons():
		
	for b in swordButtons:
		setButton(b, attackPoints > 0)
	setButton($Shield, attackPoints > 0 and !shielding)
	setButton($Jump, true)
onready var sword = $Sprite/SwordHolder.get_child(0)
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
		var an = sword.get_node("Anim")
		if move == "Shield":
			if shielding:
				return
			shielding = true
		else:
			if shielding:
				shielding = false
				an.play("Unshield")
				yield(an, "animation_finished")
		attackPoints -= 1
		an.play(move)
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
