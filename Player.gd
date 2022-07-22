extends "res://Clickable.gd"
var walking = false
var movePoints = 4
var attackPoints = 1
class DashState:
	var actor = null
	var panels = []
	var dest_panel = null
	var freeMovePoints = 4
	func _init(actor):
		self.actor = actor
		actor.connect("started_moving", self, "clear_panels")
		actor.connect("deselected", self, "clear_panels")
		actor.connect("turn_ended", self, "clear_panels")
	signal dest_changed()
	func clear_panels():
		dest_panel = null
		emit_signal("dest_changed")
		for p in panels:
			p.dismiss()
		panels.clear()
	func set_dest_panel(dest_panel):
		self.dest_panel = dest_panel
		emit_signal("dest_changed")
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
			#actor.move.refresh_panels()
			return
			
		#actor.move.clear_panels()
		var world = Helper.get_world(actor)
		
		if world.get_ground_origin(actor.get_global_transform().origin, [], false) == null:
			return
		
		var radius = actor.movePoints + freeMovePoints #actor.movePoints * 2
		var start = actor.get_global_transform().origin
		for x in range(-radius, radius + 1, 1):
			for y in range(-radius, radius + 1, 1):
				var off = Vector3(x, 0, y)
				var dist = abs(off.x) + abs(off.z)
				if dist > radius:
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
	var off = null
	func start_action():
		if dest_panel and actor.inTurn:
			actor.move.clear_panels()
			off = dest_panel.get_global_transform().origin - actor.get_global_transform().origin
			var cost = abs(off.x) + abs(off.z) - freeMovePoints
			actor.movePoints -= clamp(cost, 0, actor.movePoints)
			yield(Helper.tween_move(actor, off, off.length()/10.0, Tween.TRANS_LINEAR), "completed")
			return
		yield(actor.get_tree(), "idle_frame")
	func end_action():
		clear_panels()
		if off:
			yield(Helper.tween_move(actor, -off, off.length()/10.0, Tween.TRANS_LINEAR), "completed")
			off = null
			actor.move.refresh_panels()
			return
		yield(actor.get_tree(), "idle_frame")
			
			

