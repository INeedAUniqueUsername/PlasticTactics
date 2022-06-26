extends Spatial
var chars = []

func add_region(offset = null):
	if !offset:
		offset = Vector2(0, 0)
	var ground = Game.get_region(Game.region_pos + offset)
	if !ground:
		return
	offset = Helper.extrude_2d(offset, 0) * 32
	ground = ground.instance()
	#ground.name = "Ground"
	#add_child(ground)
	for c in ground.get_children():
		var origin = null
		if 'transform' in c:
			origin = c.transform.origin + offset
		ground.remove_child(c)
		if c.is_in_group("Placeholder"):
			$Ground.add_child(c)
		else:
			add_child(c)
		if origin:
			c.transform.origin = origin
	
func _ready():
	if Game.region_pos != null:
		add_region()
		for off in [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]:
			continue
			add_region(off)
	
	
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
	call_deferred("register_ground")
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
signal player_turn_started()
signal player_turn_ended()
func play_player_turn():
	
	var an = $CameraPivot/Camera/Control/Anim
	an.play("Player")
	yield(an, "animation_finished")
	
	emit_signal("player_turn_started")
	
	for c in get_misc_actors():
		if c.has_method("start_turn"):
			c.start_turn()
	for c in get_player_chars():
		c.start_turn()
	if selectedChar:
		selectedChar.selected()
func play_enemy_turn():
	if enemyMove:
		return
		
	
	emit_signal("player_turn_ended")
	
	for c in get_player_chars():
		c.end_turn()
		
	for c in get_misc_actors():
		if c.has_method("end_turn"):
			c.end_turn()
		
		
	var an = $CameraPivot/Camera/Control/Anim
	an.play("Enemy")
	yield(an, "animation_finished")
	
	
	
		
	
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

	
var selectedChar
var freeMove = false
func select_char(subject):
	if selectedChar:
		if selectedChar.walking:
			return
		selectedChar.deselected()
		if selectedChar == subject:
			selectedChar = null
			return
	selectedChar = subject
	selectedChar.selected()
		


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
					yield(Helper.tween_rotate($CameraPivot, Vector3(-PI/72, 0, 0), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
			else:
				yield(Helper.tween_move($CameraPivot, Vector3(0, 0, -1), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
			cameraMoving = false
			return
		elif Input.is_key_pressed(KEY_S):
			cameraMoving = true
			if shift:
				if $CameraPivot.rotation_degrees.x < -15:
					yield(Helper.tween_rotate($CameraPivot, Vector3(PI/72, 0, 0), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT), "completed")
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
func is_open(pos: Vector3, ignore: Array = []):
	for col in get_areas(pos, ignore):
		if col.is_in_group("NoMove"):
			return false
	return true
var ground = {}
func register_ground():
	for c in $Ground.get_children():
		if !c.is_in_group("Ground"):
			continue
		var origin = c.get_global_transform().origin
		ground[Vector2(origin.x, origin.z)] = c
func get_ground(pos: Vector3, ignore: Array = []):
	var d = get_world().get_direct_space_state().intersect_point(pos + Vector3(0, -0.5, 0), 32, ignore, 2147483647, false, true)                                                                   
	for other in d:
		var col = other.collider
		if col.is_in_group("Ground"):
			return col
	return null
func get_ground_origin(pos: Vector3, ignore: Array = [], allowWater = true):                                                                   
	var p = Vector2(pos.x, pos.z)
	if p in ground:
		return ground[p].get_global_transform().origin
	
	var st = get_world().get_direct_space_state()
	
	for i in range(5):
		for other in st.intersect_point(pos + Vector3(0, -0.5 - i, 0), 32, ignore, 2147483647, false, true):
			var col = other.collider
			if col.is_in_group("Water") and !allowWater:
				continue
			if col.is_in_group("Ground"):
				return col.get_global_transform().origin
	return null
