extends "res://Clickable.gd"
var walking = false
var movePoints = 5
var attackPoints = 1
onready var swordButtons = [$Slash, $Stab, $Shield]
func _ready():
	deselected()
	$Slash.connect("clicked", self, "attack", ["Slash"])
	$Stab.connect("clicked", self, "attack", ["Stab"])
	$Shield.connect("clicked", self, "attack", ["Shield"])
var selected = true
func selected():
	selected = true
func deselected():
	selected = false
func updateButtons():
	if selected:
		if attackPoints > 0:
			for b in swordButtons:
				b.modulate.a = 1.0
				b.get_node("Area").input_ray_pickable = true
		else:
			for b in swordButtons:
				b.modulate.a = 0.5
				b.get_node("Area").input_ray_pickable = false
	else:
		for b in swordButtons:
			b.modulate.a = 0
			b.get_node("Area").input_ray_pickable = false
	
func refresh_move():
	movePoints = 5
	attackPoints = 1
	
	updateButtons()
func attack(move):
	if attackPoints > 0:
		attackPoints -= 1
		$Sprite/VaguelyLegendarySword/Anim.play(move)
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
	if actor.get_parent() == $Sprite:
		return
	hp = max(0, hp - actor.damage)
	emit_signal("damaged")
	$Hurt.play("Hurt")
	if hp == 0:
		pass
		#queue_free()
