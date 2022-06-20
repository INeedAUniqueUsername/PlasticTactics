extends Spatial

var gridPanels = {}
var chars = []
func _ready():
	for c in get_children():
		if !c.is_in_group("Char"):
			continue
		print(c.name)
		c.connect("clicked", self, "select_char", [c])
		chars.append(c)
		c.connect("tree_exited", self, "remove_char", [c])
		if c.is_in_group("Player"):
			selectedChar = c
	play_player_turn()
	$CameraPivot/Camera/Control/TextureButton.connect("pressed", self, "play_enemy_turn")
func remove_char(c):
	chars.erase(c)
var enemyMove = false
func get_player_chars():
	var r = []
	for c in chars:
		if c.is_in_group("Player"):
			r.append(c)
	return r
func get_enemy_chars():
	var r = []
	for c in chars:
		if !c.is_in_group("Player"):
			r.append(c)
	return r
func get_misc_actors():
	var r = []
	for c in get_children():
		if !c.is_in_group("Actor"):
			continue
		if c.is_in_group("Char"):
			continue
		r.append(c)
	return r
func play_player_turn():
	
	var an = $CameraPivot/Camera/Control/Anim
	an.play("Player")
	yield(an, "animation_finished")
	
	for c in get_misc_actors():
		if c.has_method("start_turn"):
			c.start_turn()
	for c in get_player_chars():
		c.start_turn()
	if selectedChar:
		selectedChar.selected()
		if !selectedChar.walking:
			clear_panels()
			place_panels_slow()
func play_enemy_turn():
	if enemyMove:
		return
		
	
	for c in get_player_chars():
		c.end_turn()
		
	for c in get_misc_actors():
		if c.has_method("end_turn"):
			c.end_turn()
		
		
	var an = $CameraPivot/Camera/Control/Anim
	an.play("Enemy")
	yield(an, "animation_finished")
	
	
	
	if !selectedChar.walking:
		clear_panels()
		place_panels_quick()
		
	
	for c in get_misc_actors():
		if c.has_method("start_turn"):
			c.start_turn()
	enemyMove=true
	for c in get_enemy_chars():
		c.start_turn()
	for c in get_enemy_chars():
		c.play_move()
		yield(c, "moved")
	for c in get_enemy_chars():
		c.end_turn()
	enemyMove=false
	for c in get_misc_actors():
		if c.has_method("end_turn"):
			c.end_turn()
	
	play_player_turn()

const PANEL = preload("res://Panel.tscn")
func clear_panels():
	
	for panel in get_children():
		if panel.is_in_group("Panel") and !gridPanels.keys().has(panel):
			panel.get_node("Fade").play("Exit")
	for pos in gridPanels.keys():
		var p = gridPanels[pos].panel
		#p.queue_free()
		p.get_node("Fade").play("Exit")
		p.disconnect("clicked", self, "on_panel_clicked")
	gridPanels.clear()
	
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
var panelsReset = false
func place_panels_slow():
	panelsReset = true
	var tr = selectedChar.get_global_transform()
	var start = tr.origin
	var p = PANEL.instance()
	p.set_global_transform(tr)
	gridPanels[start] = GridEntry.new(p, start)
	
	call_deferred("add_child", p)
	p.connect("clicked", self, "on_panel_clicked", [p, selectedChar])
	var placed = [p]
	yield(p.get_node("Fade"), "animation_finished")
	panelsReset = false
	var i = 0
	while i < len(placed):
		if selectedChar.walking or panelsReset:
			break
		var next = []
		while i < len(placed):
			var current = placed[i]
			var adjacent = get_surrounding_squares(current.get_global_transform().origin)
			for direction in adjacent.keys():
				var dest = adjacent[direction]
				
				var entry = get_ground_panel(current, dest)
				if entry == null:
					continue
				gridPanels[entry.pos] = entry
				var p2 = entry.panel
				p2.get_node("Anim").play("FlipTo" + direction)
				next.append(p2)
				call_deferred("add_child", p2)
				p2.connect("clicked", self, "on_panel_clicked", [p2, selectedChar])
			i += 1
		for panel in next:
			placed.append(panel)
			yield(panel.get_node("Anim"), "animation_finished")
func place_panels_quick():
	var tr = selectedChar.get_global_transform()
	var start = tr.origin
	var p = PANEL.instance()
	p.set_global_transform(tr)
	gridPanels[start] = GridEntry.new(p, start)
	call_deferred("add_child", p)
	p.connect("clicked", self, "on_panel_clicked", [p, selectedChar])
	
	yield(p, "tree_entered")
	
	var placed = [p]
	var i = 0
	while i < len(placed):
		var next = []
		while i < len(placed):
			var current = placed[i]
			var adjacent = get_surrounding_squares(current.get_global_transform().origin)
			for direction in adjacent.keys():
				var dest = adjacent[direction]
				var entry = get_ground_panel(current, dest)
				if entry == null:
					continue
				gridPanels[entry.pos] = entry
				var p2 = entry.panel
				next.append(p2)
				call_deferred("add_child", p2)
				p2.connect("clicked", self, "on_panel_clicked", [p2, selectedChar])
			i += 1
		for panel in next:
			placed.append(panel)
			#need to wait for this to enter the tree so that transform origins work properly
			yield(panel, "tree_entered")
