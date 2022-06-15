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
func set_weapon(w):
	sword = w
	sword.connect("boost_started", self, "set_boost_button")
	sword.connect("attack_ended", self, "updateButtons", [], CONNECT_DEFERRED)
func _ready():
	set_weapon($Sprite/WeaponEquip.get_child(0))
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
	$Item.connect("clicked", self, "toggle_item_menu")
	$Switch.connect("clicked", self, "switch_weapon")
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
	
	
	$Item.set_appearance(selected, !sword.current_attack)
	$Switch.set_appearance(selected, !sword.current_attack)
	$Jump.set_appearance(selected, true)
func set_boost_button():
	var b = boostButtons[sword.current_attack]
	b.connect("clicked", sword, "set_boost")
	b.set_appearance(true)
	
const healEffect = preload("res://HealEffect.tscn")
func check_standing_areas():
	for a in $Sprite/Area.get_overlapping_areas():
		if a.is_in_group("Heal"):
			hp = min(100, hp + 10)
			emit_signal("damaged")
			var he = healEffect.instance()
			he.set_global_transform(get_global_transform())
			Helper.get_world(self).add_child(he)
		elif a.is_in_group("Burning"):
			hp = max(0, hp - 10)
			emit_signal("damaged")
			$Hurt.play("Hurt")
var inTurn = false
func start_turn():
	refresh_move()
	inTurn = true
	check_standing_areas()
func end_turn():
	inTurn = false
	check_standing_areas()
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
		check_standing_areas()
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
func switch_weapon():
	sword.hide()
	$Sprite/WeaponEquip.remove_child(sword)
	$Sprite/WeaponEquip.add_child(sword)
	set_weapon($Sprite/WeaponEquip.get_child(0))
	sword.show()
	updateButtons()
	
var inventory = [
	{
		"sprite": preload("res://Oasisphere.png")
	},{
		"sprite": preload("res://Oasisphere.png")
	},{
		"sprite": preload("res://Oasisphere.png")
	},{
		"sprite": preload("res://Oasisphere.png")
	},{
		"sprite": preload("res://Oasisphere.png")
	},
]
var itemButtons = {}
const StdSprite = preload("res://StdSprite.tscn")
const SpriteButton = preload("res://SpriteButton3D.tscn")
func toggle_item_menu(vis = null):
	if vis == null:
		vis = itemButtons.empty()
	for i in itemButtons.keys():
		itemButtons[i].queue_free()
		itemButtons.erase(i)
	if vis:
		var i = 0
		for item in inventory:
			var b = SpriteButton.instance()
			itemButtons[item] = b
			$Item.add_child(b)
			b.transform.origin = Vector3(-0.5, i * 0.5, 0)
			b.connect("clicked", self, "use_item", [item])
			
			b.set_appearance(selected, attackPoints > 0)
			
			var s = StdSprite.instance()
			s.texture = item.sprite
			s.opacity = b.opacity
			b.add_child(s)
			s.transform.origin = Vector3(0, 0, 0.025)
			i += 1
const Oasisphere = preload("res://Oasisphere.tscn")
func use_item(item):
	var s = Oasisphere.instance()
	s.set_global_transform(get_global_transform())
	s.transform.origin += Vector3(0, 1, 0)
	s.vel = Vector3(0, 9.8/2, 0)
	Helper.get_world(self).add_child(s)
	inventory.erase(item)
	toggle_item_menu(true)
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
