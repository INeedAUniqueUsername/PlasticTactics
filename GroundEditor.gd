tool
extends Spatial

func add_child(node, legible_unique_name: bool = false ):
	.add_child(node, legible_unique_name)
	prints("added node ", node.get_name())


export(bool) var lock setget set_lock
func set_lock(l):
	if !Engine.editor_hint:
		return
	lock = l
	
	for c in get_placeholders():
		c.set_meta("_edit_lock_", {true: true, false: null}[l])

export(bool) var snap setget set_snap
func set_snap(s):
	if !Engine.editor_hint:
		return
	snap = s
	if s:
		for p in tiles.keys():
			var c = tiles[p]
			c.transform.origin = Vector3(p.x, c.transform.origin.y, p.y)

func _ready():
	pass
func get_placeholders():
	var result = []
	for c in get_children():
		if c.is_in_group("Placeholder"):
			result.append(c)
	return result
func register(c):
	var p = c.transform.origin
	tiles[Vector2(p.x, p.z)] = c
	c.name = "(%s, %s)" % [p.x, -p.z]
export(Vector2) var size setget set_size
var tiles = {}
const Placeholder = preload("res://PlaceholderTile.tscn")
func set_size(s):
	if !Engine.editor_hint:
		return
	size = s
	if reset:
		tiles = {}
		for c in get_placeholders():
			remove_child(c)
	else:
		for c in get_placeholders():
			register(c)
			c.hide()
	for x in range(s.x):
		for y in range(s.y):
			var p = Vector2(x, -y)
			if p in tiles:
				tiles[p].show()
			else:
				var c = Placeholder.instance()
				c.show()
				c.transform.origin = Vector3(x, 0, -y)
				register(c)
				add_child(c)
				c.set_owner(get_tree().edited_scene_root)
			
export(bool) var reset = false
