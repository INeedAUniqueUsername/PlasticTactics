extends Spatial

var panels = {}
var directionToPos = {}
var chars = []
func _ready():
	for c in get_children():
		if !c.is_in_group("Char"):
			continue
		print(c.name)
		c.connect("clicked", self, "select_char")
		chars.append(c)

var enemyMove = false
func play_enemy_turn():
	if enemyMove:
		return
	var an = $CameraPivot/Camera/Control/Anim
	an.play("Enemy")
	yield(an, "animation_finished")
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

const PANEL = preload("res://Panel.tscn")
func clear_panels():
	directionToPos.clear()
	for pos in panels.keys():
		panels[pos].queue_free()
	panels.clear()
	
var selectedChar
var freeMove = false
func select_char(subject):
	if selectedChar and selectedChar.walking:
		return
	clear_panels()
	selectedChar = subject
	var tr = selectedChar.get_global_transform()
	var start = tr.origin
	var p = PANEL.instance()
	call_deferred("add_child", p)
	p.set_global_transform(tr)
	p.connect("clicked", self, "on_panel_clicked")
	panels[tr.origin] = p
	var placed = []
	placed.append(p)
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
					
					p2.connect("clicked", self, "on_panel_clicked")
					
					next.append(p2)
					call_deferred("add_child", p2)
			i += 1
		for panel in next:
			placed.append(panel)
			yield(panel.get_node("Anim"), "animation_finished")
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
	for p in panels.keys():
		panels[p].get_node("Fade").play("Exit")
		panels.erase(p)
const directions = {
	'N': Vector3(0, 0, -1),
	'E': Vector3(1, 0, 0),
	'S': Vector3(0, 0, 1),
	'W': Vector3(-1, 0, 0),
}
func get_surrounding_squares(origin):
	var result = directions.duplicate(true)
	for key in result.keys():
		result[key] += origin
	return result
func _process(delta):
	var keyDirections = {
		KEY_UP: 'N',
		KEY_RIGHT: 'E',
		KEY_DOWN: 'S',
		KEY_LEFT: 'W'
	}
	
	if selectedChar and !selectedChar.walking and !enemyMove:
		var pos = selectedChar.get_global_transform().origin
		for k in keyDirections.keys():
			var dir = keyDirections[k]
			if Input.is_key_pressed(k):
				var dest = pos + directions[dir]
				if panels.keys().has(dest) and selectedChar.movePoints >= 1.0:
					var t = $Tween
					t.interpolate_property(selectedChar, "walking", true, false, 0.5, Tween.TRANS_LINEAR)
					t.interpolate_property(selectedChar, "global_transform:origin", pos, dest, 0.5, Tween.TRANS_LINEAR)
					t.start()
					selectedChar.movePoints -= 1
	if selectedChar:
		if Input.is_key_pressed(KEY_SPACE):
			selectedChar.jump()
	if Input.is_key_pressed(KEY_A):
		$CameraPivot.rotate_y(PI * delta)
	if Input.is_key_pressed(KEY_D):
		$CameraPivot.rotate_y(-PI * delta)
func get_holder(subject):
	while subject and !subject.is_in_group("CharHolder"):
		subject = subject.get_parent()
	return subject