func get_ground_panel(prevPanel: Spatial, pos: Vector3):
	var y = get_ground_y(pos)
	if y == null:
		return null
	pos = Vector3(pos.x, y, pos.z)
	
	if gridPanels.keys().has(pos):
		return null
		
	if !is_open(pos):
		return null
		
	var prevPos = prevPanel.get_global_transform().origin
	var distance = 1 + gridPanels[prevPos].distance
	if distance > selectedChar.movePoints:
		return null
	
	
	var panel = PANEL.instance()
	
	var tr = panel.get_global_transform()
	tr.origin = pos
	panel.set_global_transform(tr)
	
	
	return GridEntry.new(panel, pos, prevPanel, prevPos, distance)
	
func on_panel_clicked(clickedPanel, ownerChar):
	#var dest = clickedPanel.get_global_transform().origin
	#ownerChar.movePoints -= (dest - ownerChar.get_global_transform().origin).length()
	var destPanel = clickedPanel
	var destPos = destPanel.get_global_transform().origin
	ownerChar.movePoints -= gridPanels[destPos].distance
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
		panel.get_node("Fade").play("Exit")
		gridPanels.erase(pos)
	pathPanels.remove(0)
	yield(ownerChar.walk(pathPanels), "completed")
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
				if gridPanels.keys().has(dest) and selectedChar.movePoints >= 1.0:
					
					selectedChar.movePoints -= 1
					yield(selectedChar.walk([dir]), "completed")
					refresh_panels()
					return
	if selectedChar:
		if Input.is_key_pressed(KEY_Z):
			selectedChar.jump()
		if Input.is_key_pressed(KEY_X):
			selectedChar.attack("Stab")
		if Input.is_key_pressed(KEY_ENTER):
			play_enemy_turn()
	var shift = Input.is_key_pressed(KEY_SHIFT)
	if !cameraMoving:
			
		if Input.is_key_pressed(KEY_W):
			cameraMoving = true
			if shift:
				if $CameraPivot.rotation_degrees.x > -60:
					yield(Helper.tween_rotate($CameraPivot, Vector3(-PI/36, 0, 0), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
			else:
				yield(Helper.tween_move($CameraPivot, Vector3(0, 0, -1), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
			cameraMoving = false
			return
		elif Input.is_key_pressed(KEY_S):
			cameraMoving = true
			if shift:
				if $CameraPivot.rotation_degrees.x < -30:
					yield(Helper.tween_rotate($CameraPivot, Vector3(PI/36, 0, 0), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
			else:
				yield(Helper.tween_move($CameraPivot, Vector3(0, 0, 1), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
			cameraMoving = false
			return
		elif Input.is_key_pressed(KEY_A):
			cameraMoving = true
			if shift:
				yield(Helper.tween_rotate($CameraPivot, Vector3(0, -PI/6, 0), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
			else:
				yield(Helper.tween_move($CameraPivot, Vector3(-1, 0, 0), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
			cameraMoving = false
			return
		elif Input.is_key_pressed(KEY_D):
			cameraMoving = true
			if shift:
				yield(Helper.tween_rotate($CameraPivot, Vector3(0, PI/6, 0), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
			else:
				yield(Helper.tween_move($CameraPivot, Vector3(1, 0, 0), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
			cameraMoving = false
			return
var cameraMoving = false

func get_areas(pos: Vector3, ignore: Array = []):
	var d = get_world().get_direct_space_state().intersect_point(pos + Vector3(0, 1.0, 0), 32, ignore, 2147483647, false, true)                                                                   
	var result = []
	for other in d:
		var col = other.collider
		result.append(col)
	return result
func get_heal(pos: Vector3, ignore: Array = []):
	var d = get_world().get_direct_space_state().intersect_point(pos + Vector3(0, 1.0, 0), 32, ignore, 2147483647, false, true)                                                                   
	var result = []
	for other in d:
		var col = other.collider
		if col.is_in_group("Heal"):
			result.append(col)
	return result
func is_open(pos: Vector3, ignore: Array = []):
	var d = get_world().get_direct_space_state().intersect_point(pos + Vector3(0, 1.0, 0), 32, ignore, 2147483647, false, true)                                                                   
	for other in d:
		var col = other.collider
		if col.is_in_group("NoMove"):
			return false
	return true
	
func has_ground(pos: Vector3, ignore: Array = []):
	var d = get_world().get_direct_space_state().intersect_point(pos + Vector3(0, -0.5, 0), 32, ignore, 2147483647, false, true)                                                                   
	for other in d:
		var col = other.collider
		if col.is_in_group("Ground"):
			return true
	return false
func get_ground(pos: Vector3, ignore: Array = []):
	var d = get_world().get_direct_space_state().intersect_point(pos + Vector3(0, -0.5, 0), 32, ignore, 2147483647, false, true)                                                                   
	for other in d:
		var col = other.collider
		if col.is_in_group("Ground"):
			return col
	return null
func get_ground_y(pos: Vector3, ignore: Array = [], allowWater = true):                                                                   
	var origin = get_ground_origin(pos, ignore, allowWater)
	if origin:
		return origin.y
	return null
func get_ground_origin(pos: Vector3, ignore: Array = [], allowWater = true):                                                                   
	var st = get_world().get_direct_space_state()
	
	for i in range(5):
		for other in st.intersect_point(pos + Vector3(0, -0.5 - i, 0), 32, ignore, 2147483647, false, true):
			var col = other.collider
			if col.is_in_group("Water") and !allowWater:
				continue
			if col.is_in_group("Ground"):
				return col.get_global_transform().origin
	return null