class MoveState:
	var actor
	var gridPanels = {}
	
	const directions = {
		'N': Vector3(0, 0, -1),
		'E': Vector3(1, 0, 0),
		'S': Vector3(0, 0, 1),
		'W': Vector3(-1, 0, 0),
	}
	func _init(actor):
		self.actor = actor
		actor.connect("selected", self, "on_actor_selected")
		actor.connect("deselected", self, "clear_panels")
		actor.connect("turn_ended", self, "on_actor_turn_ended")
		actor.connect("moved", self, "refresh_panels")
	func process():
		var keyDirections = {
			KEY_UP: 'N',
			KEY_RIGHT: 'E',
			KEY_DOWN: 'S',
			KEY_LEFT: 'W'
		}
		
		if !actor.walking:
			var pos = actor.get_global_transform().origin
			for k in keyDirections.keys():
				var dir = keyDirections[k]
				if Input.is_key_pressed(k):
					var dest = pos + directions[dir]
					if gridPanels.keys().has(dest) and actor.movePoints >= 1.0:
						
						actor.movePoints -= 1
						yield(actor.walk([gridPanels[dest].panel]), "completed")
						refresh_panels()
						return
	func on_actor_selected():
		if actor.walking:
			return
		clear_panels()
		if actor.inTurn:
			place_panels_slow()
		else:
			place_panels_quick()
	func on_actor_turn_ended():
		if !actor.walking:
			clear_panels()
			if actor.selected:
				place_panels_quick()
	const PANEL = preload("res://Panel.tscn")
	func clear_panels():
		panelsReset = true
		for entry in gridPanels.values():
			var p = entry.panel
			p.dismiss()
			p.disconnect("clicked", self, "on_panel_clicked")
		gridPanels.clear()
		
	var panelsReset = false
	func place_panels_slow():
		var w = Helper.get_world(actor)
		var tr = actor.get_global_transform()
		var start = tr.origin
		var p = PANEL.instance()
		gridPanels[start] = GridEntry.new(p, start)
		p.set_global_transform(tr)
		w.call_deferred("add_child", p)
		p.connect("clicked", self, "on_panel_clicked", [p])
		var placed = [p]
		yield(p.get_node("Fade"), "animation_finished")
		panelsReset = false
		var i = 0
		while i < len(placed):
			if !actor.selected or actor.walking or panelsReset:
				#clear_panels()
				return
			var next = []
			while i < len(placed):
				var current = placed[i]
				if current.dismissed:
					return
				var adjacent = w.get_surrounding_squares(current.get_global_transform().origin)
				for direction in adjacent.keys():
					var dest = adjacent[direction]
					
					var entry = get_ground_panel(w, current, dest)
					if entry == null:
						continue
					gridPanels[entry.pos] = entry
					p = entry.panel
					p.get_node("Anim").play("FlipTo" + direction)
					next.append(p)
					w.call_deferred("add_child", p)
					p.connect("clicked", self, "on_panel_clicked", [p])
				i += 1
			for panel in next:
				placed.append(panel)
				yield(panel.get_node("Anim"), "animation_finished")
	func place_panels_quick():
		var w = Helper.get_world(actor)
		var tr = actor.get_global_transform()
		var start = tr.origin
		var p = PANEL.instance()
		p.set_global_transform(tr)
		gridPanels[start] = GridEntry.new(p, start)
		w.call_deferred("add_child", p)
		p.connect("clicked", self, "on_panel_clicked", [p])
		
		yield(p, "tree_entered")
		
		var placed = [p]
		var i = 0
		while i < len(placed):
			var next = []
			while i < len(placed):
				var current = placed[i]
				var adjacent = w.get_surrounding_squares(current.get_global_transform().origin)
				for direction in adjacent.keys():
					var dest = adjacent[direction]
					var entry = get_ground_panel(w, current, dest)
					if entry == null:
						continue
					gridPanels[entry.pos] = entry
					p = entry.panel
					next.append(p)
					w.call_deferred("add_child", p)
					p.connect("clicked", self, "on_panel_clicked", [p])
				i += 1
			for panel in next:
				placed.append(panel)
				#need to wait for this to enter the tree so that transform origins work properly
				yield(panel, "tree_entered")

	func refresh_panels():
		panelsReset = true
		clear_panels()
		place_panels_quick()
	func get_ground_panel(world, prevPanel: Spatial, pos: Vector3):
		var g = world.get_ground_origin(pos)
		if g == null:
			return null
		pos = Vector3(pos.x, g.y, pos.z)
		
		if gridPanels.keys().has(pos):
			return null
			
		if !world.is_open(pos):
			return null
			
		var prevPos = prevPanel.get_global_transform().origin
		var distance = 1 + gridPanels[prevPos].distance
		if distance > actor.movePoints:
			return null
		
		
		var panel = PANEL.instance()
		
		var tr = panel.get_global_transform()
		tr.origin = pos
		panel.set_global_transform(tr)
		
		
		return GridEntry.new(panel, pos, prevPanel, prevPos, distance)
		
	func on_panel_clicked(clickedPanel):
		#var dest = clickedPanel.get_global_transform().origin
		#ownerChar.movePoints -= (dest - ownerChar.get_global_transform().origin).length()
		var destPanel = clickedPanel
		var destPos = destPanel.get_global_transform().origin
		actor.movePoints -= gridPanels[destPos].distance
		var pathPanels = []
		while destPanel:
			pathPanels.append(destPanel)
			destPanel = gridPanels[destPanel.get_global_transform().origin].prevPanel
		pathPanels.invert()
		if len(pathPanels) == 1:
			return
		for pos in gridPanels.keys():
			var panel = gridPanels[pos].panel
			panel.disconnect("clicked", self, "on_panel_clicked")
			if panel in pathPanels:
				continue
			panel.dismiss()
			gridPanels.erase(pos)
		pathPanels.remove(0)
		yield(actor.walk(pathPanels), "completed")
	class GridEntry:
		var panel
		var prevPanel
		var distance
		
		var pos
		var prevPos
		func _init(panel: Spatial, pos = null, prevPanel: Spatial = null, prevPos = null, distance: float = 0):
			self.panel = panel
			self.pos = pos
			self.prevPanel = prevPanel
			self.prevPos = prevPos
			self.distance = distance
