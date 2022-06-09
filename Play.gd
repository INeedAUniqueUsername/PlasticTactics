extends Spatial

var panels = {}
var directionToPos = {}
var chars = []
func _ready():
	for c in get_children():
		if !c.is_in_group("Char"):
			continue
		print(c.name)
		c.connect("clicked", self, "select_char", [c])
		chars.append(c)
		if c.is_in_group("Player"):
			call_deferred("select_char", c)

var enemyMove = false
func play_enemy_turn():
	if enemyMove:
		return
	var an = $CameraPivot/Camera/Control/Anim
	an.play("Enemy")
	yield(an, "animation_finished")
	
	if !selectedChar.walking:
		clear_panels()
		place_panels_quick()
	enemyMove=true
	for c in chars:
		if c.is_in_group("Player"):
			continue
		c.play_move()
		yield(c, "moved")
	enemyMove=false
	an.play("Player")
	for c in chars:
		if !c.is_in_group("Player"):
			continue
		c.refresh_move()
	yield(an, "animation_finished")
	if !selectedChar.walking:
		clear_panels()
		place_panels_quick()

const PANEL = preload("res://Panel.tscn")
func clear_panels():
	directionToPos.clear()
	
	for panel in get_children():
		if panel.is_in_group("Panel") and !panels.keys().has(panel):
			panel.get_node("Fade").play("Exit")
	for pos in panels.keys():
		var p = panels[pos]
		#p.queue_free()
		p.get_node("Fade").play("Exit")
		p.disconnect("clicked", self, "on_panel_clicked")
	panels.clear()
	
var selectedChar
var freeMove = false
func select_char(subject):
	if selectedChar and selectedChar.walking:
		return
	selectedChar = subject
	selectedChar.selected()
	clear_panels()
	if enemyMove:
		place_panels_quick()
	else:
		place_panels_slow()
func place_panels_slow():
	var tr = selectedChar.get_global_transform()
	var start = tr.origin
	var p = PANEL.instance()
	p.set_global_transform(tr)
	panels[start] = p
	call_deferred("add_child", p)
	p.connect("clicked", self, "on_panel_clicked", [p])
	var placed = [p]
	yield(p.get_node("Fade"), "animation_finished")
	var i = 0
	while i < len(placed):
		if selectedChar.walking:
			break
		var next = []
		while i < len(placed):
			var adjacent = get_surrounding_squares(placed[i].get_global_transform().origin)
			for direction in adjacent.keys():
				var dest = adjacent[direction]
				if (dest - start).length() < selectedChar.movePoints and !panels.keys().has(dest):
					directionToPos[dest] = direction
					var p2 = PANEL.instance()
					tr.origin = dest
					p2.set_global_transform(tr)
					p2.get_node("Anim").play("FlipTo" + direction)
					panels[dest] = p2
					next.append(p2)
					call_deferred("add_child", p2)
					p2.connect("clicked", self, "on_panel_clicked", [p2])
			i += 1
		for panel in next:
			placed.append(panel)
			yield(panel.get_node("Anim"), "animation_finished")
func place_panels_quick():
	var tr = selectedChar.get_global_transform()
	var start = tr.origin
	var p = PANEL.instance()
	p.set_global_transform(tr)
	panels[start] = p
	call_deferred("add_child", p)
	p.connect("clicked", self, "on_panel_clicked", [p])
	
	yield(p, "tree_entered")
	
	var placed = [p]
	var i = 0
	while i < len(placed):
		var next = []
		while i < len(placed):
			var adjacent = get_surrounding_squares(placed[i].get_global_transform().origin)
			for direction in adjacent.keys():
				var dest = adjacent[direction]
				if (dest - start).length() < selectedChar.movePoints and !panels.keys().has(dest):
					directionToPos[dest] = direction
					var p2 = PANEL.instance()
					tr.origin = dest
					p2.set_global_transform(tr)
					#p2.get_node("Anim").play("FlipTo" + direction)
					panels[dest] = p2
					next.append(p2)
					call_deferred("add_child", p2)
					p2.connect("clicked", self, "on_panel_clicked", [p2])
			i += 1
		for panel in next:
			placed.append(panel)
			#need to wait for this to enter the tree so that transform origins work properly
			yield(panel, "tree_entered")
func on_panel_clicked(panel):
	if !selectedChar:
		return
	var steps = []
	var walked = []
	var pos = panel.get_global_transform().origin
	selectedChar.movePoints -= (pos - selectedChar.get_global_transform().origin).length()
	while directionToPos.keys().has(pos):
		steps.append(directionToPos[pos])
		walked.append(pos)
		pos -= directions[directionToPos[pos]]
	walked.append(pos)
	for p in panels.keys():
		panels[p].disconnect("clicked", self, "on_panel_clicked")
		if p in walked:
			continue
		panels[p].get_node("Fade").play("Exit")
		panels.erase(p)
	steps.invert()
	selectedChar.walking = true
	
	var prevPos = selectedChar.get_global_transform().origin
	for s in steps:
		var nextPos = prevPos + directions[s]
		var t = $Tween
		t.interpolate_property(selectedChar, "global_transform:origin", prevPos, nextPos, 0.5, Tween.TRANS_LINEAR)
		prevPos = nextPos
		t.start()
		yield(t, "tween_completed")
	selectedChar.walking = false
	refresh_panels()
func refresh_panels():
	clear_panels()
	place_panels_quick()
const directions = {
	'N': Vector3(0, 0, -1),
	'E': Vector3(1, 0, 0),
	'S': Vector3(0, 0, 1),
	'W': Vector3(-1, 0, 0),
}
func get_surrounding_squares(origin):
	var result = {}
	for key in directions.keys():
		result[key] = directions[key] + origin
	return result
func _process(delta):
	var keyDirections = {
		KEY_UP: 'N',
		KEY_RIGHT: 'E',
		KEY_DOWN: 'S',
		KEY_LEFT: 'W'
	}
	
	if selectedChar and !selectedChar.walking:
		var pos = selectedChar.get_global_transform().origin
		for k in keyDirections.keys():
			var dir = keyDirections[k]
			if Input.is_key_pressed(k):
				var dest = pos + directions[dir]
				if panels.keys().has(dest) and selectedChar.movePoints >= 1.0:
					var t = $Tween
					var dur = 0.3
					t.interpolate_property(selectedChar, "walking", true, false, dur, Tween.TRANS_LINEAR)
					t.interpolate_property(selectedChar, "global_transform:origin", pos, dest, dur, Tween.TRANS_LINEAR)
					t.start()
					selectedChar.movePoints -= 1
					
					yield(t, "tween_all_completed")
					refresh_panels()
					return
	if selectedChar:
		if Input.is_key_pressed(KEY_Z):
			selectedChar.jump()
		if Input.is_key_pressed(KEY_X):
			selectedChar.attack("Stab")
		if Input.is_key_pressed(KEY_ENTER):
			play_enemy_turn()
	if Input.is_key_pressed(KEY_A):
		$CameraPivot.rotate_y(PI * delta)
	if Input.is_key_pressed(KEY_D):
		$CameraPivot.rotate_y(-PI * delta)
func get_holder(subject):
	while subject and !subject.is_in_group("CharHolder"):
		subject = subject.get_parent()
	return subject
