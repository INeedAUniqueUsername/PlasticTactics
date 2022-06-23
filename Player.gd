extends "res://Clickable.gd"
var walking = false
var movePoints = 4
var attackPoints = 1


class DashState:
	var actor = null
	var panels = []
	var dest_panel = null
	func _init(actor):
		self.actor = actor
		actor.connect("started_moving", self, "clear_panels")
		actor.connect("deselected", self, "clear_panels")
		actor.connect("turn_ended", self, "clear_panels")
	func clear_panels():
		dest_panel = null
		for p in panels:
			p.dismiss()
		panels.clear()
	func set_dest_panel(dest_panel):
		self.dest_panel = dest_panel
		panels.erase(dest_panel)
		for p in panels:
			p.dismiss()
		panels.clear()
		panels = [dest_panel]
	const AttackPanel = preload("res://AttackPanel.tscn")
	func clicked():
		if !actor.inTurn:
			return
		if len(panels) > 0:
			clear_panels()
			return
		var world = Helper.get_world(actor)
		
		var start = actor.get_global_transform().origin
		for x in range(-7, 8, 1):
			for y in range(-7, 8, 1):
				var off = Vector3(x, 0, y)
				var dist = off.length()
				if dist > 7:
					continue
				var ground = world.get_ground_origin(start + off, [], false)
				if ground == null:
					continue
				
				var open = true	
				var normal = off.normalized()
				for i in range(off.length()):
					var p = world.get_ground_origin(start + normal * (i + 1), [], false)
					var good = p != null and world.is_open(p)
					if !good:
						open = false
						break
				if !open:
					continue
				
				var p = AttackPanel.instance()
				p.connect("clicked", self, "set_dest_panel", [p])
				world.add_child(p)
				var tr = p.get_global_transform()
				tr.origin = ground
				p.set_global_transform(tr)
				panels.append(p)
		if false:
			for a in world.get_enemy_chars():
				var off = a.get_global_transform().origin - actor.get_global_transform().origin
				if off.length() > 6:
					continue
				var p = AttackPanel.instance()
				p.connect("clicked", self, "set_dest_panel", [p])
				world.add_child(p)
				p.set_global_transform(a.get_global_transform())
				panels.append(p)
	var off = null
	func start_attack():
		if dest_panel and actor.inTurn:
			actor.movePoints = 0
			
			off = dest_panel.get_global_transform().origin - actor.get_global_transform().origin
			yield(Helper.tween_move(actor, off, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
			return
		yield(actor.get_tree(), "idle_frame")
	func end_attack():
		clear_panels()
		if off:
			yield(Helper.tween_move(actor, -off, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
			off = null
			return
		yield(actor.get_tree(), "idle_frame")
onready var dash = DashState.new(self)

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
	for c in $Sprite/WeaponEquip.get_children():
		c.hide()
	var w = $Sprite/WeaponEquip.get_child(0)
	w.show()
	set_weapon(w)
	for act in actButtons.keys():
		var button = $AttackButtons.get_node(act)
		button.connect("clicked", self, "attack", [act])
		actButtons[act] = button
		
		button = button.get_node("Boost")
		button.set_appearance(false, false)
		button.connect("clicked", button, "set_appearance", [false, false])
		boostButtons[act] = button
		
	var otherButtons = {
		$Jump: "jump",
		$Item: "toggle_item_menu",
		$Switch: "switch_weapon"
	}
	for b in otherButtons:
		b.connect("clicked", self, otherButtons[b])
	$Dash.connect("clicked", dash, "clicked")
	updateButtons()
var selected = false
signal selected()
signal deselected()
func selected():
	selected = true
	emit_signal("selected")
	updateButtons()
func deselected():
	selected = false
	emit_signal("deselected")
	updateButtons()
func updateButtons():
	var y = 0
	
	var canAttack = attackPoints > 0
	for action in actButtons.keys():
		var vis = selected and action in sword.actions
		var b = actButtons[action]
		b.set_appearance(vis, canAttack)
		if vis:
			b.transform.origin = Vector3(0, y, 0)
			y += 0.5
	
	var otherButtons = {
		$Item: !sword.current_attack,
		$Switch: !sword.current_attack,
		$Jump: true,
		$Dash: inTurn and attackPoints > 0
	}
	for b in otherButtons.keys():
		b.set_appearance(selected, otherButtons[b])
	
	toggle_item_menu(!itemButtons.keys().empty())
func set_boost_button():
	var b = boostButtons[sword.current_attack]
	b.connect("clicked", sword, "set_boost")
	sword.connect("boost_ended", b, "set_appearance", [false, false])
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
		elif a.is_in_group("Hail"):
			hp = max(0, hp - 10)
			emit_signal("damaged")
			$Hurt.play("Hurt")
signal turn_started()
signal turn_ended()
var inTurn = false
func start_turn():
	refresh_move()
	inTurn = true
	emit_signal("turn_started")
	check_standing_areas()
	updateButtons()
func end_turn():
	inTurn = false
	emit_signal("turn_ended")
	check_standing_areas()
	updateButtons()
func refresh_move():
	movePoints = 4
	attackPoints = 1
	updateButtons()
signal started_moving()
signal moved()
func walk(pathPanels):
	if len(pathPanels) == 0:
		return
	walking = true
	emit_signal("started_moving")
	for panel in pathPanels:
		var g = Helper.get_world(self).get_ground(get_global_transform().origin)
		var time = 0.3
		#print(g.name)
		if g.get_parent().is_in_group("River"):
			time = 0.9
		yield(Helper.tween_move(self, panel.get_global_transform().origin - get_global_transform().origin, time, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
		check_standing_areas()
	walking = false
	emit_signal("moved")
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
		yield(dash.start_attack(), "completed")
		sword.do(move, inTurn)
		yield(sword, "attack_ended")
		yield(dash.end_attack(), "completed")
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
	ItemTypes.Oasisphere,
	ItemTypes.Dynamite,
	ItemTypes.Oasisphere,
	ItemTypes.Oasisphere,
	ItemTypes.Oasisphere,
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
		var canAttack = attackPoints > 0
		for item in inventory:
			var b = SpriteButton.instance()
			itemButtons[i] = b
			$Item.add_child(b)
			b.transform.origin = Vector3(-0.5, i * 0.5, 0)
			b.connect("clicked", self, "use_item", [i])
			
			b.set_appearance(selected, canAttack)
			
			var s = StdSprite.instance()
			s.texture = item.sprite
			s.opacity = b.opacity
			b.add_child(s)
			s.transform.origin = Vector3(0, 0, 0.025)
			i += 1
const Oasisphere = preload("res://Oasisphere.tscn")
func use_item(index):
	var item = inventory[index]
	match item:
		ItemTypes.Oasisphere:
			var s = Oasisphere.instance()
			Helper.add_to_world(self, s, get_global_transform())
			s.transform.origin += Vector3(0, 1, 0)
			s.vel = Vector3(0, 9.8/2, 0)
		ItemTypes.Dynamite:
			
			var s = preload("res://Dynamite.tscn").instance()
			var tr = get_global_transform()
			tr.origin += tr.basis.x
			Helper.add_to_world(self, s, tr)
			
	inventory.remove(index)
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