class Targeter:
	const AP = preload("res://AttackPanel.tscn")
	signal targeting_activated()
	signal target_selected()
	var panels = []
	var actor
	func _init(actor):
		self.actor = actor
		actor.connect("started_moving", self, "clear_panels")
		actor.connect("deselected", self, "clear_panels")
	func clear_panels():
		for p in panels:
			p.dismiss()
		panels.clear()
	func selected_char(targeting, target):
		clear_panels()
		targeting.target = target
		emit_signal("target_selected")
	func selected_location(targeting, target):
		clear_panels()
		targeting.target = target
		emit_signal("target_selected")
	const TargetType = preload("res://Targeting.gd").TargetType
	func activate(targeting, attackPos = null):
		emit_signal("targeting_activated")
		clear_panels()
		if !attackPos:
			attackPos = actor.get_global_transform().origin
		var world = Helper.get_world(actor)
		
		match targeting.targetType:
			TargetType.LOCATION:
				
				var radius = 12 #actor.movePoints * 2
				var start = actor.get_global_transform().origin
				for x in range(-radius, radius + 1, 1):
					for y in range(-radius, radius + 1, 1):
						var off = Vector3(x, 0, y)
						var dist = abs(off.x) + abs(off.z)
						if dist > radius:
							continue
						var ground = world.get_ground_origin(start + off, [], true)
						if ground == null:
							continue
						var ap = AP.instance()
						world.add_child(ap)
						ap.transform.origin = ground
						ap.connect("clicked", self, "selected_location", [targeting, ground])
						panels.append(ap)
			TargetType.CHAR:
				for c in world.get_children():
					if !c.is_in_group("Char"):
						continue
					var ap = AP.instance()
					world.add_child(ap)
					ap.transform.origin = c.get_global_transform().origin
					ap.connect("clicked", self, "selected_char", [targeting, c])
					#ap.connect("clicked", self, "set", ["target", ap.transform.origin])
					#ap.connect("clicked", self, "clear_panels", [panels])
					#ap.connect("clicked", self, "emit_signal", ["target_selected"])
					panels.append(ap)
onready var dash = DashState.new(self)
onready var move = MoveState.new(self)
onready var targeter = Targeter.new(self)
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
	for e in ["selected", "deselected", "moved", "turn_started", "turn_ended"]:
		connect(e, self, "updateButtons")
	updateButtons()
var selected = false
signal selected()
signal deselected()
func selected():
	selected = true
	emit_signal("selected")
func deselected():
	selected = false
	emit_signal("deselected")
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
		$Dash: inTurn and attackPoints > 0 #and movePoints > 0
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
	check_standing_areas()
	emit_signal("turn_started")
func end_turn():
	inTurn = false
	check_standing_areas()
	emit_signal("turn_ended")
func refresh_move():
	movePoints = 4
	attackPoints = 1
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
func attack(move):
	if attackPoints > 0:
		if 'targeting' in sword:
			var targeting = sword.targeting
			if targeting and !targeting.target:
				var pos = get_global_transform().origin
				if dash.dest_panel:
					pos = dash.dest_panel.get_global_transform().origin
				targeter.activate(targeting, pos)
				yield(targeter, "target_selected")
				if !(attackPoints > 0):
					return
			
		attackPoints -= 1
		updateButtons()
		yield(dash.start_action(), "completed")
		sword.do(move, self)
		yield(sword, "attack_ended")
		yield(dash.end_action(), "completed")
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
	inventory.remove(index)
	attackPoints -= 1
	updateButtons()
	
	yield(dash.start_action(), "completed")
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
	yield(dash.end_action(), "completed")
			
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
	if 'active' in actor and !actor.active:
		return
	hp = max(0, hp - actor.damage)
	emit_signal("damaged")
	$Hurt.play("Hurt")
	if hp == 0:
		pass
		#queue_free()
