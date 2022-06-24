tool
extends Spatial
export(Vector2) var size setget set_size
var tiles = {}
const Placeholder = preload("res://PlaceholderTile.tscn")
func set_size(s):
	if !Engine.editor_hint:
		return
	size = s
	if reset:
		tiles = {}
		
		for c in get_children():
			remove_child(c)
	else:
		for c in get_children():
			var p = c.transform.origin
			tiles[Vector2(p.x, p.z)] = c
			c.hide()
	for x in range(s.x):
		for y in range(s.y):
			var p = Vector2(x, -y)
			if p in tiles:
				tiles[p].show()
			else:
				var c = Placeholder.instance()
				c.show()
				tiles[p] = c
				c.transform.origin = Vector3(x, 0, -y)
				add_child(c)
				c.set_owner(get_tree().edited_scene_root)
			
export(bool) var reset = false
